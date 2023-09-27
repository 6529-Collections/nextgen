// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Admin Contract
 *  @date: 26-September-2023 
 *  @version: 1.1
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./Ownable.sol";
import "./IDelegationManagementContract.sol";

contract NextGenAdmins is Ownable{

    // sets global admins
    mapping(address => bool) public adminPermissions;

    // sets collection admins
    mapping (address => mapping (uint256 => bool)) private collectionAdmin;

    // sets permission on specific function
    mapping (address => mapping (bytes4 => bool)) private functionAdmin;

    // nftdelegation management contract
    IDelegationManagementContract public dmc;

    constructor() {
        adminPermissions[msg.sender] = true;
    }

    // certain functions can only be called by an admin
    modifier AdminRequired {
      require((adminPermissions[msg.sender] == true) || (_msgSender()== owner()), "Not allowed");
      _;
    }

    // function to register a global admin

    function registerAdmin(address _admin, bool _status) public onlyOwner {
        adminPermissions[_admin] = _status;
    }

    // function to register function admin

    function registerFunctionAdmin(address _address, bytes4 _selector, bool _status) public AdminRequired {
        functionAdmin[_address][_selector] = _status;
    }

    // function to register batch functions admin

    function registerBatchFunctionAdmin(address _address, bytes4[] memory _selector, bool _status) public AdminRequired {
        for (uint256 i=0; i<_selector.length; i++) {
            functionAdmin[_address][_selector[i]] = _status;
        }
    }

    // function to retrieve global admin

    function retrieveGlobalAdmin(address _address) public view returns(bool) {
        return adminPermissions[_address];
    }

    // function to retrieve collection admin

    function retrieveFunctionAdmin(address _address, bytes4 _selector) public view returns(bool) {
        return functionAdmin[_address][_selector];
    }

    // get admin contract status

    function isAdminContract() external view returns (bool) {
        return true;
    }

}