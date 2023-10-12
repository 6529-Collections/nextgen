// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Randomizer Contract RNG
 *  @date: 12-October-2023
 *  @version: 1.5
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./ArrngConsumer.sol";
import "./Ownable.sol";
import "./INextGenCore.sol";
import "./INextGenAdmins.sol";

contract NextGenRandomizerRNG is ArrngConsumer, Ownable {

    mapping(uint256 => uint256) private _arrngRequestToMintIndex;
    address gencore;
    INextGenCore public gencoreContract;
    INextGenAdmins private adminsContract;
    event Withdraw(address indexed _add, bool status, uint256 indexed funds);
    uint256 ethRequired;

    constructor(address _gencore, address _adminsContract, address _arRNG) ArrngConsumer(_arRNG) {
        gencore = _gencore;
        gencoreContract = INextGenCore(_gencore);
        adminsContract = INextGenAdmins(_adminsContract);
    }

    modifier FunctionAdminRequired(bytes4 _selector) {
        require(adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true, "Not allowed");
        _;
    }

    function requestRandomWords(uint256 tokenid, uint256 _ethRequired) public payable {
         require(msg.sender == gencore);
        _arrngRequestToMintIndex[arrngController.requestRandomWords{value: _ethRequired}(1, (address(this)))] = tokenid;

    }

    function fulfillRandomWords(uint256 id, uint256[] memory numbers) internal override {
        gencoreContract.setTokenHash(_arrngRequestToMintIndex[id], bytes32(numbers[0]));
    }

    // function that calculates the random hash and returns it to the gencore contract
    function calculateTokenHash(uint256 _mintIndex, uint256 _saltfun_o) public {
        require(msg.sender == gencore);
        requestRandomWords(_mintIndex, ethRequired);
    }

    // function to update admin contract

    function updateAdminContract(address _newadminsContract) public FunctionAdminRequired(this.updateAdminContract.selector) {
        require(INextGenAdmins(_newadminsContract).isAdminContract() == true, "Contract is not Admin");
        adminsContract = INextGenAdmins(_newadminsContract);
    }

    // function to update cost

    function updateRNGCost(uint256 _ethRequired) public FunctionAdminRequired(this.updateRNGCost.selector) {
        ethRequired = _ethRequired;
    }

    // function to withdraw any balance from the smart contract

    function emergencyWithdraw() public FunctionAdminRequired(this.emergencyWithdraw.selector) {
        uint balance = address(this).balance;
        address admin = adminsContract.owner();
        (bool success, ) = payable(admin).call{value: balance}("");
        emit Withdraw(msg.sender, success, balance);
    }

    receive() external payable {}

    // get randomizer contract status
    function isRandomizerContract() external view returns (bool) {
        return true;
    }
}
