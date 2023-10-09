// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Word Pool
 *  @date: 09-October-2023 
 *  @version: 1.1
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

contract randomText {

function getWord(uint256 id) private pure returns (string memory) {
    
    // array storing the words list
    string[10] memory wordsList = ["Acai", "Ackee", "Apple", "Apricot", "Avocado", "Babaco", "Banana", "Bilberry", "Blackberry", "Blackcurrant"];

    // returns a word based on index
    if (id==0) {
        return wordsList[id];
    } else {
        return wordsList[id - 1];
    }
    }

function randomNumber() public view returns (uint256){
    uint256 randomNum = uint(keccak256(abi.encodePacked(block.prevrandao,gasleft(),msg.sender,blockhash(block.number - 1),block.timestamp))) % 1000;
    return randomNum;
}

function randomWord() public view returns (string memory) {
    uint256 randomNum = uint(keccak256(abi.encodePacked(block.prevrandao,gasleft(),msg.sender,blockhash(block.number - 1),block.timestamp))) % 10;
    return getWord(randomNum);
}

function returnIndex(uint256 id) public view returns (string memory) {
    return getWord(id);
}


}