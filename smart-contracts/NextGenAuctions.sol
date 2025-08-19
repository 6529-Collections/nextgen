// SPDX-License-Identifier: MIT

/**
 *
 *  @title: Auction Contract for 6529 NextGen
 *  @date: 11-August-2024
 *  @version: 1.9
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./IMinterContract.sol";
import "./INextGenCore.sol";
import "./IERC721.sol";
import "./INextGenAdmins.sol";
import "./ReentrancyGuard.sol";

contract NextGenAuctions is ReentrancyGuard {

    // variables declaration
    IMinterContract public minterContract;
    INextGenAdmins public adminsContract;
    INextGenCore public coreContract;
    address public gencore;

    // certain functions can only be called by a global or function admin
    modifier FunctionAdminRequired(bytes4 _selector) {
      require(adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true , "Not allowed");
      _;
    }

    // events 
    event Participate(address indexed _add, uint256 indexed tokenid, uint256 indexed bid);
    event ClaimAuction(uint256 indexed tokenid, uint256 indexed bid);
    event Withdraw(address indexed _add, bool status, uint256 indexed funds);

    // constructor
    constructor (address _minterContract, address _gencore, address _adminsContract) {
        minterContract = IMinterContract(_minterContract);
        coreContract = INextGenCore(_gencore);
        gencore = _gencore;
        adminsContract = INextGenAdmins(_adminsContract);
    }

    // auction highest bid
    mapping (uint256 => uint256) public auctionHighestBid;

    // aduction highest bidder
    mapping (uint256 => address) public auctionHighestBidder;

    // auction claim
    mapping (uint256 => bool) public auctionClaim;

    struct auctionStr {
        uint256 minBidPrice;
        uint256 incrPercent;
        uint256 extensionTime;
        address payOutAddress;
        bool status;
    }

    // colletion auction data
    mapping (uint256 => auctionStr) public auctionData;

    // set auction collection data per collection

    function setCollectionAuctionData(uint256 _col, uint256 _minBidPrice, uint256 _incrPercent, uint256 _extensionTime, address _payOutAddress, bool _status) public FunctionAdminRequired(this.setCollectionAuctionData.selector) {
        require(coreContract.retrievewereDataAdded(_col) == true, "Add data");
        auctionData[_col].minBidPrice = _minBidPrice;
        auctionData[_col].incrPercent = _incrPercent;
        auctionData[_col].extensionTime = _extensionTime;
        auctionData[_col].payOutAddress = _payOutAddress;
        auctionData[_col].status = _status;
    }

    // participate to auction
    function participateToAuction(uint256 _tokenid) public payable {
        uint256 colId = coreContract.viewColIDforTokenID(_tokenid);
        uint256 endTime = minterContract.getAuctionEndTime(_tokenid);
        require(block.timestamp >= minterContract.getAuctionStartTime(_tokenid) && block.timestamp <=  endTime && minterContract.getAuctionStatus(_tokenid) == true, "No Active Auction");
        require(auctionData[colId].status == true, "Set auction data");
        uint256 bid;
        address currentBidder;
        if (auctionHighestBid[_tokenid] == 0) {
            bid = auctionData[colId].minBidPrice;
            // bid can be equal to the starting bid
            require(msg.value >= bid, "Equal or Higher than starting bid");
        } else {
            bid = auctionHighestBid[_tokenid];
            // bid must be equal or larger than current highest bid by a %
            require(msg.value >= bid + (bid * auctionData[colId].incrPercent / 100), "% more than highest bid");
            currentBidder = auctionHighestBidder[_tokenid];
            (bool success1, ) = payable(currentBidder).call{value: (bid)}("");
            require(success1, "ETH failed");
        }
        // extend auction if less than X remaining mins
        if (endTime - block.timestamp <= auctionData[colId].extensionTime ) {
            minterContract.updateAuctionEndTime(_tokenid, endTime + auctionData[colId].extensionTime);
        }
        // register the new bid;
        auctionHighestBid[_tokenid] = msg.value;
        auctionHighestBidder[_tokenid] = msg.sender;
        emit Participate(msg.sender, _tokenid, msg.value);
    }

    // claim token after auction end
    function claimAuction(uint256 _tokenid) public nonReentrant {
        require(block.timestamp > minterContract.getAuctionEndTime(_tokenid) && minterContract.getAuctionStatus(_tokenid) == true && auctionClaim[_tokenid] == false, "err"); 
        uint256 highestBid = auctionHighestBid[_tokenid];
        require(highestBid > 0 , "No bids");
        address ownerOfToken = IERC721(gencore).ownerOf(_tokenid);
        address highestBidder = auctionHighestBidder[_tokenid];
        uint256 colId = coreContract.viewColIDforTokenID(_tokenid);
        auctionClaim[_tokenid] = true;
        (bool success, ) = payable(auctionData[colId].payOutAddress).call{value: (highestBid)}("");
        require(success, "ETH failed");
        IERC721(gencore).safeTransferFrom(ownerOfToken, highestBidder, _tokenid);
        emit ClaimAuction(_tokenid, highestBid);
    }

    // function to add a minter contract
    function updateMinterContract(address _minterContract) public FunctionAdminRequired(this.updateMinterContract.selector) { 
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

    // function to return collection auction details
    function getCollectionAuctionData(uint256 _col) public view returns (uint256, uint256, uint256, address, bool) {
        return (auctionData[_col].minBidPrice, auctionData[_col].incrPercent, auctionData[_col].extensionTime, auctionData[_col].payOutAddress, auctionData[_col].status);
    }

}