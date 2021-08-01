// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./math/BancorFormula.sol";
import "./interfaces/IBloomCurve.sol";
import "./interfaces/IERC20.sol";

contract BloomCurve is BancorFormula, IBloomCurve {
    address public reserveToken;
    uint32 public reserveRatio;
    /*
        reserve ratio, represented in ppm, 1-1000000
        1/3 corresponds to y= multiple * x^2
        1/2 corresponds to y= multiple * x
        2/3 corresponds to y= multiple * x^1/2
    */
    uint256 internal redeemFee = 100;
    uint256 internal mintFee = 100;
    address public owner;
    address public factory;
    mapping(address => uint256) private balances;

    mapping(address => mapping(address => uint256)) private allowances;

    uint256 private tokenTotalSupply = 10**3;
    string private tokenName; 
    string private tokenSymbol; 


    constructor() public {
        factory = msg.sender;
        _mint(address(this), 10**3);
    }

    function initialize(
        string memory _tokenSymbol, 
        string memory _tokenName, 
        address _user, 
        address _reserveToken, 
        uint32 _reserveRatio
        ) external override {
        require(msg.sender == factory, 'Bloom: FORBIDDEN'); // sufficient check
        owner = _user;
        reserveToken = _reserveToken;
        reserveRatio = _reserveRatio;
        tokenSymbol = _tokenSymbol;
        tokenName = _tokenName;
    }

    function getContinuousMintAmount(uint256 _reserveTokenAmount) public view override returns (uint256) {
        return calculatePurchaseReturn(totalSupply(), balanceOf(address(this)), reserveRatio, _reserveTokenAmount);
    }

    function getContinuousRedeemAmount(uint256 _continuousTokenAmount) public view override returns (uint256) {
        return calculateSaleReturn(totalSupply(), balanceOf(address(this)), reserveRatio, _continuousTokenAmount);
    }

    function continuousMint(uint256 _deposit) internal returns (bool) {
        require(_deposit > 0, "Deposit must be non-zero.");
        uint256 rewardAmount = getContinuousMintAmount(_deposit);
        _mint(msg.sender, rewardAmount);
        emit Minted(msg.sender, rewardAmount, _deposit);
        return true;
    }

    function continuousBurn(uint256 _amount) internal returns (bool) {
        require(_amount > 0, "Amount must be non-zero.");
        require(balanceOf(msg.sender) >= _amount, "Insufficient tokens to burn.");
        uint256 refundAmount = getContinuousRedeemAmount(_amount);
        _burn(msg.sender, _amount);
        emit Redeemed(msg.sender, _amount, refundAmount);
        return true;
    }

    function mint(uint256 _amount) external override returns (bool) {
        uint256 mintTax = (_amount * mintFee) / 1000;
        uint256 adjustedAmount = _amount - mintTax;
        continuousMint(adjustedAmount);
        require(IERC20(reserveToken).transferFrom(msg.sender, address(this), _amount), "mint() ERC20.transferFrom failed.");
        require(IERC20(reserveToken).transfer(owner, mintTax), "mint() ERC20.transferFrom failed.");
        return true;
    }

    function redeem(uint256 _amount) external override returns (bool) {
        uint256 redeemTax = (_amount * redeemFee) / 1000;
        uint256 adjustedAmount = _amount - redeemTax;
        continuousBurn(adjustedAmount);
        require(IERC20(reserveToken).transfer(msg.sender, adjustedAmount), "burn() ERC20.transfer failed.");
        require(IERC20(reserveToken).transfer(owner, redeemTax), "burn() ERC20.transfer failed.");
        return true;
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
}

