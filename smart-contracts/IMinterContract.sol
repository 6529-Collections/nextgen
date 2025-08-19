// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface IMinterContract {

    // retrieve if the contract is minter contract
    function isMinterContract() external view returns (bool);

    // retrieve the public end time of a sale
    function getEndTime(uint256 _collectionID) external view returns (uint);

    // retrieve auction end time
    function getAuctionEndTime(uint256 _tokenId) external view returns (uint);

    // retrieve auctions start time
    function getAuctionStartTime(uint256 _tokenId) external view returns (uint);

    // retrieve auction status
    function getAuctionStatus(uint256 _tokenId) external view  returns (bool);

    // retrieve primary addresses
    function retrievePrimaryAddressesAndPercentages(uint256 _collectionID) external view returns(address, address, address, uint256, uint256, uint256, bool);
    
    // retrieve secondary addresses
    function retrieveSecondaryAddressesAndPercentages(uint256 _collectionID) external view returns(address, address, address, uint256, uint256, uint256, bool);

    // update auction endtime
    function updateAuctionEndTime(uint256 _tokenId, uint256 _auctionEndTime) external;
}