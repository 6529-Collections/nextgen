// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Randomizer Contract VRF
 *  @date: 12-October-2023 
 *  @version: 1.5
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";
import "./Ownable.sol";
import "./INextGenCore.sol";
import "./INextGenAdmins.sol";

contract NextGenRandomizerVRF is VRFConsumerBaseV2, Ownable {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; 
    VRFCoordinatorV2Interface public COORDINATOR;

    // chainlink data
    uint64 s_subscriptionId;
    bytes32 public keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 public callbackGasLimit = 400000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 2;

    mapping(uint256 => bytes32) public tokenHash;
    mapping(uint256 => uint256) public tokenToRequest;
    mapping(uint256 => uint256) public requestToToken;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    address gencore;
    INextGenCore public gencoreContract;
    INextGenAdmins private adminsContract;

    constructor(uint64 subscriptionId, address vrfCoordinator, address _gencore, address _adminsContract) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        gencore = _gencore;
        gencoreContract = INextGenCore(_gencore);
        adminsContract = INextGenAdmins(_adminsContract);
    }

    modifier FunctionAdminRequired(bytes4 _selector) {
      require(adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true , "Not allowed");
      _;
    }

    function requestRandomWords(uint256 tokenid) public returns (uint256 requestId) {
        require(msg.sender == gencore);
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,  
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        tokenToRequest[tokenid] = requestId;
        requestToToken[requestId] = tokenid;
        return (requestId);
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        tokenHash[requestToToken[_requestId]] = keccak256(abi.encodePacked(_randomWords));
        gencoreContract.setTokenHash(requestToToken[_requestId], tokenHash[requestToToken[_requestId]]);
        emit RequestFulfilled(_requestId, _randomWords);
    }

    // function that calculates the random hash and returns it to the gencore contract
    function calculateTokenHash(uint256 _mintIndex, uint256 _saltfun_o) public {
        require(msg.sender == gencore);
        requestRandomWords(_mintIndex);
    }

    // function to update callbackGasLimit & keyHash

    function updatecallbackGasLimitAndkeyHash(uint32 _callbackGasLimit, bytes32 _keyHash) public FunctionAdminRequired(this.updatecallbackGasLimitAndkeyHash.selector){
        callbackGasLimit = _callbackGasLimit;
        keyHash = _keyHash;
    }

    // function to change the requests other data

    function updateAdditionalData(uint64 _s_subscriptionId, uint32 _numWords, uint16 _requestConfirmations) public FunctionAdminRequired(this.updateAdditionalData.selector){
        s_subscriptionId = _s_subscriptionId;
        numWords = _numWords;
        requestConfirmations = _requestConfirmations;
    }

     // function to update admin contract

    function updateAdminContract(address _newadminsContract) public FunctionAdminRequired(this.updateAdminContract.selector) {
        require(INextGenAdmins(_newadminsContract).isAdminContract() == true, "Contract is not Admin");
        adminsContract = INextGenAdmins(_newadminsContract);
    }

    // get randomizer contract status
    function isRandomizerContract() external view returns (bool) {
        return true;
    }

    // functions to get requests data

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function getRequestWords(uint256 _requestId) external view returns (uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.randomWords);
    }
}