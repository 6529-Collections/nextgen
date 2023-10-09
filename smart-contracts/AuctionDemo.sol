// SPDX-License-Identifier: MIT

/**
 *
 *  @title: Auction Demo Contract (work in progress - not to be used)
 *  @date: 09-October-2023 
 *  @version: 1.0
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./IMinterContract.sol";
import "./IERC721.sol";
import "./Ownable.sol";

contract auctionDemo is Ownable {

    //events 

    event ClaimAuction(address indexed _add, uint256 indexed tokenid, bool status, uint256 indexed funds);
    event Refund(address indexed _add, uint256 indexed tokenid, bool status, uint256 indexed funds);
    event CancelBid(address indexed _add, uint256 indexed tokenid, uint256 index, bool status, uint256 indexed funds);

    IMinterContract public minter;
    address gencore;

    constructor (address _minter, address _gencore) public {
        minter = IMinterContract(_minter);
        gencore = _gencore;
    }

    // auction Bidders
    struct auctionInfoStru {
        address bidder;
        uint256 bid;
        bool status;
    }

    // mapping of collectionSecondaryAddresses struct
    mapping (uint256 => auctionInfoStru[]) public auctionInfoData;

    // claim auctioned
    mapping (uint256 => bool) public auctionClaim;

    // participate to auction

    function participateToAuction(uint256 _tokenid) public payable {
        require(msg.value > returnHighestBid(_tokenid) && block.timestamp <= minter.getAuctionEndTime(_tokenid) && minter.getAuctionStatus(_tokenid) == true);
        auctionInfoStru memory newBid = auctionInfoStru(msg.sender, msg.value, true);
        auctionInfoData[_tokenid].push(newBid);
    }

    // get highest bid

    function returnHighestBid(uint256 _tokenid) public view returns (uint256) {
        if (auctionInfoData[_tokenid].length > 0) {
            uint256 highBid = auctionInfoData[_tokenid][0].bid;
            for (uint256 i=0; i< auctionInfoData[_tokenid].length; i++) {
                if (auctionInfoData[_tokenid][i].bid > highBid) {
                    highBid = auctionInfoData[_tokenid][i].bid;
                }
            }
            return highBid;
        } else {
            return 0;
        }
    }

    // get highest bidder

    function returnHighestBidder(uint256 _tokenid) public view returns (address) {
        uint256 highBid = auctionInfoData[_tokenid][0].bid;
        uint256 index;
        for (uint256 i=0; i< auctionInfoData[_tokenid].length; i++) {
            if (auctionInfoData[_tokenid][i].bid > highBid && auctionInfoData[_tokenid][i].status == true) {
                index = i;
            }
        }
        return auctionInfoData[_tokenid][index].bidder;
    }

    // claim Token After Auction

    function claimAuction(uint256 _tokenid) public {
        require(block.timestamp >= minter.getAuctionEndTime(_tokenid) && auctionClaim[_tokenid] == false && minter.getAuctionStatus(_tokenid) == true);
        uint256 auctionFunds = returnHighestBid(_tokenid);
        address ownerOfToken = IERC721(gencore).ownerOf(_tokenid);
        address highestBidder = returnHighestBidder(_tokenid);
        for (uint256 i=0; i< auctionInfoData[_tokenid].length; i ++) {
            if (auctionInfoData[_tokenid][i].bidder == highestBidder && auctionInfoData[_tokenid][i].bid == auctionFunds && auctionInfoData[_tokenid][i].status == true) {
                IERC721(gencore).safeTransferFrom(ownerOfToken, highestBidder, _tokenid);
                (bool success, ) = payable(owner()).call{value: auctionFunds}("");
                emit ClaimAuction(owner(), _tokenid, success, auctionFunds);
            } else if (auctionInfoData[_tokenid][i].status == true) {
                (bool success, ) = payable(auctionInfoData[_tokenid][i].bidder).call{value: auctionInfoData[_tokenid][i].bid}("");
                emit Refund(auctionInfoData[_tokenid][i].bidder, _tokenid, success, auctionFunds);
            } else {}
        }
        auctionClaim[_tokenid] = true;
    }

    // cancel Auction Bid

    function cancelBid(uint256 _tokenid, uint256 index) public {
        require(auctionInfoData[_tokenid][index].bidder == msg.sender && auctionInfoData[_tokenid][index].status == true);
        auctionInfoData[_tokenid][index].status = false;
        (bool success, ) = payable(auctionInfoData[_tokenid][index].bidder).call{value: auctionInfoData[_tokenid][index].bid}("");
        emit CancelBid(msg.sender, _tokenid, index, success, auctionInfoData[_tokenid][index].bid);
    }

    // cancel Auction Bids

    function cancelAllBids(uint256 _tokenid) public {
        for (uint256 i=0; i<auctionInfoData[_tokenid].length; i++) {
            if (auctionInfoData[_tokenid][i].bidder == msg.sender && auctionInfoData[_tokenid][i].status == true) {
                auctionInfoData[_tokenid][i].status = false;
                (bool success, ) = payable(auctionInfoData[_tokenid][i].bidder).call{value: auctionInfoData[_tokenid][i].bid}("");
                emit CancelBid(msg.sender, _tokenid, i, success, auctionInfoData[_tokenid][i].bid);
            } else {}
        }
    }


}