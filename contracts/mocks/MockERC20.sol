pragma solidity ^0.8.0;

import "./IMockErc20.sol";

contract MockErc20 is IMockErc20 {
    address public owner;
    mapping(address => uint256) private balances;

    mapping(address => mapping(address => uint256)) private allowances;

    uint256 private tokenTotalSupply = 0;
    string private tokenName; 
    string private tokenSymbol; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(
        uint256 initialSupply,
        string memory _name,
        string memory _symbol,
        address _owner
    ) public {
        owner = _owner;
        _mint(owner, initialSupply);
    }


    function name() external view override returns (string memory) {
        return tokenName;
    }

    function symbol() external view override returns (string memory) {
        return tokenSymbol;
    }

    function decimals() external view override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return tokenTotalSupply;
    }

    function balanceOf(address _account) public view override returns (uint256) {
        return balances[_account];
    }

    function transfer(address _recipient, uint256 _amount) external override returns (bool) {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256) {
        return allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external override returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external override returns (bool) {
        _transfer(_sender, _recipient, _amount);

        uint256 currentAllowance = allowances[_sender][msg.sender];
        require(currentAllowance >= _amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(_sender, msg.sender, currentAllowance - _amount);
        }
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) external override returns (bool) {
        _approve(msg.sender, _spender, allowances[msg.sender][_spender] + _addedValue);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) external override returns (bool) {
        uint256 currentAllowance = allowances[msg.sender][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, _spender, currentAllowance - _subtractedValue);
        }

        return true;
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = balances[_sender];
        require(senderBalance >= _amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            balances[_sender] = senderBalance - _amount;
        }
        balances[_recipient] += _amount;
        emit Transfer(_sender, _recipient, _amount);
    }

    function _mint(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: mint to the zero address");
        tokenTotalSupply += _amount;
        balances[_account] += _amount;
        emit Transfer(address(0), _account, _amount);
    }

    function _burn(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = balances[_account];
        require(accountBalance >= _amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balances[_account] = accountBalance - _amount;
        }
        tokenTotalSupply -= _amount;
        emit Transfer(_account, address(0), _amount);
    }

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner.
    function mint(address _to, uint256 _amount) public override {
        require(msg.sender == owner, 'ERC20: FORBIDDEN');
        _mint(_to, _amount);
    }
}