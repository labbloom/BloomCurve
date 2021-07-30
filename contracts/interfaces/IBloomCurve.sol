// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

interface IBloomCurve {
    function initialize(string memory _tokenSymbol, string memory _tokenName, address _user, address _reserveToken, uint32 _reserveRatio) external;
    function getContinuousMintAmount(uint256 _reserveTokenAmount) external view returns (uint256);
    function getContinuousRedeemAmount(uint256 _continuousTokenAmount) external view returns (uint256);
    function mint(uint256 _amount) external returns (bool);
    function redeem(uint256 _amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool);
    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Minted(address sender, uint256 amount, uint256 deposit);
    event Redeemed(address sender, uint256 amount, uint256 refund);
}