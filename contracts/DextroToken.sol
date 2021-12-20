pragma solidity ^0.8.7;
import './IERC20.sol';

contract DextToken is IERC20 {

    string public constant name = "DextroToken";
    string public constant symbol = "DXT";
    uint8 public constant decimals = 18;


    // event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    // event Transfer(address indexed from, address indexed to, uint value);

    address public contract_owner;

    mapping(address => bool) owners;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_;

    uint256 public owner_count = 0;

    constructor(uint256 total) {
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
        contract_owner = msg.sender;
        owners[msg.sender] = true;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[contract_owner]);
        balances[contract_owner] = balances[contract_owner] - numTokens;
        balances[receiver] = balances[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner] - numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender] - numTokens;
        balances[buyer] = balances[buyer] + numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function buyTokens() external payable {
        require(msg.value == 1 ether);
        transfer(msg.sender, 1);
        owners[msg.sender] = true;
        owner_count++;
    }

    function checkOwners(address addr) public view returns (bool) {
        return owners[addr];
    }
}



