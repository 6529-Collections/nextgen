// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract optionalRetrieveFunctions {
    
    // get Selector

    function getSelector(string calldata _func) public view returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

    // function to retrieve bytes32 used in initialization of burn or swap to mint

    function retrieveKeccakForExtCol(address _erc721Collection, uint256 _burnCollectionID) public view returns (bytes32) {
        return keccak256(abi.encodePacked(_erc721Collection,_burnCollectionID));
    }

}