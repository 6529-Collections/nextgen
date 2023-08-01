// SPDX-License-Identifier: MIT

/**
 *
 *  @title: NextGen Smart Contract
 *  @date: 01-August-2023 
 *  @version: 10.17
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Strings.sol";
import "./Base64.sol";
import "./IDelegationManagementContract.sol";
import "./MerkleProof.sol";


contract NextGen is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    uint256 public newCollectionIndex;

    // collectionInfo struct declaration

    struct collectionInfoStructure {
        string collectionName;
        string collectionArtist;
        string collectionDescription;
        string collectionWebsite;
        string collectionLicense;
        string collectionBaseURI;
        string collectionLibrary;
        string[] collectionScript;
    }

    // mapping of collectionInfo struct

    mapping (uint256 => collectionInfoStructure) private collectionInfo;

    // collectionAdditionalData struct declaration

    struct collectionAdditonalDataStructure {
        address collectionArtistAddress;
        uint256 maxCollectionPurchases;
        uint256 collectionCirculationSupply;
        uint256 collectionTotalSupply;
        uint256 collectionSalesPercentage;
        uint256 reservedMinTokensIndex;
        uint256 reservedMaxTokensIndex;
    }

    // mapping of collectionAdditionalData struct

    mapping (uint256 => collectionAdditonalDataStructure) private collectionAdditionalData;

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

    // other mappings

    // checks if a collection was created
    mapping (uint256 => bool) private isCollectionCreated; 

    // checks if data on a collection were added
    mapping (uint256 => bool) private wereDataAdded;

    // maps tokends ids with collectionsids
    mapping (uint256 => uint256) private tokenIdsToCollectionIds;

    // sets global admins
    mapping(address => bool) public adminPermissions;

    // stores randomizer hash
    mapping(uint256 => bytes32) public tokenToHash;

    // minted tokens per address per collection during public sale
    mapping (uint256 => mapping (address => uint256)) private tokensMintedPerAddress;

    // minted tokens per address per collection during allowlist
    mapping (uint256 => mapping (address => uint256)) private tokensMintedAllowlistAddress;

    // tokens airdrop per address per collection 
    mapping (uint256 => mapping (address => uint256)) private tokensAirdropPerAddress;

    // mint tokens on a specific collection after burning on other collection
    mapping (uint256 => mapping (uint256 => bool)) public burnToMintCollections;

    // current amount of burnt tokens per collection
    mapping (uint256 => uint256) private burnAmount;

    // total amount collected during minting from collections
    mapping (uint256 => uint256) public collectionTotalAmount;

    // modify the metadata view
    mapping (uint256 => bool) public onchainMetadata; 

    // collection admin
    mapping (address => mapping (uint256 => bool)) private collectionAdmin;

    // artist signature per collection
    mapping (uint256 => string) public artistsSignatures;

    // tokens additional metadata
    mapping (uint256 => string) public tokenData;

    // on-chain token Image URI
    mapping (uint256 => string) public tokenImage;

    // sales Option3 timestamp of last mint
    mapping (uint256 => uint) public lastMintDate;

    // collectionFreeze Thumbnail
    mapping (uint256 => bool) public collectionFreeze; 

    // NFTdelegation contract variable
    IDelegationManagementContract private dmc;

    // smart contract constructor
    constructor(string memory name, string memory symbol, address _delegationManagementContract) ERC721(name, symbol) {
        dmc = IDelegationManagementContract(_delegationManagementContract);
        adminPermissions[msg.sender] = true;
        newCollectionIndex = newCollectionIndex + 1;
    }

    // certain functions can only be called by an admin

    modifier AdminRequired {
      require((adminPermissions[msg.sender] == true) || (_msgSender()== owner()), "Not allowed");
      _;
   }

    // certain functions can only be called by an admin or the collection admin

    modifier collectionOrGlobalAdmin(uint256 _collectionID) {
      require((collectionAdmin[msg.sender][_collectionID] == true) || (adminPermissions[msg.sender] == true) || (_msgSender()== owner()), "Not allowed");
      _;
   }

    // function to create a Collection

    function createCollection(string memory _collectionName, string memory _collectionArtist, string memory _collectionDescription, string memory _collectionWebsite, string memory _collectionLicense, string memory _collectionBaseURI, string memory _collectionLibrary, string[] memory _collectionScript) public AdminRequired {
        collectionInfo[newCollectionIndex].collectionName = _collectionName;
        collectionInfo[newCollectionIndex].collectionArtist = _collectionArtist;
        collectionInfo[newCollectionIndex].collectionDescription = _collectionDescription;
        collectionInfo[newCollectionIndex].collectionWebsite = _collectionWebsite;
        collectionInfo[newCollectionIndex].collectionLicense = _collectionLicense;
        collectionInfo[newCollectionIndex].collectionBaseURI = _collectionBaseURI;
        collectionInfo[newCollectionIndex].collectionLibrary = _collectionLibrary;
        collectionInfo[newCollectionIndex].collectionScript = _collectionScript;
        isCollectionCreated[newCollectionIndex] = true;
        newCollectionIndex = newCollectionIndex + 1;
    }

    // function to add/modify the additional data of a collection
    // once a collection is created and total supply is set it cannot be changed
    // only _collectionArtistAddress , _maxCollectionPurchases and _collectionSalesPercentage can change after total supply is set

    function setCollectionData(uint256 _collectionID, address _collectionArtistAddress, uint256 _maxCollectionPurchases, uint256 _collectionTotalSupply, uint256 _collectionSalesPercentage) public AdminRequired {
        require((isCollectionCreated[_collectionID] == true) && (collectionFreeze[_collectionID] == false) && (_collectionTotalSupply <= 10000000000) && (_collectionSalesPercentage <= 100), "wrong/freezed");
        if (collectionAdditionalData[_collectionID].collectionTotalSupply == 0) {
            collectionAdditionalData[_collectionID].collectionArtistAddress = _collectionArtistAddress;
            collectionAdditionalData[_collectionID].maxCollectionPurchases = _maxCollectionPurchases;
            collectionAdditionalData[_collectionID].collectionCirculationSupply = 0;
            collectionAdditionalData[_collectionID].collectionTotalSupply = _collectionTotalSupply;
            collectionAdditionalData[_collectionID].collectionSalesPercentage = _collectionSalesPercentage;
            collectionAdditionalData[_collectionID].reservedMinTokensIndex = (_collectionID * 10000000000);
            collectionAdditionalData[_collectionID].reservedMaxTokensIndex = (_collectionID * 10000000000) + _collectionTotalSupply - 1;
            wereDataAdded[_collectionID] = true;
        } else {
            collectionAdditionalData[_collectionID].collectionArtistAddress = _collectionArtistAddress;
            collectionAdditionalData[_collectionID].maxCollectionPurchases = _maxCollectionPurchases;
            collectionAdditionalData[_collectionID].collectionSalesPercentage = _collectionSalesPercentage;
        }
    }

    // function to add a collection's start/end times and merkleroot

    function setCollectionPhases(uint256 _collectionID, uint _allowlistStartTime, uint _allowlistEndTime, uint _publicStartTime, uint _publicEndTime, bytes32 _merkleRoot, uint256 _collectionMintCost, uint256 _collectionEndMintCost, uint256 _rate, uint256 _timePeriod, uint8 _salesOption) public collectionOrGlobalAdmin(_collectionID) {
        require(wereDataAdded[_collectionID] == true && collectionFreeze[_collectionID] == false, "nodata/freezed");
        collectionPhases[_collectionID].allowlistStartTime = _allowlistStartTime;
        collectionPhases[_collectionID].allowlistEndTime = _allowlistEndTime;
        collectionPhases[_collectionID].merkleRoot = _merkleRoot;
        collectionPhases[_collectionID].publicStartTime = _publicStartTime;
        collectionPhases[_collectionID].publicEndTime = _publicEndTime;
        collectionPhases[_collectionID].collectionMintCost = _collectionMintCost;
        collectionPhases[_collectionID].collectionEndMintCost = _collectionEndMintCost;
        collectionPhases[_collectionID].rate = _rate;
        collectionPhases[_collectionID].timePeriod = _timePeriod;
        collectionPhases[_collectionID].salesOption = _salesOption;
    }

    // airdrop function
    
    function airDropTokens(address _recipient, string memory _tokenData, uint256 _varg0, uint256 _collectionID, uint256 _numberOfTokens) public AdminRequired {
        require(wereDataAdded[_collectionID] == true, "Add data");
        uint256 collectionTokenMintIndex;
        collectionTokenMintIndex = collectionAdditionalData[_collectionID].reservedMinTokensIndex + collectionAdditionalData[_collectionID].collectionCirculationSupply + _numberOfTokens - 1;
        require(collectionTokenMintIndex <= collectionAdditionalData[_collectionID].reservedMaxTokensIndex, "No supply");
        for(uint256 i = 0; i < _numberOfTokens; i++) {
            uint256 mintIndex = collectionAdditionalData[_collectionID].reservedMinTokensIndex + collectionAdditionalData[_collectionID].collectionCirculationSupply;
            collectionAdditionalData[_collectionID].collectionCirculationSupply = collectionAdditionalData[_collectionID].collectionCirculationSupply + 1;
            if (collectionAdditionalData[_collectionID].collectionTotalSupply >= collectionAdditionalData[_collectionID].collectionCirculationSupply) {
                tokenToHash[mintIndex] = calculateTokenHash(mintIndex, _recipient, _varg0);
                tokenData[mintIndex] = _tokenData;
                // mint token
                _safeMint(_recipient, mintIndex);
                tokenIdsToCollectionIds[mintIndex] = _collectionID;
            }
        }
        tokensAirdropPerAddress[_collectionID][_recipient] = tokensAirdropPerAddress[_collectionID][_recipient] + _numberOfTokens;
    }

    // mint function

    function mint(uint256 _collectionID, uint256 _numberOfTokens, uint256 _maxAllowance, string memory _tokenData, address _mintTo, bytes32[] calldata merkleProof, address _delegator, uint256 _varg0) public payable
    {
        if (block.timestamp >= collectionPhases[_collectionID].allowlistStartTime && block.timestamp <= collectionPhases[_collectionID].allowlistEndTime) {
            //require(_numberOfTokens <=_maxAllowance, "Check maxAllowance");
            bytes32 node;
            if (_delegator != 0x0000000000000000000000000000000000000000) {
                bool isAllowedToMint;
                isAllowedToMint = dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x8888888888888888888888888888888888888888, msg.sender, 1) || dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x8888888888888888888888888888888888888888, msg.sender, 2);
                if (isAllowedToMint == false) {
                isAllowedToMint = dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x33FD426905F149f8376e227d0C9D3340AaD17aF1, msg.sender, 1) || dmc.retrieveGlobalStatusOfDelegation(_delegator, 0x33FD426905F149f8376e227d0C9D3340AaD17aF1, msg.sender, 2);    
                }
                require(isAllowedToMint == true, "No delegation");
                node = keccak256(abi.encodePacked(_delegator, _maxAllowance, _tokenData));
                require(_maxAllowance >= tokensMintedAllowlistAddress[_collectionID][_delegator] + _numberOfTokens, "AL limit");
            } else {
                node = keccak256(abi.encodePacked(msg.sender, _maxAllowance, _tokenData));
                require(_maxAllowance >= tokensMintedAllowlistAddress[_collectionID][msg.sender] + _numberOfTokens, "AL limit");
            }
            require(MerkleProof.verifyCalldata(merkleProof, collectionPhases[_collectionID].merkleRoot, node), 'invalid proof');
        } else if (block.timestamp >= collectionPhases[_collectionID].publicStartTime && block.timestamp <= collectionPhases[_collectionID].publicEndTime) {
            require(_numberOfTokens <= collectionAdditionalData[_collectionID].maxCollectionPurchases, "Limit");
            require(tokensMintedPerAddress[_collectionID][msg.sender] + _numberOfTokens <= collectionAdditionalData[_collectionID].maxCollectionPurchases, "Max");
        } else {
            revert("No minting");
        }
        uint256 collectionTokenMintIndex;
        collectionTokenMintIndex = collectionAdditionalData[_collectionID].reservedMinTokensIndex + collectionAdditionalData[_collectionID].collectionCirculationSupply + _numberOfTokens - 1;
        require(collectionTokenMintIndex <= collectionAdditionalData[_collectionID].reservedMaxTokensIndex, "No supply");
        require(msg.value >= (getPrice(_collectionID) * _numberOfTokens), "Wrong ETH");
        for(uint256 i = 0; i < _numberOfTokens; i++) {
            uint256 mintIndex = collectionAdditionalData[_collectionID].reservedMinTokensIndex + collectionAdditionalData[_collectionID].collectionCirculationSupply;
            collectionAdditionalData[_collectionID].collectionCirculationSupply = collectionAdditionalData[_collectionID].collectionCirculationSupply + 1;
            if (collectionAdditionalData[_collectionID].collectionTotalSupply >= collectionAdditionalData[_collectionID].collectionCirculationSupply) {
                if (block.timestamp >= collectionPhases[_collectionID].allowlistStartTime && block.timestamp<=collectionPhases[_collectionID].allowlistEndTime) {
                    if (_delegator != 0x0000000000000000000000000000000000000000) {
                        tokenToHash[mintIndex] = calculateTokenHash(mintIndex, _delegator, _varg0);
                        tokenData[mintIndex] = _tokenData;
                    } else {
                        tokenToHash[mintIndex] =  calculateTokenHash(mintIndex, msg.sender, _varg0);
                        tokenData[mintIndex] = _tokenData;
                    }
                } else {
                    tokenToHash[mintIndex] =  calculateTokenHash(mintIndex, msg.sender, _varg0);
                        tokenData[mintIndex] = '"public"';
                }
                // mint token
                _safeMint(_mintTo, mintIndex);
                tokenIdsToCollectionIds[mintIndex] = _collectionID;
            }
        }
        collectionTotalAmount[_collectionID] = collectionTotalAmount[_collectionID] + msg.value;
        if (block.timestamp >= collectionPhases[_collectionID].allowlistStartTime && block.timestamp <= collectionPhases[_collectionID].allowlistEndTime) {
            if (_delegator != 0x0000000000000000000000000000000000000000) {
                tokensMintedAllowlistAddress[_collectionID][_delegator] = tokensMintedAllowlistAddress[_collectionID][_delegator] + _numberOfTokens;
            } else {
                tokensMintedAllowlistAddress[_collectionID][msg.sender] = tokensMintedAllowlistAddress[_collectionID][msg.sender] + _numberOfTokens;
            }
        } else {
            tokensMintedPerAddress[_collectionID][msg.sender] = tokensMintedPerAddress[_collectionID][msg.sender] + _numberOfTokens;
        }
        // control mechanism for sale option 3
        if (collectionPhases[_collectionID].salesOption == 3) {
            uint timeOfLastMint;
            if (lastMintDate[_collectionID] == 0) {
                // for public sale set the allowlist the same time as publicsale
                timeOfLastMint = collectionPhases[_collectionID].allowlistStartTime - collectionPhases[_collectionID].timePeriod;
            } else {
                timeOfLastMint = lastMintDate[_collectionID];
            }
            //uint calculates if period has passed in order to allow minting
            uint tDiff = (block.timestamp - timeOfLastMint) / collectionPhases[_collectionID].timePeriod;
            // users are able to mint after a day passes
            require(tDiff>=1 && _numberOfTokens == 1, "1 mint/period");
            lastMintDate[_collectionID] = block.timestamp;
        }
    }

    // Additional setter functions

    // function that sends the collected funds to the artist and the team

    function payArtist(uint256 _collectionID, address _team) public AdminRequired {
        uint256 royalties;
        uint256 artistRoyalties;
        uint256 teamRoyalites;
        royalties = collectionTotalAmount[_collectionID];
        artistRoyalties = royalties * collectionAdditionalData[_collectionID].collectionSalesPercentage / 100;
        teamRoyalites = royalties * (100 - collectionAdditionalData[_collectionID].collectionSalesPercentage) / 100;
        payable(collectionAdditionalData[_collectionID].collectionArtistAddress).transfer(artistRoyalties);
        payable(_team).transfer(teamRoyalites);
        collectionTotalAmount[_collectionID] = 0;
    }

    // function to update Collection Info

    function updateCollectionInfo(uint256 _collectionID, string memory _newCollectionName, string memory _newCollectionArtist, string memory _newCollectionDescription, string memory _newCollectionWebsite, string memory _newCollectionLicense, string memory _newCollectionLibrary, string[] memory _newCollectionScript) public AdminRequired {
        require((isCollectionCreated[_collectionID] == true) && (collectionFreeze[_collectionID] == false), "Not allowed");
        collectionInfo[_collectionID].collectionName = _newCollectionName;
        collectionInfo[_collectionID].collectionArtist = _newCollectionArtist;
        collectionInfo[_collectionID].collectionDescription = _newCollectionDescription;
        collectionInfo[_collectionID].collectionWebsite = _newCollectionWebsite;
        collectionInfo[_collectionID].collectionLicense = _newCollectionLicense;
        collectionInfo[_collectionID].collectionLibrary = _newCollectionLibrary;
        collectionInfo[_collectionID].collectionScript = _newCollectionScript;
    }

    // function to update Collection Script By Index

    function updateCollectionScriptByIndex(uint256 _collectionID, uint256 _index, string memory _newCollectionIndexScript) public AdminRequired {
        require((isCollectionCreated[_collectionID] == true) && (collectionFreeze[_collectionID] == false), "Not allowed");
        collectionInfo[_collectionID].collectionScript[_index] = _newCollectionIndexScript;
    }

    // function for artist signature

    function artistSignature(uint256 _collectionID, string memory _signature) public {
        require(msg.sender == collectionAdditionalData[_collectionID].collectionArtistAddress, "Only artist");
        artistsSignatures[_collectionID] = _signature;
    }

    // function to register admins on the smart contract

    function registerAdmin(address _admin, bool _status) public onlyOwner {
        adminPermissions[_admin] = _status;
    }

    // burn function

    function burn(uint256 _collectionID, uint256 _tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: caller is not token owner or approved");
        require ((_tokenId >= collectionAdditionalData[_collectionID].reservedMinTokensIndex) && (_tokenId <= collectionAdditionalData[_collectionID].reservedMaxTokensIndex), "id err");
        _burn(_tokenId);
        burnAmount[_collectionID] = burnAmount[_collectionID] + 1;
    }

    // burn to mint function

    function burnToMint(uint256 _burnCollectionID, uint256 _tokenId, uint256 _mintCollectionID, uint256 _varg0) public payable{
        require(burnToMintCollections[_burnCollectionID][_mintCollectionID] == true, "Initialize burn");
        require(block.timestamp >= collectionPhases[_mintCollectionID].publicStartTime && block.timestamp<=collectionPhases[_mintCollectionID].publicEndTime,"No minting");
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: caller is not token owner or approved");
        require ((_tokenId >= collectionAdditionalData[_burnCollectionID].reservedMinTokensIndex) && (_tokenId <= collectionAdditionalData[_burnCollectionID].reservedMaxTokensIndex), "id err");
        // minting new token
        uint256 collectionTokenMintIndex;
        collectionTokenMintIndex = collectionAdditionalData[_mintCollectionID].reservedMinTokensIndex + collectionAdditionalData[_mintCollectionID].collectionCirculationSupply;
        require(collectionTokenMintIndex <= collectionAdditionalData[_mintCollectionID].reservedMaxTokensIndex, "No supply");
        require(msg.value >= getPrice(_mintCollectionID), "Wrong ETH");
        uint256 mintIndex = collectionAdditionalData[_mintCollectionID].reservedMinTokensIndex + collectionAdditionalData[_mintCollectionID].collectionCirculationSupply;
        collectionAdditionalData[_mintCollectionID].collectionCirculationSupply = collectionAdditionalData[_mintCollectionID].collectionCirculationSupply + 1;
        if (collectionAdditionalData[_mintCollectionID].collectionTotalSupply >= collectionAdditionalData[_mintCollectionID].collectionCirculationSupply) {
            // generate hash
            tokenToHash[mintIndex] = calculateTokenHash(mintIndex, msg.sender, _varg0);
            tokenData[mintIndex] = string(abi.encodePacked("'burntFrom'",",",_tokenId.toString(),",",tokenData[_tokenId]));
            // mint token
            _safeMint(ownerOf(_tokenId), mintIndex);
            tokenIdsToCollectionIds[mintIndex] = _mintCollectionID;
            // burn token
            _burn(_tokenId);
            burnAmount[_burnCollectionID] = burnAmount[_burnCollectionID] + 1;
        }
        collectionTotalAmount[_mintCollectionID] = collectionTotalAmount[_mintCollectionID] + msg.value;
    }

    // function to initialize burn

    function initializeBurn(uint256 _burnCollectionID, uint256 _mintCollectionID, bool _status) public AdminRequired { 
        require((wereDataAdded[_burnCollectionID] == true) && (wereDataAdded[_mintCollectionID] == true), "No data");
        burnToMintCollections[_burnCollectionID][_mintCollectionID] = _status;
    }

    // function change metadata view 

    function changeMetadataView(uint256 _collectionID, bool _status) public AdminRequired { 
        onchainMetadata[_collectionID] = _status;
    }

    // function to change the token data

    function changeTokenData(uint256 _tokenId, string memory newData) public AdminRequired{
        require(collectionFreeze[tokenIdsToCollectionIds[_tokenId]] == false, "Data frozen");
        _requireMinted(_tokenId);
        tokenData[_tokenId] = newData;
    }
    
    // function change the status of a collection admin

    function registerCollectionAdmin(uint256 _collectionID, address _address, bool _status) public AdminRequired { 
        collectionAdmin[_address][_collectionID] = _status;
    }

    // function to update the baseuri

    function updateBaseURI(uint256 _collectionID, string memory _newCollectionBaseURI) public AdminRequired{
        require((isCollectionCreated[_collectionID] == true) && (collectionFreeze[_collectionID] == false), "Not allowed");
        collectionInfo[_collectionID].collectionBaseURI = _newCollectionBaseURI;
    }

    // function to add a thumbnail image

    function updateImages(uint256[] memory _tokenId, string[] memory _image) public AdminRequired{
        for (uint256 x; x<_tokenId.length; x++) {
            require(collectionFreeze[tokenIdsToCollectionIds[_tokenId[x]]] == false, "Data frozen");
            _requireMinted(_tokenId[x]);
            tokenImage[_tokenId[x]] = _image[x];
        }
    }

    // freeze collection

    function freezeCollection(uint256 _collectionID) public AdminRequired{
        require(isCollectionCreated[_collectionID] == true, "No Col");
        collectionFreeze[_collectionID] = true;
    }

    // Retrieve Functions

    // function to return the tokenURI

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        if (onchainMetadata[tokenIdsToCollectionIds[tokenId]] == false) {
        string memory baseURI = collectionInfo[tokenIdsToCollectionIds[tokenId]].collectionBaseURI;
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
        } else {
        string memory b64 = Base64.encode(abi.encodePacked("<html><head></head><body><script src=\"",collectionInfo[tokenIdsToCollectionIds[tokenId]].collectionLibrary,"\"></script><script>",retrieveGenerativeScript(tokenId),"</script></body></html>"));
        string memory _uri = string(abi.encodePacked("data:application/json;utf8,{\"name\":\"",tokenId.toString(),"\",\"description\":\"",collectionInfo[tokenIdsToCollectionIds[tokenId]].collectionDescription,"\",\"image\":\"",tokenImage[tokenId],"\",\"animation_url\":\"data:text/html;base64,",b64,"\"}"));
        return _uri;
        }
    }

    // function to return the token ids per collection

    function viewTokensIndexForCollection(uint256 _collectionID) public view returns (uint256, uint256) {
        return(collectionAdditionalData[_collectionID].reservedMinTokensIndex, collectionAdditionalData[_collectionID].reservedMaxTokensIndex);
    }

    // function to retrieve a Collection's Info

    function retrieveCollectionInfo(uint256 _collectionID) public view returns(string memory, string memory, string memory, string memory, string memory, string memory){
        return (collectionInfo[_collectionID].collectionName, collectionInfo[_collectionID].collectionArtist, collectionInfo[_collectionID].collectionDescription, collectionInfo[_collectionID].collectionWebsite, collectionInfo[_collectionID].collectionLicense, collectionInfo[_collectionID].collectionBaseURI);
    }

    // function to retrieve the library and script of a collection

    function retrieveCollectionLibraryAndScript(uint256 _collectionID) public view returns(string memory, string[] memory){
        return (collectionInfo[_collectionID].collectionLibrary, collectionInfo[_collectionID].collectionScript);
    }

    // function to retrieve the Additional data of a Collection

    function retrieveCollectionAdditionalData(uint256 _collectionID) public view returns(address, uint256, uint256, uint256, uint256){
        return (collectionAdditionalData[_collectionID].collectionArtistAddress, collectionAdditionalData[_collectionID].maxCollectionPurchases, collectionAdditionalData[_collectionID].collectionCirculationSupply, collectionAdditionalData[_collectionID].collectionTotalSupply, collectionAdditionalData[_collectionID].collectionSalesPercentage);
    }

    // function to retrieve the Collection phases times and merkle root of a collection

    function retrieveCollectionPhases(uint256 _collectionID) public view returns(uint, uint, bytes32, uint, uint){
        return (collectionPhases[_collectionID].allowlistStartTime, collectionPhases[_collectionID].allowlistEndTime, collectionPhases[_collectionID].merkleRoot, collectionPhases[_collectionID].publicStartTime, collectionPhases[_collectionID].publicEndTime);
    }

    // function to retrieve the minting details of a collection

    function retrieveCollectionMintingDetails(uint256 _collectionID) public view returns(uint256, uint256, uint256, uint256, uint8){
        return (collectionPhases[_collectionID].collectionMintCost, collectionPhases[_collectionID].collectionEndMintCost, collectionPhases[_collectionID].rate, collectionPhases[_collectionID].timePeriod, collectionPhases[_collectionID].salesOption);
    }

    // function to retrieve the Generative Script of a token

    function retrieveGenerativeScript(uint256 tokenId) public view returns(string memory){
        _requireMinted(tokenId);
        string memory scripttext;
        for (uint256 i=0; i < collectionInfo[tokenIdsToCollectionIds[tokenId]].collectionScript.length; i++) {
            scripttext = string(abi.encodePacked(scripttext, collectionInfo[tokenIdsToCollectionIds[tokenId]].collectionScript[i])); 
        }
        return string(abi.encodePacked("let hash='",Strings.toHexString(uint256(tokenToHash[tokenId]), 32),"';let tokenId=",tokenId.toString(),";let tokenData=[",tokenData[tokenId],"];", scripttext));
        }

    // function to retrieve the supply of a collection

    function totalSupplyOfCollection(uint256 _collectionID) public view returns (uint256) {
        return (collectionAdditionalData[_collectionID].collectionCirculationSupply - burnAmount[_collectionID]);
    }

    // function to retrieve the airdrop/minted tokens per address 

    function retrieveTokensPerAddress(uint256 _collectionID, address _address) public view returns(uint256, uint256, uint256) {
        return (tokensAirdropPerAddress[_collectionID][_address],  tokensMintedAllowlistAddress[_collectionID][_address], tokensMintedPerAddress[_collectionID][_address] );
    }

    // function to calculate tokenhash

    function calculateTokenHash(uint256 _mintIndex, address _address, uint256 _varg0) private view returns(bytes32) {
        return keccak256(abi.encodePacked(_mintIndex, blockhash(block.number - 1), _address, _varg0));
    }

    // get the minting price of collection

    function getPrice(uint256 _collectionId) public view returns (uint256) {
        uint tDiff;
        if (collectionPhases[_collectionId].salesOption == 3) {
            // increase minting price by mintcost / collectionPhases[_collectionId].rate every mint (1mint/period)
            // to get the price rate needs to be set
            if (collectionPhases[_collectionId].rate > 0) {
                return collectionPhases[_collectionId].collectionMintCost + ((collectionPhases[_collectionId].collectionMintCost / collectionPhases[_collectionId].rate) * collectionAdditionalData[_collectionId].collectionCirculationSupply);
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

}