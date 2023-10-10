// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Randomizer Contract
 *  @date: 09-October-2023 
 *  @version: 1.3
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./IXRandoms.sol";
import "./INextGenAdmins.sol";

contract NextGenRandomizer {

    IXRandoms public randoms;
    INextGenAdmins public adminsContract;

    constructor(address _randoms, address _admin) {
        randoms = IXRandoms(_randoms);
        adminsContract = INextGenAdmins(_admin);
    }

    // certain functions can only be called by a global or function admin

    modifier FunctionAdminRequired(bytes4 _selector) {
      require(adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true , "Not allowed");
      _;
    }

    // update contracts if needed

    function updateRandomsContract(address _randoms) public FunctionAdminRequired(this.updateRandomsContract.selector) {
        randoms = IXRandoms(_randoms);
    }

    function updateAdminsContract(address _admin) public FunctionAdminRequired(this.updateAdminsContract.selector) {
        adminsContract = INextGenAdmins(_admin);
    }

    // function that calculates the random hash and returns it to the gencore contract
    function calculateTokenHash(uint256 _mintIndex, address _address, uint256 _varg0) public view returns(bytes32) {
        return keccak256(abi.encodePacked(_mintIndex, blockhash(block.number - 1), _address, _varg0, tx.origin.balance, randoms.randomNumber(), randoms.randomWord()));
    }

    // get randomizer contract status
    function isRandomizerContract() external view returns (bool) {
        return true;
    }
    
}