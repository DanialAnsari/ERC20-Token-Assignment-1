                                        pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/GSN/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (uint => address) private approved_Addresses;
    
    mapping(address=>uint) private time_Lock;
    
    
    uint256 private _totalSupply;

    string private _name;

    
    string private _symbol;
    uint8 private _decimals;
    uint256 private _value;  
    uint counter=0;
    
    address payable private  owner=0xC50170C99805Ec5dd752099EE4b960CD496f2337                                                                                                                                                                                                                                               ;


    constructor (string memory name,string memory symbol,uint8 decimals,uint256 value) public {
        _name = name;
        _decimals=decimals;
        _symbol = symbol;
        
        _mint(owner,1000000000000);
        require(msg.sender == owner, "ERC20: Price can only be adjusted by owner");
        _value=value;
        
    }

    function fallBack() public payable{
        
        require(Address.isContract(msg.sender)==false, "ERC20: Address Should be EOA");
        
        uint256 _ether=msg.value/1000000000000000000;
        uint256 token=_ether*_value;
        
        
        approve(msg.sender,token);
        transfer(msg.sender,token);
        time_Lock[msg.sender]=now+ 30 days;
        
        
    }
    
    function sellToken(uint token2sell) public{
        require(_balances[msg.sender]>=token2sell,"Your Balance does not contain this many tokens");
        require(now>time_Lock[msg.sender],"Your tokens selling time has expired");
        uint256 _ether=token2sell/_value;
        uint256 _wei=_ether*1000000000000000000;
        msg.sender.transfer(_wei);
        
        
    }
    
    function delegateAddresses(address approver) public{
        
        approved_Addresses[counter]=approver;
        counter+=1;
        
    }
    
    
    
    function adjustPrice(uint value) public{
        bool check=false;
        for(uint i=0; i<=counter; i++) {
            if(msg.sender==approved_Addresses[i]){
                check=true;
                break;
            }
        }
        if(check || msg.sender==owner){
        _value=value;
            
        }
        else{
            require(msg.sender == owner, "ERC20: Owndership can only be transfered by current owner or appoved addresses");
        }
        
    }
    
    function transferOwnership(address payable new_owner) public{
        require(msg.sender == owner, "ERC20: Owndership can only be transfered by current owner");
        owner=new_owner;
    }
     
    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public view returns (uint8) {
        return _decimals;
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        
        _transfer(owner, recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(owner, spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, owner, _allowances[sender][owner].sub(amount, "ERC20 trfr: transfer amount exceeds allowance"));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(owner, spender, _allowances[owner][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(owner, spender, _allowances[(owner)][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20 tr: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }


    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}