// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

interface IBloomFactory {
    function allCurvesLength() external view returns (uint);
    function createCurve(string memory _tokenName, string memory _tokenSymbol, uint32 _curveParam) external returns (address curve);
    function setOwner(address _owner) external;

    event CurveCreated(address indexed user, address curve, uint allCurvesSize);
}