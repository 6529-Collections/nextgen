// SPDX-License-Identifier: MIT

// demo contract

pragma solidity ^0.8.19;

contract Bytes32TestFunctions {
    
    function getBytes32(string memory words, string memory tokenid) public view returns (bytes32) {
        return bytes32(abi.encodePacked(words,tokenid));
    }

    function getStringEncode(string memory words, string memory tokenid) public view returns (string memory) {
        return string(abi.encode(words,tokenid));
    }

    function getStringPacked(string memory words, string memory tokenid) public view returns (string memory) {
        return string(abi.encodePacked(words,tokenid));
    }

    function getStringKeccak(string memory words, string memory tokenid) public view returns (bytes32) {
        return keccak256(abi.encodePacked(words,tokenid));
    }

    function fulfillRandomWordsBytes(uint256 tokenId, uint256[] memory _randomWords) public view returns (bytes32) {
        return bytes32(abi.encodePacked(_randomWords,tokenId));
    }

    function fulfillRandomWordsKeccack(uint256 tokenId, uint256[] memory _randomWords) public view returns (bytes32) {
        return keccak256(abi.encodePacked(_randomWords,tokenId));
    }

    function getKecKec(string memory words, string memory _tokenId) public view returns (bytes32) {
        return keccak256(bytes.concat(keccak256((abi.encodePacked(words, _tokenId)))));
    }

    function getConcat(bytes memory _hash) public view returns (bytes32) {
        return keccak256(abi.encodePacked(_hash));
    }

    function getMerkle(bytes32 _h1, bytes32 _h2) public view returns (bytes32) {
        return keccak256(abi.encodePacked(_h1,_h2));
    }

}