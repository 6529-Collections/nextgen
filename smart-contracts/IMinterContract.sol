// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IMinterContract {

    function isMinterContract() external view returns (bool);

    function getEndTime(uint256 _collectionID) external view returns (uint);
    
}