// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Admin Contract
 *  @date: 22-August-2023 
 *  @version: 1.0
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

    constructor(address _del) {
        adminPermissions[msg.sender] = true;
        dmc = IDelegationManagementContract(_del);
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

    // function to register a collection admin

    function registerCollectionAdmin(uint256 _collectionID, address _address, bool _status) public AdminRequired {
        require(_collectionID > 0, "Collection Id must be larger than 0");
        collectionAdmin[_address][_collectionID] = _status;
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

    // function to register a global admin via nftdelegation

    function registerAdminWithDelegation(address _delegator, address _admin, bool _status) public {
        bool isAllowed;
        isAllowed = dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x8888888888888888888888888888888888888888, msg.sender, 1);
        require(isAllowed == true, "Not allowed");
        require(_delegator == owner(), "Delegator is not owner");
        adminPermissions[_admin] = _status;
    } 

    // function to register a collection admin via nftdelegation

    function registerCollectionAdminWithDelegation(address _delegator, uint256 _collectionID, address _address, bool _status) public {
        bool isAllowed;
        isAllowed = dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x8888888888888888888888888888888888888888, msg.sender, 1);
        require(isAllowed == true, "Not allowed");
        require(adminPermissions[_delegator] == true, "Delegator is not an admin");
        require(_collectionID > 0, "Collection Id must be larger than 0");
        collectionAdmin[_address][_collectionID] = _status;
    }

    // function to retrieve global or collection admins

    function retrieveAdmin(address _address, uint256 _collectionID) public view returns(bool) {
        if (_collectionID == 0) {
            return adminPermissions[_address];
        } else if (_collectionID > 0) {
             return collectionAdmin[_address][_collectionID];
        } else {
            revert("Caller is not an Admin");
        }
    }

    // function to retrieve global admin

    function retrieveGlobalAdmin(address _address) public view returns(bool) {
        return adminPermissions[_address];
    }

    // function to retrieve collection admin

    function retrieveCollectionAdmin(address _address, uint256 _collectionID) public view returns(bool) {
        return collectionAdmin[_address][_collectionID];
    }

    // function to retrieve collection admin

    function retrieveFunctionAdmin(address _address, bytes4 _selector) public view returns(bool) {
        return functionAdmin[_address][_selector];
    }

}