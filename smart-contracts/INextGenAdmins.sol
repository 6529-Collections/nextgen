// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface INextGenAdmins {

    // function to retrieve global or collection admins
    function retrieveAdmin(address _address, uint256 _collectionID) external view returns(bool);

    // retrieve global admin
    function retrieveGlobalAdmin(address _address) external view returns(bool);

    // retrieve collection admin
    function retrieveCollectionAdmin(address _address, uint256 _collectionID) external view returns(bool);

    // retrieve function admin
    function retrieveFunctionAdmin(address _address, bytes4 _selector) external view returns(bool);

}