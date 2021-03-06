// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./BloomCurve.sol";
import "./interfaces/IBloomCurve.sol";
import "./interfaces/IBloomFactory.sol";
import "./interfaces/IERC20.sol";

contract BloomFactory is IBloomFactory {
    address public owner;
    address public immutable reserveToken;
    address[] public allCurves;
    mapping(address => address) public getCurve;

    constructor(
        address _reserveToken, 
        address _owner) {
        reserveToken = _reserveToken;
        owner = _owner;
    }

    function allCurvesLength() external view override returns (uint) {
        return allCurves.length;
    }

    function createCurve(
        string memory _tokenName, 
        string memory _tokenSymbol, 
        uint32 _reserveRatio,
        address _user
        ) external override returns (address curve) {
        require(getCurve[msg.sender] == address(0), 'BloomCurve: CURVE_EXISTS'); 
        bytes memory bytecode = type(BloomCurve).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(msg.sender));
        assembly {
            curve := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IBloomCurve(curve).initialize(_tokenSymbol,_tokenName, _user, reserveToken, _reserveRatio);
        getCurve[msg.sender] = curve;
        allCurves.push(curve);
        emit CurveCreated(msg.sender, curve, allCurves.length);
    }

    function setOwner(address _owner) external override {
        require(msg.sender == owner, 'BloomCurve: FORBIDDEN');
        owner = _owner;
    }

    function getFees(address _token, uint256 _amount, address _wallet) external override {
        require(msg.sender == owner, 'BloomCurve: FORBIDDEN');
        IERC20(_token).transfer(_wallet, _amount);
    }
}