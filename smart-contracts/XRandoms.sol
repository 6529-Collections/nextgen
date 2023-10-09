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

    uint256 acai;
    uint256 ackee;
    uint256 apple;
    uint256 apricot;
    uint256 avocado;
    uint256 babaco;
    uint256 banana;
    uint256 bilberry;
    uint256 blackberry;
    uint256 blackcurrant;

function getWord(uint256 id) private pure returns (string memory) {
    
    // array storing the words list
    string[10] memory wordsList = ["Acai", "Ackee", "Apple", "Apricot", "Avocado", "Babaco", "Banana", "Bilberry", "Blackberry", "Blackcurrant"];

    return wordsList[id];
    
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

function checkDistribution() public {
    for (uint256 i=0; i<20; i ++) {
        uint256 randomNum = uint(keccak256(abi.encodePacked(block.prevrandao,gasleft(),msg.sender,blockhash(block.number - 1),block.timestamp))) % 10;
        if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Acai"))) {
            acai = acai + 1;
        } else if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Ackee"))) {
            ackee = ackee + 1;
        } else if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Apple"))) {
            apple = apple + 1;
        } else if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Apricot"))) {
            apricot = apricot + 1;
        } else if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Avocado"))) {
            avocado = avocado + 1;
        } else if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Babaco"))) {
            babaco = babaco + 1;
        } else if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Banana"))) {
            banana = banana + 1;
        } else if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Bilberry"))) {
            bilberry = bilberry + 1;
        } else if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Blackberry"))) {
            blackberry = blackberry + 1;
        } else if (keccak256(abi.encodePacked(getWord(randomNum))) == keccak256(abi.encodePacked("Blackcurrant"))) {
            blackcurrant = blackcurrant + 1;
        }
    }
}

function returnDistribution() public view returns (uint256,uint256,uint256,uint256,uint256 ) {
    return (acai, ackee, apple, apricot, avocado);
}

function returnDistribution2() public view returns (uint256,uint256,uint256,uint256,uint256) {
    return (babaco, banana, bilberry, blackberry, blackcurrant);
}


}