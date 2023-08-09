// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract WhiskyToken {
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    struct WhiskyCask {
        uint256 totalFractions;
        uint256 fractionPrice;
        uint256 exitPrice;
        uint256 age;
        string distillery;
        address owner;
    }

    WhiskyCask[] public casks;
    mapping(uint256 => address) public disputeClaims;
    mapping(address => uint256) public pendingWithdrawals;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event CaskCreated(uint256 indexed caskId, string distillery, uint256 totalFractions, uint256 fractionPrice, uint256 age);
    event FractionPurchased(uint256 indexed caskId, address indexed buyer, uint256 fractions);
    event CaskExited(uint256 indexed caskId, uint256 exitPrice);
    event DisputeFiled(uint256 indexed caskId, address indexed claimant);
    event DisputeResolved(uint256 indexed caskId, bool resolved);
    event CaskTransferred(uint256 indexed caskId, address indexed from, address indexed to);
    event FractionsSplit(uint256 indexed caskId, uint256 fractionToSplit, uint256 newFraction);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 initialSupply
    ) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = initialSupply * 10**uint256(decimals);
        balances[msg.sender] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function createCask(
        uint256 _totalFractions,
        uint256 _fractionPrice,
        uint256 _exitPrice,
        uint256 _age,
        string memory _distillery
    ) external onlyOwner {
        casks.push(
            WhiskyCask({
                totalFractions: _totalFractions,
                fractionPrice: _fractionPrice,
                exitPrice: _exitPrice,
                age: _age,
                distillery: _distillery,
                owner: msg.sender
            })
        );
        emit CaskCreated(casks.length - 1, _distillery, _totalFractions, _fractionPrice, _age);
    }

    function purchaseFractions(uint256 _caskId, uint256 _fractions) external payable {
        require(_caskId < casks.length, "Invalid cask ID");
        WhiskyCask storage cask = casks[_caskId];
        require(cask.owner != address(0), "Cask does not exist");
        require(_fractions > 0 && _fractions <= cask.totalFractions, "Invalid fractions");
        uint256 purchaseAmount = cask.fractionPrice * _fractions;
        require(msg.value >= purchaseAmount, "Insufficient payment");
        cask.owner = msg.sender;
        cask.totalFractions -= _fractions;
        balances[msg.sender] += _fractions;
        balances[cask.owner] -= _fractions;
        emit FractionPurchased(_caskId, msg.sender, _fractions);
    }

    function exitCask(uint256 _caskId) external {
        require(_caskId < casks.length, "Invalid cask ID");
        WhiskyCask storage cask = casks[_caskId];
        require(cask.owner == msg.sender, "Only the cask owner can exit");
        cask.owner = address(0);
        uint256 exitAmount = cask.exitPrice * cask.totalFractions;
        balances[msg.sender] += cask.totalFractions;
        cask.totalFractions = 0;
        emit CaskExited(_caskId, exitAmount);
    }

    function setCaskAge(uint256 _caskId, uint256 _age) external onlyOwner {
        require(_caskId < casks.length, "Invalid cask ID");
        WhiskyCask storage cask = casks[_caskId];
        cask.age = _age;
    }

    function fileDispute(uint256 _caskId) external {
        require(_caskId < casks.length, "Invalid cask ID");
        WhiskyCask storage cask = casks[_caskId];
        require(cask.owner != address(0), "Cask does not exist");
        disputeClaims[_caskId] = msg.sender;
        emit DisputeFiled(_caskId, msg.sender);
    }

    function resolveDispute(uint256 _caskId, bool _resolved) external onlyOwner {
        require(_caskId < casks.length, "Invalid cask ID");
        address claimant = disputeClaims[_caskId];
        require(claimant != address(0), "No dispute to resolve");
        WhiskyCask storage cask = casks[_caskId];
        if (_resolved) {
            cask.owner = claimant;
        }
        disputeClaims[_caskId] = address(0);
        emit DisputeResolved(_caskId, _resolved);
    }

    function transferCask(uint256 _caskId, address _newOwner) external {
        require(_caskId < casks.length, "Invalid cask ID");
        WhiskyCask storage cask = casks[_caskId];
        require(cask.owner == msg.sender, "Only the cask owner can transfer");
        cask.owner = _newOwner;
        emit CaskTransferred(_caskId, msg.sender, _newOwner);
    }

    function splitFraction(uint256 _caskId, uint256 _fractionToSplit, uint256 _newFraction) external {
        require(_caskId < casks.length, "Invalid cask ID");
        WhiskyCask storage cask = casks[_caskId];
        require(cask.owner == msg.sender, "Only the cask owner can split fractions");
        require(_fractionToSplit > 0 && _fractionToSplit <= cask.totalFractions, "Invalid fraction to split");
        require(_newFraction > 0 && _newFraction <= _fractionToSplit, "Invalid new fraction amount");

        cask.totalFractions += _newFraction;
        cask.totalFractions -= _fractionToSplit;

        balances[msg.sender] += _newFraction;
        balances[cask.owner] -= _newFraction;

        emit FractionsSplit(_caskId, _fractionToSplit, _newFraction);
    }

    function calculateProfits(uint256 _caskId) external view returns (uint256) {
        require(_caskId < casks.length, "Invalid cask ID");
        WhiskyCask storage cask = casks[_caskId];
        return cask.totalFractions * (cask.exitPrice - cask.fractionPrice);
    }

    function withdraw() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No pending withdrawals");
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}
