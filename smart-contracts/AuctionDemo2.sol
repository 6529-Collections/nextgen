// SPDX-License-Identifier: MIT

/**
 *
 *  @title: Auction Contract
 *  @date: 07-December-2023 
 *  @version: 1.4
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./IMinterContract.sol";
import "./IERC721.sol";
import "./INextGenAdmins.sol";
import "./ReentrancyGuard.sol";

contract auctionContract is ReentrancyGuard {

    //events 

    event Participate(address indexed _add, uint256 indexed tokenid, uint256 indexed funds);
    event ClaimAuction(address indexed _add, uint256 indexed tokenid, bool status, uint256 indexed funds);
    event Refund(address indexed _add, uint256 indexed tokenid, bool status, uint256 indexed funds);
    event CancelBid(address indexed _add, uint256 indexed tokenid, uint256 index, bool status, uint256 indexed funds);
    event Withdraw(address indexed _add, bool status, uint256 indexed funds);

    IMinterContract public minterContract;
    INextGenAdmins public adminsContract;
    address gencore;
    uint256 public startingBid;

    // certain functions can only be called by a global or function admin

    modifier FunctionAdminRequired(bytes4 _selector) {
      require(adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true , "Not allowed");
      _;
    }

    // certain functions can only be called by auction winner or admin
    modifier WinnerOrAdminRequired(uint256 _tokenId, bytes4 _selector) {
      require(msg.sender == returnHighestBidder(_tokenId) || adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true, "Not allowed");
      _;
    }

    constructor (address _minterContract, address _gencore, address _adminsContract, uint256 _startingBid) public {
        minterContract = IMinterContract(_minterContract);
        gencore = _gencore;
        adminsContract = INextGenAdmins(_adminsContract);
        startingBid = _startingBid;
    }

    // auction Bidders
    struct auctionInfoStru {
        address bidder;
        uint256 bid;
        bool status;
        bool refunded;
    }

    // mapping of auction info per token id
    mapping (uint256 => auctionInfoStru[]) public auctionInfoData;

    // claim auctioned
    mapping (uint256 => bool) public auctionClaim;

    // auction error
    mapping (uint256 => bool) public auctionError;

    // mapping of auction info per token id
    mapping (uint256 => mapping (address => uint256)) public bidsPerAddress;

    // participate to auction

    function participateToAuction(uint256 _tokenid) public payable {
        uint256 bid;
        if (auctionInfoData[_tokenid].length == 0) {
            bid = startingBid;
        } else {
            bid = returnHighestBid(_tokenid);
        }
        require(msg.value > bid && block.timestamp <= minterContract.getAuctionEndTime(_tokenid) && minterContract.getAuctionStatus(_tokenid) == true);
        // cancel existing bid
        if (bidsPerAddress[_tokenid][msg.sender] > 0) {
            cancelBid(_tokenid);
        }
        // register the new bid;
        bidsPerAddress[_tokenid][msg.sender] = bidsPerAddress[_tokenid][msg.sender] + msg.value;
        auctionInfoStru memory newBid = auctionInfoStru(msg.sender, msg.value, true, false);
        auctionInfoData[_tokenid].push(newBid);
        emit Participate(msg.sender, _tokenid, msg.value);
    }

    // claim after end of auction Auction (winner or admin)

    function claimAuction(uint256 _tokenid) public nonReentrant WinnerOrAdminRequired(_tokenid, this.claimAuction.selector) {
        require(block.timestamp > minterContract.getAuctionEndTime(_tokenid) && auctionClaim[_tokenid] == false);
        require(auctionError[_tokenid] == false);
        auctionClaim[_tokenid] = true;
        uint256 highestBid = returnHighestBid(_tokenid);
        address ownerOfToken = IERC721(gencore).ownerOf(_tokenid);
        address highestBidder = returnHighestBidder(_tokenid);
        for (uint256 i=0; i< auctionInfoData[_tokenid].length; i++) {
            if (auctionInfoData[_tokenid][i].bidder == highestBidder && auctionInfoData[_tokenid][i].bid == highestBid && auctionInfoData[_tokenid][i].status == true) {
                IERC721(gencore).safeTransferFrom(ownerOfToken, highestBidder, _tokenid);
                (bool success, ) = payable(ownerOfToken).call{value: highestBid}("");
                require(success, "ETH failed");
                emit ClaimAuction(ownerOfToken, _tokenid, success, highestBid);
            } else if (auctionInfoData[_tokenid][i].status == true && auctionInfoData[_tokenid][i].refunded == false) {
                auctionInfoData[_tokenid][i].refunded = true;
                bidsPerAddress[_tokenid][auctionInfoData[_tokenid][i].bidder] = bidsPerAddress[_tokenid][auctionInfoData[_tokenid][i].bidder] - auctionInfoData[_tokenid][i].bid;
                (bool success, ) = payable(auctionInfoData[_tokenid][i].bidder).call{value: auctionInfoData[_tokenid][i].bid}("");
                require(success, "ETH failed");
                emit Refund(auctionInfoData[_tokenid][i].bidder, _tokenid, success, highestBid);
            }
        }
    }

    // claim using small indices (admin only)

    function claimAuctionAdmin(uint256 _tokenid, uint256 _startIndex, uint256 _endIndex, uint256 _highBid, address _highBidder) public FunctionAdminRequired(this.claimAuctionAdmin.selector){
        require(block.timestamp > minterContract.getAuctionEndTime(_tokenid) && auctionClaim[_tokenid] == false && minterContract.getAuctionStatus(_tokenid) == true);
        auctionError[_tokenid] = true;
        uint256 highestBid = _highBid;
        address ownerOfToken = IERC721(gencore).ownerOf(_tokenid);
        address highestBidder = _highBidder;
        for (uint256 i=_startIndex; i <= _endIndex; i ++) {
            if (auctionInfoData[_tokenid][i].bidder == highestBidder && auctionInfoData[_tokenid][i].bid == highestBid && auctionInfoData[_tokenid][i].status == true) {
                IERC721(gencore).safeTransferFrom(ownerOfToken, highestBidder, _tokenid);
                (bool success, ) = payable(ownerOfToken).call{value: highestBid}("");
                require(success, "ETH failed");
                emit ClaimAuction(ownerOfToken, _tokenid, success, highestBid);
            } else if (auctionInfoData[_tokenid][i].status == true && auctionInfoData[_tokenid][i].refunded == false) {
                auctionInfoData[_tokenid][i].refunded = true;
                bidsPerAddress[_tokenid][auctionInfoData[_tokenid][i].bidder] = bidsPerAddress[_tokenid][auctionInfoData[_tokenid][i].bidder] - auctionInfoData[_tokenid][i].bid;
                (bool success, ) = payable(auctionInfoData[_tokenid][i].bidder).call{value: auctionInfoData[_tokenid][i].bid}("");
                require(success, "ETH failed");
                emit Refund(auctionInfoData[_tokenid][i].bidder, _tokenid, success, highestBid);
            }
        }
    }

    // cancel Bids

    function cancelBid(uint256 _tokenid) public nonReentrant {
        require(block.timestamp <= minterContract.getAuctionEndTime(_tokenid), "Auction ended");
        require(bidsPerAddress[_tokenid][msg.sender] > 0);
        for (uint256 i=0; i < auctionInfoData[_tokenid].length; i++) {
            if (auctionInfoData[_tokenid][i].bidder == msg.sender && auctionInfoData[_tokenid][i].status == true) {
                uint256 bid = auctionInfoData[_tokenid][i].bid;
                address bidder = auctionInfoData[_tokenid][i].bidder;
                uint256 lastBid = auctionInfoData[_tokenid][auctionInfoData[_tokenid].length-1].bid;
                address lastBidder = auctionInfoData[_tokenid][auctionInfoData[_tokenid].length-1].bidder;
                auctionInfoData[_tokenid][i].bid = lastBid;
                auctionInfoData[_tokenid][i].bidder = lastBidder;
                bidsPerAddress[_tokenid][msg.sender] = bidsPerAddress[_tokenid][msg.sender] - bid;
                (bool success, ) = payable(bidder).call{value: bid}("");
                require(success, "ETH failed");
                emit CancelBid(msg.sender, _tokenid, i, success, bid);
            }
        }
        auctionInfoData[_tokenid].pop();
    }

    // function to update starting bid

    function updateStartingBid(uint256 _startingBid) public FunctionAdminRequired(this.updateStartingBid.selector) {
        startingBid = _startingBid;
    }

    // function to add a minter contract

    function addMinterContract(address _minterContract) public FunctionAdminRequired(this.addMinterContract.selector) { 
        require(IMinterContract(_minterContract).isMinterContract() == true, "Contract is not Minter");
        minterContract = IMinterContract(_minterContract);
    }

    // function to update admin contract

    function updateAdminContract(address _newadminsContract) public FunctionAdminRequired(this.updateAdminContract.selector) {
        require(INextGenAdmins(_newadminsContract).isAdminContract() == true, "Contract is not Admin");
        adminsContract = INextGenAdmins(_newadminsContract);
    }

    // function to withdraw any balance from the smart contract

    function emergencyWithdraw() public FunctionAdminRequired(this.emergencyWithdraw.selector) {
        uint balance = address(this).balance;
        address admin = adminsContract.owner();
        (bool success, ) = payable(admin).call{value: balance}("");
        require(success, "ETH failed");
        emit Withdraw(msg.sender, success, balance);
    }

    // get highest bid

    function returnHighestBid(uint256 _tokenid) public view returns (uint256) {
        uint256 index;
        if (auctionInfoData[_tokenid].length > 0) {
            uint256 highBid = 0;
            for (uint256 i=0; i< auctionInfoData[_tokenid].length; i++) {
                if (auctionInfoData[_tokenid][i].bid > highBid && auctionInfoData[_tokenid][i].status == true) {
                    highBid = auctionInfoData[_tokenid][i].bid;
                    index = i;
                }
            }
            if (auctionInfoData[_tokenid][index].status == true) {
                return highBid;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    // get highest bidder

    function returnHighestBidder(uint256 _tokenid) public view returns (address) {
        uint256 highBid = 0;
        uint256 index;
        for (uint256 i=0; i< auctionInfoData[_tokenid].length; i++) {
            if (auctionInfoData[_tokenid][i].bid > highBid && auctionInfoData[_tokenid][i].status == true) {
                highBid = auctionInfoData[_tokenid][i].bid;
                index = i;
            }
        }
        if (auctionInfoData[_tokenid][index].status == true) {
                return auctionInfoData[_tokenid][index].bidder;
            } else {
                revert("No Active Bidder");
        }
    }

    // return Bids
    // true, false = participated not refunded --> after end of auction winner
    // true, true = participated and refunded

    function returnBids(uint256 _tokenid) public view returns(auctionInfoStru[] memory) {
        return auctionInfoData[_tokenid];
    }

}