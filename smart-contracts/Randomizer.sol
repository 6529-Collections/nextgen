// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Randomizer Contract
 *  @date: 11-October-2023 
 *  @version: 1.4
 *  @author: 6529 team
 */

pragma solidity ^0.8.7;

import "./VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2.sol";
import "./Ownable.sol";
import "./INextGenCore.sol";

contract NextGenRandomizerVRF is VRFConsumerBaseV2, Ownable {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface public COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 400000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // Retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 2;

    address gencore;

    INextGenCore public gencoreContract;

    /**
     * HARDCODED FOR GOERLI
     * COORDINATOR: 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D
     */

    constructor(uint64 subscriptionId, address vrfCoordinator, address _gencore) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        gencore = _gencore;
        gencoreContract = INextGenCore(_gencore);
    }

    mapping(uint256 => bytes32) public tokenHash;
    mapping(uint256 => uint256) public tokenRequest;
    mapping(uint256 => uint256) public RequestToken;

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords(uint256 tokenid) public returns (uint256 requestId) {
        require(msg.sender == gencore);
        // Will revert if subscription is not set and funded.
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
        tokenRequest[tokenid] = requestId;
        RequestToken[requestId] = tokenid;
        return (requestId);
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        tokenHash[RequestToken[_requestId]] = keccak256(abi.encodePacked(_randomWords));
        gencoreContract.setTokenHash(RequestToken[_requestId], tokenHash[RequestToken[_requestId]]);
        emit RequestFulfilled(_requestId, _randomWords);
    }

    // function that calculates the random hash and returns it to the gencore contract
    function calculateTokenHash(uint256 _mintIndex) public {
        require(msg.sender == gencore);
        requestRandomWords(_mintIndex);
    }

    // get randomizer contract status
    function isRandomizerContract() external view returns (bool) {
        return true;
    }

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