// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IRandoms {

    function randomNumber() external view returns (uint256);

    function randomWord() external view returns (string memory);
    
}