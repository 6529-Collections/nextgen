// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Minter Contract
 *  @date: 23-August-2023 
 *  @version: 1.1
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./INextGenCore.sol";
import "./Ownable.sol";
import "./IDelegationManagementContract.sol";
import "./MerkleProof.sol";
import "./INextGenAdmins.sol";

contract MinterContract is Ownable{

    // total amount collected during minting from collections
    mapping (uint256 => uint256) public collectionTotalAmount;

    // sales Option3 timestamp of last mint
    mapping (uint256 => uint) public lastMintDate;

    // mint tokens on a specific collection after burning on other collection
    mapping (uint256 => mapping (uint256 => bool)) public burnToMintCollections;

    // sales Option3 timestamp of last mint
    mapping (uint256 => bool) public setMintingCosts;

    // collectionPhasesData struct declaration
    struct collectionPhasesDataStructure {
        uint allowlistStartTime;
        uint allowlistEndTime;
        uint publicStartTime;
        uint publicEndTime;
        bytes32 merkleRoot;
        uint256 collectionMintCost;
        uint256 collectionEndMintCost;
        uint256 timePeriod;
        uint256 rate;
        uint8 salesOption;
    }

    // mapping of collectionPhasesData struct
    mapping (uint256 => collectionPhasesDataStructure) private collectionPhases;

    // royalties primary splits structure

    struct royaltiesPrimarySplits {
        uint256 artistPercentage;
        uint256 teamPercentage;
    }

    // mapping of royaltiesPrimarySplits struct

    mapping (uint256 => royaltiesPrimarySplits) private collectionRoyaltiesPrimarySplits;

    // artists primary Addresses
    struct collectionPrimaryAddresses {
        address primaryAdd1;
        address primaryAdd2;
        address primaryAdd3;
        uint256 add1Percentage;
        uint256 add2Percentage;
        uint256 add3Percentage;
        bool status;
    }

    // mapping of collectionPrimaryAndSecondaryAddresses struct
    mapping (uint256 => collectionPrimaryAddresses) private collectionArtistAddresses;

    // royalties secondary splits structure

    struct royaltiesSecondarySplits {
        uint256 artistPercentage;
        uint256 teamPercentage;
    }

    // mapping of royaltiesSecondarySplits struct

    mapping (uint256 => royaltiesSecondarySplits) private collectionRoyaltiesSecondarySplits;

    // artists secondary Addresses
    struct collectionSecondaryAddresses {
        address secondaryAdd1;
        address secondaryAdd2;
        address secondaryAdd3;
        uint256 add1Percentage;
        uint256 add2Percentage;
        uint256 add3Percentage;
        bool status;
    }

    // mapping of collectionSecondaryAddresses struct
    mapping (uint256 => collectionSecondaryAddresses) private collectionArtistSecondaryAddresses;

    //external contracts declaration
    INextGenCore public gencore;
    IDelegationManagementContract public dmc;
    INextGenAdmins public adminsContract;

    // constructor
    constructor (address _gencore, address _del, address _adminsContract) {
        gencore = INextGenCore(_gencore);
        dmc = IDelegationManagementContract(_del);
        adminsContract = INextGenAdmins(_adminsContract);
    }

    // certain functions can only be called by an admin or the collection admin
    modifier collectionAdminOrGlobal(uint256 _collectionID) {
      require(adminsContract.retrieveCollectionAdmin(msg.sender,_collectionID) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true, "Not allowed");
      _;
    }

    // certain functions can only be called by an admin or the artist
    modifier ArtistOrAdminRequired(uint256 _collectionID, bytes4 _selector) {
      require(msg.sender == gencore.retrieveArtistAddress(_collectionID) || adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true, "Not allowed");
      _;
    }

    // certain functions can only be called by a global or function admin

    modifier FunctionAdminRequired(bytes4 _selector) {
      require(adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true , "Not allowed");
      _;
    }

    // function to add a collection's minting costs

    function setCollectionCosts(uint256 _collectionID, uint256 _collectionMintCost, uint256 _collectionEndMintCost, uint256 _rate, uint256 _timePeriod, uint8 _salesOption) public FunctionAdminRequired(this.setCollectionCosts.selector) {
        require(gencore.retrievewereDataAdded(_collectionID) == true, "Add data");
        collectionPhases[_collectionID].collectionMintCost = _collectionMintCost;
        collectionPhases[_collectionID].collectionEndMintCost = _collectionEndMintCost;
        collectionPhases[_collectionID].rate = _rate;
        collectionPhases[_collectionID].timePeriod = _timePeriod;
        collectionPhases[_collectionID].salesOption = _salesOption;
        setMintingCosts[_collectionID] = true;
    }

    // function to add a collection's start/end times and merkleroot

    function setCollectionPhases(uint256 _collectionID, uint _allowlistStartTime, uint _allowlistEndTime, uint _publicStartTime, uint _publicEndTime, bytes32 _merkleRoot) public collectionAdminOrGlobal(_collectionID) {
        require(setMintingCosts[_collectionID] == true, "Set Minting Costs");
        collectionPhases[_collectionID].allowlistStartTime = _allowlistStartTime;
        collectionPhases[_collectionID].allowlistEndTime = _allowlistEndTime;
        collectionPhases[_collectionID].merkleRoot = _merkleRoot;
        collectionPhases[_collectionID].publicStartTime = _publicStartTime;
        collectionPhases[_collectionID].publicEndTime = _publicEndTime;
    }

    // airdrop function
    
    function airDropTokens(address[] memory _recipients, string[] memory _tokenData, uint256[] memory _varg0, uint256 _collectionID, uint256[] memory _numberOfTokens) public FunctionAdminRequired(this.airDropTokens.selector) {
        require(gencore.retrievewereDataAdded(_collectionID) == true, "Add data");
        uint256 collectionTokenMintIndex;
        for (uint256 y=0; y< _recipients.length; y++) {
            collectionTokenMintIndex = gencore.viewTokensIndexMin(_collectionID) + gencore.viewCirSupply(_collectionID) + _numberOfTokens[y] - 1;
            require(collectionTokenMintIndex <= gencore.viewTokensIndexMax(_collectionID), "No supply");
            for(uint256 i = 0; i < _numberOfTokens[y]; i++) {
                uint256 mintIndex = gencore.viewTokensIndexMin(_collectionID) + gencore.viewCirSupply(_collectionID);
                gencore.airDropTokens(mintIndex, _recipients[y], _tokenData[y], _varg0[y], _collectionID);
            }
        }
    }

    // mint function

    function mint(uint256 _collectionID, uint256 _numberOfTokens, uint256 _maxAllowance, string memory _tokenData, address _mintTo, bytes32[] calldata merkleProof, address _delegator, uint256 _varg0) public payable {
        require(setMintingCosts[_collectionID] == true, "Set Minting Costs");
        uint256 col = _collectionID;
        address mintingAddress;
        uint256 phase;
        string memory tokData = _tokenData;
        if (block.timestamp >= collectionPhases[col].allowlistStartTime && block.timestamp <= collectionPhases[col].allowlistEndTime) {
            phase = 1;
            bytes32 node;
            if (_delegator != 0x0000000000000000000000000000000000000000) {
                bool isAllowedToMint;
                isAllowedToMint = dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x8888888888888888888888888888888888888888, msg.sender, 1) || dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x8888888888888888888888888888888888888888, msg.sender, 2);
                if (isAllowedToMint == false) {
                isAllowedToMint = dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x33FD426905F149f8376e227d0C9D3340AaD17aF1, msg.sender, 1) || dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x33FD426905F149f8376e227d0C9D3340AaD17aF1, msg.sender, 2);    
                }
                require(isAllowedToMint == true, "No delegation");
                node = keccak256(abi.encodePacked(_delegator, _maxAllowance, tokData));
                require(_maxAllowance >= gencore.retrieveTokensMintedALPerAddress(col, _delegator) + _numberOfTokens, "AL limit");
                mintingAddress = _delegator;
            } else {
                node = keccak256(abi.encodePacked(msg.sender, _maxAllowance, tokData));
                require(_maxAllowance >= gencore.retrieveTokensMintedALPerAddress(col, msg.sender) + _numberOfTokens, "AL limit");
                mintingAddress = msg.sender;
            }
            require(MerkleProof.verifyCalldata(merkleProof, collectionPhases[col].merkleRoot, node), 'invalid proof');
        } else if (block.timestamp >= collectionPhases[col].publicStartTime && block.timestamp <= collectionPhases[col].publicEndTime) {
            phase = 2;
            require(_numberOfTokens <= gencore.viewMaxAllowance(col), "Change no of tokens");
            require(gencore.retrieveTokensMintedPublicPerAddress(col, msg.sender) + _numberOfTokens <= gencore.viewMaxAllowance(col), "Max");
            mintingAddress = msg.sender;
            tokData = '"public"';
        } else {
            revert("No minting");
        }
        uint256 collectionTokenMintIndex;
        collectionTokenMintIndex = gencore.viewTokensIndexMin(col) + gencore.viewCirSupply(col) + _numberOfTokens - 1;
        require(collectionTokenMintIndex <= gencore.viewTokensIndexMax(col), "No supply");
        require(msg.value >= (getPrice(col) * _numberOfTokens), "Wrong ETH");
        for(uint256 i = 0; i < _numberOfTokens; i++) {
            uint256 mintIndex = gencore.viewTokensIndexMin(col) + gencore.viewCirSupply(col);
            gencore.mint(mintIndex, mintingAddress, _mintTo, tokData, _varg0, col, phase);
        }
        collectionTotalAmount[col] = collectionTotalAmount[col] + msg.value;
        // control mechanism for sale option 3
        if (collectionPhases[col].salesOption == 3) {
            uint timeOfLastMint;
            if (lastMintDate[col] == 0) {
                // for public sale set the allowlist the same time as publicsale
                timeOfLastMint = collectionPhases[col].allowlistStartTime - collectionPhases[col].timePeriod;
            } else {
                timeOfLastMint =  lastMintDate[col];
            }
            // uint calculates if period has passed in order to allow minting
            uint tDiff = (block.timestamp - timeOfLastMint) / collectionPhases[col].timePeriod;
            // users are able to mint after a day passes
            require(tDiff>=1 && _numberOfTokens == 1, "1 mint/period");
            lastMintDate[col] = block.timestamp;
        }
    }

    // burn to mint function

    function burnToMint(uint256 _burnCollectionID, uint256 _tokenId, uint256 _mintCollectionID, uint256 _varg0) public payable {
        require(burnToMintCollections[_burnCollectionID][_mintCollectionID] == true, "Initialize burn");
        require(block.timestamp >= collectionPhases[_mintCollectionID].publicStartTime && block.timestamp<=collectionPhases[_mintCollectionID].publicEndTime,"No minting");
        require ((_tokenId >= gencore.viewTokensIndexMin(_burnCollectionID)) && (_tokenId <= gencore.viewTokensIndexMax(_burnCollectionID)), "col/token id error");
        // minting new token
        uint256 collectionTokenMintIndex;
        collectionTokenMintIndex = gencore.viewTokensIndexMin(_mintCollectionID) + gencore.viewCirSupply(_mintCollectionID);
        require(collectionTokenMintIndex <= gencore.viewTokensIndexMax(_mintCollectionID), "No supply");
        require(msg.value >= getPrice(_mintCollectionID), "Wrong ETH");
        uint256 mintIndex = gencore.viewTokensIndexMin(_mintCollectionID) + gencore.viewCirSupply(_mintCollectionID);
        // burn and mint token
        address burner = msg.sender;
        gencore.burnToMint(mintIndex, _burnCollectionID, _tokenId, _mintCollectionID, _varg0, burner);
        collectionTotalAmount[_mintCollectionID] = collectionTotalAmount[_mintCollectionID] + msg.value;
    }

    // function to initialize burn

    function initializeBurn(uint256 _burnCollectionID, uint256 _mintCollectionID, bool _status) public FunctionAdminRequired(this.initializeBurn.selector) { 
        require((gencore.retrievewereDataAdded(_burnCollectionID) == true) && (gencore.retrievewereDataAdded(_mintCollectionID) == true), "No data");
        burnToMintCollections[_burnCollectionID][_mintCollectionID] = _status;
    }

    // function to set primary splits

    function setPrimarySplits(uint256 _collectionID, uint256 _artistSplit, uint256 _teamSplit) public FunctionAdminRequired(this.setPrimarySplits.selector) {
        require(_artistSplit + _teamSplit == 100, "splits need to be 100%");
        collectionRoyaltiesPrimarySplits[_collectionID].artistPercentage = _artistSplit;
        collectionRoyaltiesPrimarySplits[_collectionID].teamPercentage = _teamSplit;
    }

    // function to set secondary splits

    function setSecondarySplits(uint256 _collectionID, uint256 _artistSplit, uint256 _teamSplit) public FunctionAdminRequired(this.setSecondarySplits.selector) {
        require(_artistSplit + _teamSplit == 100, "splits need to be 100%");
        collectionRoyaltiesSecondarySplits[_collectionID].artistPercentage = _artistSplit;
        collectionRoyaltiesSecondarySplits[_collectionID].teamPercentage = _teamSplit;
    }

    // function to propose primary addresses and percentages for each address

    function proposePrimaryAddressesAndPercentages(uint256 _collectionID, address _primaryAdd1, address _primaryAdd2, address _primaryAdd3, uint256 _add1Percentage, uint256 _add2Percentage, uint256 _add3Percentage) public ArtistOrAdminRequired(_collectionID, this.proposePrimaryAddressesAndPercentages.selector) {
        require (collectionArtistAddresses[_collectionID].status == false, "Already approved");
        require (_add1Percentage + _add2Percentage + _add3Percentage <= collectionRoyaltiesPrimarySplits[_collectionID].artistPercentage, "Check %");
        collectionArtistAddresses[_collectionID].primaryAdd1 = _primaryAdd1;
        collectionArtistAddresses[_collectionID].primaryAdd2 = _primaryAdd2;
        collectionArtistAddresses[_collectionID].primaryAdd3 = _primaryAdd3;
        collectionArtistAddresses[_collectionID].add1Percentage = _add1Percentage;
        collectionArtistAddresses[_collectionID].add2Percentage = _add2Percentage;
        collectionArtistAddresses[_collectionID].add3Percentage = _add3Percentage;
        collectionArtistAddresses[_collectionID].status = false;
    }

    // function to propose secondary addresses and percentages for each address

    function proposeSecondaryAddressesAndPercentages(uint256 _collectionID, address _secondaryAdd1, address _secondaryAdd2, address _secondaryAdd3, uint256 _add1Percentage, uint256 _add2Percentage, uint256 _add3Percentage) public ArtistOrAdminRequired(_collectionID, this.proposeSecondaryAddressesAndPercentages.selector) {
        require (collectionArtistAddresses[_collectionID].status == false, "Already approved");
        require (_add1Percentage + _add2Percentage + _add3Percentage <= collectionRoyaltiesSecondarySplits[_collectionID].artistPercentage, "Check %");
        collectionArtistSecondaryAddresses[_collectionID].secondaryAdd1 = _secondaryAdd1;
        collectionArtistSecondaryAddresses[_collectionID].secondaryAdd2 = _secondaryAdd2;
        collectionArtistSecondaryAddresses[_collectionID].secondaryAdd3 = _secondaryAdd3;
        collectionArtistSecondaryAddresses[_collectionID].add1Percentage = _add1Percentage;
        collectionArtistSecondaryAddresses[_collectionID].add2Percentage = _add2Percentage;
        collectionArtistSecondaryAddresses[_collectionID].add3Percentage = _add3Percentage;
        collectionArtistSecondaryAddresses[_collectionID].status = false;
    }

    // function to accept primary addresses and percentages

    function acceptPrimaryAddressesAndPercentages(uint256 _collectionID, bool _status) public FunctionAdminRequired(this.acceptPrimaryAddressesAndPercentages.selector) {
        collectionArtistAddresses[_collectionID].status = _status;
    }

    // function to accept secondary addresses and percentages

    function acceptSecondaryAddressesAndPercentages(uint256 _collectionID, bool _status) public FunctionAdminRequired(this.acceptSecondaryAddressesAndPercentages.selector) {
        collectionArtistSecondaryAddresses[_collectionID].status = _status;
    }

    // function to pay the artist

    function payArtist(uint256 _collectionID, address _team1, address _team2, uint256 _teamperc1, uint256 _teamperc2) public FunctionAdminRequired(this.payArtist.selector) {
        require(collectionArtistAddresses[_collectionID].status == true, "Accept Royalties");
        require(collectionTotalAmount[_collectionID] > 0, "Collection Balance must be grater than 0");
        require(collectionRoyaltiesPrimarySplits[_collectionID].artistPercentage + _teamperc1 + _teamperc2 == 100, "Change percentages");
        uint256 royalties;
        uint256 artistRoyalties1;
        uint256 artistRoyalties2;
        uint256 artistRoyalties3;
        uint256 teamRoyalties1;
        uint256 teamRoyalties2;
        royalties = collectionTotalAmount[_collectionID];
        artistRoyalties1 = royalties * collectionArtistAddresses[_collectionID].add1Percentage / 100;
        artistRoyalties2 = royalties * collectionArtistAddresses[_collectionID].add2Percentage / 100;
        artistRoyalties3 = royalties * collectionArtistAddresses[_collectionID].add3Percentage / 100;
        teamRoyalties1 = royalties * _teamperc1 / 100;
        teamRoyalties2 = royalties * _teamperc2 / 100;
        payable(collectionArtistAddresses[_collectionID].primaryAdd1).transfer(artistRoyalties1);
        payable(collectionArtistAddresses[_collectionID].primaryAdd2).transfer(artistRoyalties2);
        payable(collectionArtistAddresses[_collectionID].primaryAdd3).transfer(artistRoyalties3);
        payable(_team1).transfer(teamRoyalties1);
        payable(_team2).transfer(teamRoyalties2);
        collectionTotalAmount[_collectionID] = 0;
    }

    // function to change contracts

    function updateContracts(address _gencore, address _adminsContract) public FunctionAdminRequired(this.updateContracts.selector) { 
        gencore = INextGenCore(_gencore);
        adminsContract = INextGenAdmins(_adminsContract);
    }

    // function change to admin contract

    function updateAdminContract(address _newadminsContract) public onlyOwner { 
        adminsContract = INextGenAdmins(_newadminsContract);
    }

    // function to retrieve primary splits between artist and team

    function retrievePrimarySplits(uint256 _collectionID) public view returns(uint256, uint256){
        return (collectionRoyaltiesPrimarySplits[_collectionID].artistPercentage, collectionRoyaltiesPrimarySplits[_collectionID].teamPercentage);
    }

    // function to retrieve primary addresses and percentages

    function retrievePrimaryAddressesAndPercentages(uint256 _collectionID) public view returns(address, address, address, uint256, uint256, uint256, bool){
        return (collectionArtistAddresses[_collectionID].primaryAdd1, collectionArtistAddresses[_collectionID].primaryAdd2, collectionArtistAddresses[_collectionID].primaryAdd3, collectionArtistAddresses[_collectionID].add1Percentage, collectionArtistAddresses[_collectionID].add2Percentage, collectionArtistAddresses[_collectionID].add3Percentage, collectionArtistAddresses[_collectionID].status);
    }

    // function to retrieve secondary splits between artist and team

    function retrieveSecondarySplits(uint256 _collectionID) public view returns(uint256, uint256){
        return (collectionRoyaltiesSecondarySplits[_collectionID].artistPercentage, collectionRoyaltiesSecondarySplits[_collectionID].teamPercentage);
    }

    // function to retrieve secondary addresses and percentages

    function retrieveSecondaryAddressesAndPercentages(uint256 _collectionID) public view returns(address, address, address, uint256, uint256, uint256, bool){
        return (collectionArtistSecondaryAddresses[_collectionID].secondaryAdd1, collectionArtistSecondaryAddresses[_collectionID].secondaryAdd2, collectionArtistSecondaryAddresses[_collectionID].secondaryAdd3, collectionArtistSecondaryAddresses[_collectionID].add1Percentage, collectionArtistSecondaryAddresses[_collectionID].add2Percentage, collectionArtistSecondaryAddresses[_collectionID].add3Percentage, collectionArtistSecondaryAddresses[_collectionID].status);
    }

    // function to retrieve the Collection phases times and merkle root of a collection

    function retrieveCollectionPhases(uint256 _collectionID) public view returns(uint, uint, bytes32, uint, uint){
        return (collectionPhases[_collectionID].allowlistStartTime, collectionPhases[_collectionID].allowlistEndTime, collectionPhases[_collectionID].merkleRoot, collectionPhases[_collectionID].publicStartTime, collectionPhases[_collectionID].publicEndTime);
    }

    // function to retrieve the minting details of a collection

    function retrieveCollectionMintingDetails(uint256 _collectionID) public view returns(uint256, uint256, uint256, uint256, uint8){
        return (collectionPhases[_collectionID].collectionMintCost, collectionPhases[_collectionID].collectionEndMintCost, collectionPhases[_collectionID].rate, collectionPhases[_collectionID].timePeriod, collectionPhases[_collectionID].salesOption);
    }

    // get the minting price of collection

    function getPrice(uint256 _collectionId) public view returns (uint256) {
        uint tDiff;
        if (collectionPhases[_collectionId].salesOption == 3) {
            // increase minting price by mintcost / collectionPhases[_collectionId].rate every mint (1mint/period)
            // to get the price rate needs to be set
            if (collectionPhases[_collectionId].rate > 0) {
                return collectionPhases[_collectionId].collectionMintCost + ((collectionPhases[_collectionId].collectionMintCost / collectionPhases[_collectionId].rate) * gencore.viewCirSupply(_collectionId));
            } else {
                return collectionPhases[_collectionId].collectionMintCost;
            }
        } else if (collectionPhases[_collectionId].salesOption == 2 && block.timestamp > collectionPhases[_collectionId].allowlistStartTime && block.timestamp < collectionPhases[_collectionId].publicEndTime){
            // decreases exponentially every time period
            // collectionPhases[_collectionId].timePeriod sets the time period for decreasing the mintcost
            // if just public mint set the publicStartTime = allowlistStartTime
            // if rate = 0 exponetialy decrease
            // if rate is set the linear decrase each period per rate
            tDiff = (block.timestamp - collectionPhases[_collectionId].allowlistStartTime) / collectionPhases[_collectionId].timePeriod;
            uint256 price;
            uint256 decreaserate;
            if (collectionPhases[_collectionId].rate == 0) {
                price = collectionPhases[_collectionId].collectionMintCost / (tDiff + 1);
                decreaserate = ((price - (collectionPhases[_collectionId].collectionMintCost / (tDiff + 2))) / collectionPhases[_collectionId].timePeriod) * ((block.timestamp - (tDiff * collectionPhases[_collectionId].timePeriod) - collectionPhases[_collectionId].allowlistStartTime));
            } else {
                if (((collectionPhases[_collectionId].collectionMintCost - collectionPhases[_collectionId].collectionEndMintCost) / (collectionPhases[_collectionId].rate)) > tDiff) {
                    price = collectionPhases[_collectionId].collectionMintCost - (tDiff * collectionPhases[_collectionId].rate);
                } else {
                    price = collectionPhases[_collectionId].collectionEndMintCost;
                }
            }
            if (price - decreaserate > collectionPhases[_collectionId].collectionEndMintCost) {
                return price - decreaserate; 
            } else {
                return collectionPhases[_collectionId].collectionEndMintCost;
            }
        } else {
            // fixed price
            return collectionPhases[_collectionId].collectionMintCost;
        }
    }

    // get minter status

    function isMinterContract() external view returns (bool) {
        return true;
    }

}