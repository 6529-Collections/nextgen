// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Randomizer Contract
 *  @date: 22-August-2023 
 *  @version: 1.0
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

contract NextGenRandomizer {

    // function that calculates the random hash and returns it to the gencore contract

    function calculateTokenHash(uint256 _mintIndex, address _address, uint256 _varg0) public view returns(bytes32) {
        return keccak256(abi.encodePacked(_mintIndex, blockhash(block.number - 1), _address, _varg0));
    }
    
}