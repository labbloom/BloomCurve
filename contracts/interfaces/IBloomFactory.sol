// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

interface IBloomFactory {
    function allCurvesLength() external view returns (uint);
    function createCurve(string memory _tokenName, string memory _tokenSymbol, uint32 _curveParam, address _user) external returns (address curve);
    function setOwner(address _owner) external;
    function getFees(address _token, uint256 _amount, address _wallet) external;

    event CurveCreated(address indexed user, address curve, uint allCurvesSize);
}