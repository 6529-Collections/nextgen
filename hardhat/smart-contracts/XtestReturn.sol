// SPDX-License-Identifier: MIT

// demo contract

pragma solidity ^0.8.19;

import "./IMinterContract.sol";

contract testingReturns {
    IMinterContract private minterContract;

    constructor (address _minter) public {
        minterContract = IMinterContract(_minter);
    }

    // return primary addresses
    function returnPrimaryAddresses(uint256 _colid) public view returns (address, address, address, uint256, uint256, uint256, bool) {
        return minterContract.retrievePrimaryAddressesAndPercentages(_colid);
    }

    // return address b
    function returnSpecificAddress(uint256 _colid) public view returns (address) {
        (address a, address b, address c, uint256 d,uint256 e,uint256 f, bool q) = minterContract.retrievePrimaryAddressesAndPercentages(_colid);
        return b;
    }

    // return secondary addresses 
    function returnSecondaryAddresses(uint256 _colid) public view returns (address, address, address, uint256, uint256, uint256, bool) {
        return minterContract.retrieveSecondaryAddressesAndPercentages(_colid);
    }
}