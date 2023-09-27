// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Randomizer Contract
 *  @date: 27-September-2023 
 *  @version: 1.1
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

contract NextGenRandomizer {

    // function that calculates the random hash and returns it to the gencore contract
    function calculateTokenHash(uint256 _mintIndex, address _address, uint256 _varg0) public view returns(bytes32) {
        return keccak256(abi.encodePacked(_mintIndex, blockhash(block.number - 1), _address, _varg0));
    }

    // get randomizer contract status
    function isRandomizerContract() external view returns (bool) {
        return true;
    }
    
}