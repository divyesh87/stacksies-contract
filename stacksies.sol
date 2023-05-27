// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract StacksiesToken {
    uint256 public totalSupply;
    string public name = "Stacksies Token";
    string public symbol = "STK";
    uint256 public decimals = 2;
    uint256 private freeClaimAmount = 100000;

    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public claimList;
    mapping(address => Stake) public stakes;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _from,
        address indexed _spender,
        uint256 _value
    );


    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");
        balanceOf[_to] += _value;
        balanceOf[msg.sender] -= _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function mint(address _receipient, uint256 _amount) internal returns (bool success){
        balanceOf[_receipient] +=  _amount;
        totalSupply += _amount;
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(
            _value <= balanceOf[_from],
            "Spender account doesn't have enough balance"
        );
        require(
            _value <= allowance[_from][msg.sender],
            "You don't have permission to spend this amount of token"
        );
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }


// The below functions are for Staking functionality and are not part of the erc20 standard


    function stake(uint256 _amount) public returns (bool success){
        require(_amount > 0, "Amount zero");
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        require(stakes[msg.sender].amount == 0, "Already staked");

        balanceOf[msg.sender] -= _amount;
        stakes[msg.sender] = Stake(_amount, block.timestamp);
        return true;
    }

    function calculateRewards(address _owner) public view returns (uint256 reward){
        if(stakes[_owner].amount == 0){
            return 0;
        }
        uint256 rewards = block.timestamp - stakes[_owner].timestamp;
        return rewards;
    } 

    function unstake() public returns (bool success){
        require(stakes[msg.sender].amount > 0, "No amount staked");
        balanceOf[msg.sender] += stakes[msg.sender].amount;
        withdrawRewards();
        delete stakes[msg.sender];
        return true;
    }

    function withdrawRewards() public returns (bool success){
        uint256 rewards = calculateRewards(msg.sender);
        stakes[msg.sender].timestamp = block.timestamp;
        mint(msg.sender, rewards);
        return true;
    }

    function claimFreeTokens(address _receipient) public returns (bool success){
        require(claimList[_receipient] == false, "Already claimed free tokens!");
        balanceOf[_receipient] += freeClaimAmount;
        totalSupply += freeClaimAmount;
        claimList[_receipient] = true;
        return true;
    }
}
