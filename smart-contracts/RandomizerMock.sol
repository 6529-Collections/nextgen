// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Randomizer Contract Mock
 *  @date: 12-October-2023 
 *  @version: 1.1
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./INextGenCore.sol";


contract NextGenRandomizerMock {

    address gencore;
    INextGenCore public gencoreContract;

    constructor(address _gencore) {
        gencore = _gencore;
        gencoreContract = INextGenCore(_gencore);
    }

    function requestRandomWords(uint256 tokenid) public returns (bool) {
        require(msg.sender == gencore);
        bytes32 tokenHash = keccak256(abi.encodePacked(tokenid, blockhash(block.number - 1)));
        gencoreContract.setTokenHash(tokenid, tokenHash);
        return true;
    }

    // function that calculates the random hash and returns it to the gencore contract
    function calculateTokenHash(uint256 _mintIndex, uint256 _saltfun_o) public {
        require(msg.sender == gencore);
        requestRandomWords(_mintIndex);
    }

    // get randomizer contract status
    function isRandomizerContract() external view returns (bool) {
        return true;
    }

}