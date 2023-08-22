// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IRandomizer {

    function calculateTokenHash(uint256 _mintIndex, address _address, uint256 _varg0) external view returns(bytes32);
    
}