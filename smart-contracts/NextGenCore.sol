// SPDX-License-Identifier: MIT
// function admins 
/**
 *
 *  @title: NextGen Smart Contract
 *  @date: 26-September-2023 
 *  @version: 10.20
 *  @author: 6529 team
 */

pragma solidity ^0.8.19;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Strings.sol";
import "./Base64.sol";
import "./IRandomizer.sol";
import "./INextGenAdmins.sol";
import "./IMinterContract.sol";

contract NextGenCore is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    // declare variables
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

    // other mappings

    // checks if a collection was created
    mapping (uint256 => bool) public isCollectionCreated; 

    // checks if data on a collection were added
    mapping (uint256 => bool) public wereDataAdded;

    // maps tokends ids with collectionsids
    mapping (uint256 => uint256) private tokenIdsToCollectionIds;

    // stores randomizer hash
    mapping(uint256 => bytes32) public tokenToHash;

    // minted tokens per address per collection during public sale
    mapping (uint256 => mapping (address => uint256)) private tokensMintedPerAddress;

    // minted tokens per address per collection during allowlist
    mapping (uint256 => mapping (address => uint256)) private tokensMintedAllowlistAddress;

    // tokens airdrop per address per collection 
    mapping (uint256 => mapping (address => uint256)) private tokensAirdropPerAddress;

    // current amount of burnt tokens per collection
    mapping (uint256 => uint256) public burnAmount;

    // modify the metadata view
    mapping (uint256 => bool) public onchainMetadata; 

    // artist signature per collection
    mapping (uint256 => string) public artistsSignatures;

    // tokens additional metadata
    mapping (uint256 => string) public tokenData;

    // on-chain token Image URI
    mapping (uint256 => string) public tokenImage;

    // collectionFreeze Thumbnail
    mapping (uint256 => bool) private collectionFreeze;

    // artist signed
    mapping (uint256 => bool) public artistSigned; 

    // external contracts declaration
    IRandomizer public randomizer;
    INextGenAdmins public adminsContract;
    address public minterContract;

    // smart contract constructor
    constructor(string memory name, string memory symbol, address _randomizer, address _adminsContract) ERC721(name, symbol) {
        adminsContract = INextGenAdmins(_adminsContract);
        randomizer = IRandomizer(_randomizer);
        newCollectionIndex = newCollectionIndex + 1;
    }

    // certain functions can only be called by a global or function admin

    modifier FunctionAdminRequired(bytes4 _selector) {
      require(adminsContract.retrieveFunctionAdmin(msg.sender, _selector) == true || adminsContract.retrieveGlobalAdmin(msg.sender) == true , "Not allowed");
      _;
    }

    // function to create a Collection

    function createCollection(string memory _collectionName, string memory _collectionArtist, string memory _collectionDescription, string memory _collectionWebsite, string memory _collectionLicense, string memory _collectionBaseURI, string memory _collectionLibrary, string[] memory _collectionScript) public FunctionAdminRequired(this.createCollection.selector) {
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
    // only _collectionArtistAddress , _maxCollectionPurchases can change after total supply is set

    function setCollectionData(uint256 _collectionID, address _collectionArtistAddress, uint256 _maxCollectionPurchases, uint256 _collectionTotalSupply) public FunctionAdminRequired(this.setCollectionData.selector) {
        require((isCollectionCreated[_collectionID] == true) && (collectionFreeze[_collectionID] == false) && (_collectionTotalSupply <= 10000000000), "wrong/freezed");
        if (collectionAdditionalData[_collectionID].collectionTotalSupply == 0) {
            collectionAdditionalData[_collectionID].collectionArtistAddress = _collectionArtistAddress;
            collectionAdditionalData[_collectionID].maxCollectionPurchases = _maxCollectionPurchases;
            collectionAdditionalData[_collectionID].collectionCirculationSupply = 0;
            collectionAdditionalData[_collectionID].collectionTotalSupply = _collectionTotalSupply;
            collectionAdditionalData[_collectionID].reservedMinTokensIndex = (_collectionID * 10000000000);
            collectionAdditionalData[_collectionID].reservedMaxTokensIndex = (_collectionID * 10000000000) + _collectionTotalSupply - 1;
            wereDataAdded[_collectionID] = true;
        } else if (artistSigned[_collectionID] == false) {
            collectionAdditionalData[_collectionID].collectionArtistAddress = _collectionArtistAddress;
            collectionAdditionalData[_collectionID].maxCollectionPurchases = _maxCollectionPurchases;
        } else {
            collectionAdditionalData[_collectionID].maxCollectionPurchases = _maxCollectionPurchases;
        }
    }

    // airdrop called from minterContract
    
    function airDropTokens(uint256 mintIndex, address _recipient, string memory _tokenData, uint256 _varg0, uint256 _collectionID) external {
        require(msg.sender == minterContract, "Caller is not the Minter Contract");
        collectionAdditionalData[_collectionID].collectionCirculationSupply = collectionAdditionalData[_collectionID].collectionCirculationSupply + 1;
        if (collectionAdditionalData[_collectionID].collectionTotalSupply >= collectionAdditionalData[_collectionID].collectionCirculationSupply) {
            tokenToHash[mintIndex] = randomizer.calculateTokenHash(mintIndex, _recipient, _varg0);
            tokenData[mintIndex] = _tokenData;
            // mint token
            _safeMint(_recipient, mintIndex);
            tokenIdsToCollectionIds[mintIndex] = _collectionID;
            tokensAirdropPerAddress[_collectionID][_recipient] = tokensAirdropPerAddress[_collectionID][_recipient] + 1;
        }
    }

    // mint called from minterContract

    function mint(uint256 mintIndex, address _mintingAddress , address _mintTo, string memory _tokenData, uint256 _varg0, uint256 _collectionID, uint256 phase) external {
        require(msg.sender == minterContract, "Caller is not the Minter Contract");
        collectionAdditionalData[_collectionID].collectionCirculationSupply = collectionAdditionalData[_collectionID].collectionCirculationSupply + 1;
        if (collectionAdditionalData[_collectionID].collectionTotalSupply >= collectionAdditionalData[_collectionID].collectionCirculationSupply) {
            tokenToHash[mintIndex] = randomizer.calculateTokenHash(mintIndex, _mintingAddress, _varg0);
            tokenData[mintIndex] = _tokenData;
            // mint token
            _safeMint(_mintTo, mintIndex);
            tokenIdsToCollectionIds[mintIndex] = _collectionID;
            if (phase == 1) {
                tokensMintedAllowlistAddress[_collectionID][_mintingAddress] = tokensMintedAllowlistAddress[_collectionID][_mintingAddress] + 1;
            } else {
                tokensMintedPerAddress[_collectionID][_mintingAddress] = tokensMintedPerAddress[_collectionID][_mintingAddress] + 1;
            }
        }
    }

    // burn function

    function burn(uint256 _collectionID, uint256 _tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: caller is not token owner or approved");
        require ((_tokenId >= collectionAdditionalData[_collectionID].reservedMinTokensIndex) && (_tokenId <= collectionAdditionalData[_collectionID].reservedMaxTokensIndex), "id err");
        _burn(_tokenId);
        burnAmount[_collectionID] = burnAmount[_collectionID] + 1;
    }

    // burn to mint called from minterContract

    function burnToMint(uint256 mintIndex, uint256 _burnCollectionID, uint256 _tokenId, uint256 _mintCollectionID, uint256 _varg0, address burner) external {
        require(msg.sender == minterContract, "Caller is not the Minter Contract");
        require(_isApprovedOrOwner(burner, _tokenId), "ERC721: caller is not token owner or approved");
        collectionAdditionalData[_mintCollectionID].collectionCirculationSupply = collectionAdditionalData[_mintCollectionID].collectionCirculationSupply + 1;
        if (collectionAdditionalData[_mintCollectionID].collectionTotalSupply >= collectionAdditionalData[_mintCollectionID].collectionCirculationSupply) {
            // generate hash
            tokenToHash[mintIndex] = randomizer.calculateTokenHash(mintIndex, msg.sender, _varg0);
            tokenData[mintIndex] = string(abi.encodePacked("'burntFrom'",",",_tokenId.toString(),",",tokenData[_tokenId]));
            // mint token
            _safeMint(ownerOf(_tokenId), mintIndex);
            tokenIdsToCollectionIds[mintIndex] = _mintCollectionID;
            // burn token
            _burn(_tokenId);
            burnAmount[_burnCollectionID] = burnAmount[_burnCollectionID] + 1;
        }
    }

    // Additional setter functions

    // function to update Collection Info

    function updateCollectionInfo(uint256 _collectionID, string memory _newCollectionName, string memory _newCollectionArtist, string memory _newCollectionDescription, string memory _newCollectionWebsite, string memory _newCollectionLicense, string memory _newCollectionLibrary, string[] memory _newCollectionScript) public FunctionAdminRequired(this.updateCollectionInfo.selector) {
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

    function updateCollectionScriptByIndex(uint256 _collectionID, uint256 _index, string memory _newCollectionIndexScript) public FunctionAdminRequired(this.updateCollectionScriptByIndex.selector) {
        require((isCollectionCreated[_collectionID] == true) && (collectionFreeze[_collectionID] == false), "Not allowed");
        collectionInfo[_collectionID].collectionScript[_index] = _newCollectionIndexScript;
    }

    // function for artist signature

    function artistSignature(uint256 _collectionID, string memory _signature) public {
        require(msg.sender == collectionAdditionalData[_collectionID].collectionArtistAddress, "Only artist");
        require(artistSigned[_collectionID] == false, "Already Signed");
        artistsSignatures[_collectionID] = _signature;
        artistSigned[_collectionID] = true;
    }

    // function change metadata view 

    function changeMetadataView(uint256 _collectionID, bool _status) public FunctionAdminRequired(this.changeMetadataView.selector) { 
        onchainMetadata[_collectionID] = _status;
    }

    // function to change the token data

    function changeTokenData(uint256 _tokenId, string memory newData) public FunctionAdminRequired(this.changeTokenData.selector) {
        require(collectionFreeze[tokenIdsToCollectionIds[_tokenId]] == false, "Data frozen");
        _requireMinted(_tokenId);
        tokenData[_tokenId] = newData;
    }

    // function to update the baseuri

    function updateBaseURI(uint256 _collectionID, string memory _newCollectionBaseURI) public FunctionAdminRequired(this.updateBaseURI.selector) {
        require((isCollectionCreated[_collectionID] == true) && (collectionFreeze[_collectionID] == false), "Not allowed");
        collectionInfo[_collectionID].collectionBaseURI = _newCollectionBaseURI;
    }

    // function to add a thumbnail image

    function updateImages(uint256[] memory _tokenId, string[] memory _image) public FunctionAdminRequired(this.updateImages.selector) {
        for (uint256 x; x<_tokenId.length; x++) {
            require(collectionFreeze[tokenIdsToCollectionIds[_tokenId[x]]] == false, "Data frozen");
            _requireMinted(_tokenId[x]);
            tokenImage[_tokenId[x]] = _image[x];
        }
    }

    // freeze collection

    function freezeCollection(uint256 _collectionID) public FunctionAdminRequired(this.freezeCollection.selector) {
        require(isCollectionCreated[_collectionID] == true, "No Col");
        collectionFreeze[_collectionID] = true;
    }

    // set final supply

    function setFinalSupply(uint256 _collectionID) public FunctionAdminRequired(this.setFinalSupply.selector) {
        require (block.timestamp > IMinterContract(minterContract).getEndTime(_collectionID) + 30 days, "Time has not passed");
        collectionAdditionalData[_collectionID].collectionTotalSupply = collectionAdditionalData[_collectionID].collectionCirculationSupply;
        collectionAdditionalData[_collectionID].reservedMaxTokensIndex = (_collectionID * 10000000000) + collectionAdditionalData[_collectionID].collectionTotalSupply - 1;
    }

    // function change the status of a collection admin

    function addMinterContract(address _minterContract) public FunctionAdminRequired(this.addMinterContract.selector) { 
        require(IMinterContract(_minterContract).isMinterContract() == true);
        minterContract = _minterContract;
    }

    // function change to update contracts

    function updateRandomizerContract(address _newRandomizer) public FunctionAdminRequired(this.updateRandomizerContract.selector) { 
        randomizer = IRandomizer(_newRandomizer);
    }

    // function change to update contracts

    function updateAdminContract(address _newadminsContract) public FunctionAdminRequired(this.updateAdminContract.selector) {
        adminsContract = INextGenAdmins(_newadminsContract);
    }

    // function change to admin contract

    function updateAdminContractOwner(address _newadminsContract) public onlyOwner { 
        adminsContract = INextGenAdmins(_newadminsContract);
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

    // retrieve the collection freeze status
    function collectionFreezeStatus(uint256 _collectionID) public view returns(bool){
        return collectionFreeze[_collectionID];
    }

    // function to return the collection id given a token id
    function viewColIDforTokenID(uint256 _tokenid) public view returns (uint256) {
        return(tokenIdsToCollectionIds[_tokenid]);
    }

    // retrieve if data were added
    function retrievewereDataAdded(uint256 _collectionID) external view returns(bool){
        return wereDataAdded[_collectionID];
    }

    // function to return the min index id of a collection

    function viewTokensIndexMin(uint256 _collectionID) external view returns (uint256) {
        return(collectionAdditionalData[_collectionID].reservedMinTokensIndex);
    }

    // function to return the max index id of a collection

    function viewTokensIndexMax(uint256 _collectionID) external view returns (uint256) {
        return(collectionAdditionalData[_collectionID].reservedMaxTokensIndex);
    }

    // function to return the circ supply of a collection
    function viewCirSupply(uint256 _collectionID) external view returns (uint256) {
        return(collectionAdditionalData[_collectionID].collectionCirculationSupply);
    }

    // function to return max allowance in public sale
    function viewMaxAllowance(uint256 _collectionID) external view returns (uint256) {
        return(collectionAdditionalData[_collectionID].maxCollectionPurchases);
    }

    // function to return tokens minted per address during AL
    function retrieveTokensMintedALPerAddress(uint256 _collectionID, address _address) external view returns(uint256) {
        return (tokensMintedAllowlistAddress[_collectionID][_address]);
    }

    // function to return tokens minted per address during Public
    function retrieveTokensMintedPublicPerAddress(uint256 _collectionID, address _address) external view returns(uint256) {
        return (tokensMintedPerAddress[_collectionID][_address]);
    }

    // function to return the artist's address
    function retrieveArtistAddress(uint256 _collectionID) external view returns(address) {
        return (collectionAdditionalData[_collectionID].collectionArtistAddress);
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

    function retrieveCollectionAdditionalData(uint256 _collectionID) public view returns(address, uint256, uint256, uint256){
        return (collectionAdditionalData[_collectionID].collectionArtistAddress, collectionAdditionalData[_collectionID].maxCollectionPurchases, collectionAdditionalData[_collectionID].collectionCirculationSupply, collectionAdditionalData[_collectionID].collectionTotalSupply);
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

    // get Selector

    function getSelector(string calldata _func) public pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

}