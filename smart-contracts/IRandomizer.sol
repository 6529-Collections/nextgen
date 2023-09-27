// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IRandomizer {

    // function that calculates the random hash and returns it to the gencore contract
    function calculateTokenHash(uint256 _mintIndex, address _address, uint256 _varg0) external view returns(bytes32);

    // get randomizer contract status
    function isRandomizerContract() external view returns (bool);
    
}