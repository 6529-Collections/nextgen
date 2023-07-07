# NextGen Smart Contract - Setter Functions
[How to create a Collection?](#createCollection)\
[How to add data on a Collection?](#addCollectionData)\
[How to set various collection minting phases?](#setCollectionPhases)\
[How to modify the minting status of a collection?](#mintingStatus)\
[How to airdrop tokens?](#airdrop)\
[How to mint tokens?](#minting)\
[How to send the collected funds to the Artist?](#payArist)\
[How artists can sign their collections?](#artistSign)\
[How a collection can be locked?](#freezeCollection)\
[How to register a global admin on the smart contract?](#globalAdmin)\
[How to register a collection admin on the smart contract?](#collectionAdmin)\
[How to modify the metadata view of a collection?](#metadataView)\
[How to modify the on-chain token data of an existing token id?](#changeTokenData)\
[How to burn an existing token id?](#tokenBurn)\
[How to initiliaze the burn to mint functionality?](#initiliazeburnToMint)\
[How to burn an existing token and mint a new one?](#burnToMint)\
[How to update the info of a Collection?](#updateCollectionInfo)\
[How to update the script of a Collection using an index?](#updateCollectionScriptByIndex)\
[How to update the additional data already set for a collection?](#updateCollectionAdditionalData)
[How to update a collection's baseURI](#updateBaseURI)
[How to update the imageURI of a specific token for on-chain purposes?](#updateImages)

<div id='createCollection'/>

### How to create a Collection?

<b>Purpose:</b> The <i>createCollection(..)</i> function is used to create a new collection on the NextGen smart contract.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* Once the function is executed the smart contract autoassigns an id to the newly created collection.
* The admin needs to add the additional data for the newly created collection to be able to start the minting process.

<!-- end of the list -->

    /**
      * @dev Create a new NextGen collection.
      * @param _collectionName Refers to the collection name.
      * @param _collectionArtist Refers to the artist's full name.
      * @param _collectionDescription Refers to the short description of the collection.
      * @param _collectionWebsite Refers to the collection website.
      * @param _collectionLicense Refers to the collection license, ex. CC0.
      * @param _collectionBaseURI Refers to the collection BaseURI.
      * @param _collectionLibrary Refers to the library used to create the art.
      * @param _collectionScript Refers to the generative script of the collection.
    */
 
    function createCollection(
      string memory _collectionName,
      string memory _collectionArtist,
      string memory _collectionDescription,
      string memory _collectionWebsite,
      string memory _collectionLicense,
      string memory _collectionBaseURI,
      string memory _collectionLibrary,
      string memory _collectionScript
    ) public AdminRequired;

<div id='addCollectionData'/>

### How to add data on a Collection?

<b>Purpose:</b> The <i>addCollectionData(..)</i> function allows an admin to add the additional data for a Collection such as mintcost, max public purchases, total supply etc.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* Once the function is executed the smart contract reserves the min and max indices for the collection.
* The collection's circulating supply starts at 0.
* An admin needs to set the minting phases for a specific collection to start the minting process.

<!-- end of the list -->

    /**
      * @dev Add data for a new NextGen collection.
      * @param _collectionID Refers to the collection id for which the data will be added.
      * @param _collectionArtistAddress Refers to the artist's ETH public address.
      * @param _collectionMintCost Refers to the mint cost of the collection.
      * @param _maxCollectionPurchases Refers to the collection's max purchases/mints during public minting.
      * @param _collectionTotalSupply Refers to the collection's total supply.
      * @param _collectionSalesPercentage Refers to % of the summed minting sale that will be sent to the artist.
    */
 
    function addCollectionData(
      uint256 _collectionID,
      address _collectionArtistAddress,
      uint256 _collectionMintCost,
      uint256 _maxCollectionPurchases,
      uint256 _collectionTotalSupply,
      uint256 _collectionSalesPercentage
    ) public AdminRequired;

<div id='setCollectionPhases'/>

### How to set the various collection minting phases?

<b>Purpose:</b> The <i>setCollectionPhases(..)</i> function allows an admin to set the start and endtimes for allowlist and public minting. For the allowlist minting an admin needs to set also the MerkleRoot that will be used for verification purposes when the allowlist minting is active.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator or a collection administrator.
* This is the final step for setting up a collection.

<!-- end of the list -->

    /**
      * @dev Set the various collection phases.
      * @param _collectionID Refers to the collection id for which the start and endtimes will be set.
      * @param _allowlistStartTime Refers to the allowlist start time in UNIX epoch.
      * @param _allowlistEndTime Refers to the allowlist end time in UNIX epoch.
      * @param _publicStartTime Refers to the public minting start time in UNIX epoch.
      * @param _publicEndTime Refers to the public minting end time in UNIX epoch.
      * @param _merkleRoot Refers to the Merkle Root that will be used for the allowlist minting.
    */
 
    function setCollectionPhases(
      uint256 _collectionID,
      uint256 _allowlistStartTime,
      uint256 _allowlistEndTime,
      uint256 _publicStartTime,
      uint256 _publicEndTime,
      bytes32 _merkleRoot
    ) public collectionOrGlobalAdmin(_collectionID);

<div id='mintingStatus'/>

### How to modify the minting status of a collection?

<b>Purpose:</b> The <i>changeCollectionMintStatus(..)</i> function allows an admin to enable/disable the minting process of a collection.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* Minting is active once the collection phases are set.

<!-- end of the list -->

    /**
      * @dev Set the minting status of a collection.
      * @param _collectionID Refers to the collection id for which the minting status will be altered.
      * @param _status Refers to minting status, if true == minting is active, otherwise minting is not enabled.
    */
 
    function changeCollectionMintStatus(
      uint256 _collectionID,
      bool _status,
    ) public AdminRequired;

<div id='airdrop'/>

### How to airdrop tokens?

<b>Purpose:</b> The <i>airDropTokens(..)</i> function allows an admin to aidrop tokens of a specific collection to a list of recipients.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* An admin can only airdrops tokens of the same collection.
* For each recipient the admin needs to insert also the additional token data.

<!-- end of the list -->

    /**
      * @dev Aidrop tokens of a specific collection to a list of recipients.
      * @param _recipients Refers to the list of recipients who will receive the airdrop.
      * @param _tokenData Refers to a list that contains the additional token data that we store on-chain for each airdropped token.
      * @param _collectionID Refers to the collection for which the admin initiates the airdrop.
      * @param _numberOfTokens Refers to the number of tokens that will be airdroped.    
    */
 
    function airDropTokens(
      address[] memory _recipients,
      string[] memory _tokenData,
      uint256 _collectionID,
      uint256 _numberOfTokens
    ) public AdminRequired;

<div id='minting'/>

### How to mint tokens?

<b>Purpose:</b> The <i>mint(..)</i> function is used for minting new tokens.

<b>Notes:</b> 
* This is a public function.
* The function supports both allowlist and/or public minting phases.
* The function supports allowlist minting on behalf of a delegator.
* For allowlist minting the max allowance spots, the additional token data as well as the merkle proofs need to be inserted as inputs when executing the transaction.

<!-- end of the list -->

    /**
      * @dev Mint new tokens during allowlist or public minting.
      * @param _collectionID Refers to collection for whcih the tokens will be minted.
      * @param _numberOfTokens Refers to the number of tokens that will be minted. This number should be less than the max allowance
        during allowlist minting or less than the _maxCollectionPurchases during public minting.
      * @param _maxAllowance Refers to the max allowance per wallet during allowlist minting. For public minting this value is 0.
      * @param _tokenData Refers to the additional token data that will be stored on-chain for each minted token.
      * @param _mintTo Refers to the address that the token will be minted to.
      * @param merkleProof Refers to the set of hashes that can be used to prove a given leaf's membership in the merkle tree.
      * @param _delegator Refers to the delegator address during allowlist minting. If the minter will mint on his behalf the _delegator value
        is set to 0x0000000000000000000000000000000000000000, otherwise the delegator's address needs to be provided.
    */
 
    function mint(
      uint256 _collectionID,
      uint256 _numberOfTokens,
      uint256 _maxAllowance,
      string _tokenData,
      address _mintTo,
      bytes32[] calldata merkleProof
    ) public payable;

<div id='payArist'/>

### How to send the collected funds to the Artist?

<b>Purpose:</b> The <i>payArtist(..)</i> function is used to send the funds collected during minting.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* The function sends the collected funds to the artist's address based on the Sales Percentage set when adding the additional data for a collection.
* The function sends the team's share to the contract's owner wallet.

<!-- end of the list -->

    /**
      * @dev Send funds collected during minting to the Artist and the Team.
      * @param _collectionID Refers to collection for which the collected funds will be sent.
    */
 
    function payArtist(
      uint256 _collectionID,
    ) AdminRequired;

<div id='artistSign'/>

### How artists can sign their collections?

<b>Purpose:</b> The <i>artistSignature(..)</i> function is used by the artists to sign the collections that they have created.

<b>Notes:</b> 
* This function can only be called by an artist.
* The artist ETH public address needs to be assigned when adding the collection's additional data.

<!-- end of the list -->

    /**
      * @dev Artists sign their own collections.
      * @param _collectionID Refers to the collection for which an artist is allowed to add his signature.
      * @param _signature Refers to written text/signature of the artist that will be stored on-chain.
    */
 
    function artistSignature(
      uint256 _collectionID,
      string memory _signature
    ) public;

<div id='freezeCollection'/>

### How a collection can be locked?

<b>Purpose:</b> The <i>freezeCollection(..)</i> function is used to lock the information, data and metadata of a collection for ever.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* The collection should exist.
* Once executed the collection's freeze status becomes true and cannot be altered.

<!-- end of the list -->

    /**
      * @dev Lock a collection.
      * @param _collectionID Refers to the collection for which its data will be locked.
    */
 
    function freezeCollection(
      uint256 _collectionID
    ) AdminRequired;

<div id='globalAdmin'/>

### How to register a global admin on the smart contract?

<b>Purpose:</b> The <i>registerAdmin(..)</i> function is used to register global admins on the smart contract.

<b>Notes:</b> 
* This function can be called by the contract deployer.

<!-- end of the list -->

    /**
      * @dev Register a global admin.
      * @param _admin Refers to the ETH public address of an admin.
      * @param _status Refers to the status of a global admin, if true the ETH address is registered as a global admin, otherwise it's not registered.
    */
 
    function registerAdmin(
      address _admin,
      bool _status
    ) onlyOwner;

<div id='collectionAdmin'/>

### How to register a collection admin on the smart contract?

<b>Purpose:</b> The <i>registerCollectionAdmin(..)</i> function is used for registering collection admins on the smart contract.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* Collection admins can just set the various minting phases.

<!-- end of the list -->

    /**
      * @dev Register an admin on a specific collection.
      * @param _collectionID Refers to the collection for which an admin will be registered.
      * @param _address Refers to the ETH public address of the admin.
      * @param _status Refers to the status of a collection admin, if true the ETH address is registered as a collection admin, otherwise it's not registered.
    */
 
    function registerCollectionAdmin(
      uint256 _collectionID,
      address _address,
      bool _status
    ) AdminRequired;

<div id='metadataView'/>

### How to modify the metadata view of a collection?

<b>Purpose:</b> The <i>changeMetadataView(..)</i> function is used for changing how the metadata of a collection will be displayed when the <i>tokenURI()</i> function is called.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* If onMetadata is set, collection's metadata are retrieved directly from on-chain data, otherwise the metadata are returned by using a .json file stored on a distributed storage ex. ipfs.

<!-- end of the list -->

    /**
      * @dev Change the metadata view for a collection.
      * @param _collectionID Refers to the collection for which the metadata view will be modified.
      * @param _status Refers to the metadata view status of a collection, if true the tokenURI() function will return the metadata of a token id directly from on-chain, 
        otherwise it will return the tokenURI as a URI.
    */
 
    function changeMetadataView(
      uint256 _collectionID,
      bool _status
    ) AdminRequired;

<div id='changeTokenData'/>

### How to modify the on-chain token data of an existing token id?

<b>Purpose:</b> The <i>changeTokenData(..)</i> function is used to modify the token data of an already existing token.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* The collection should not be frozen.

<!-- end of the list -->

    /**
      * @dev Change the token data of an existing token.
      * @param _tokenId Refers to the existing token for which the token data will be modified.
      * @param newData Refers to the updated token data that will replace the existing ones.
    */
 
    function changeTokenData(
      uint256 _tokenId,
      string memory newData
    ) AdminRequired;

<div id='tokenBurn'/>

### How to burn an existing token id?

<b>Purpose:</b> The <i>burn(..)</i> function is used to burn an existing token id.

<b>Notes:</b> 
* This function can only be called by the owner of a token, or an approved address.

<!-- end of the list -->

    /**
      * @dev Burn an existing token id.
      * @param _collectionId Refers to the collection for which the token will be burnt.
      * @param _tokenId Refers to the existing token that will be burnt.
    */
 
    function burn(
      uint256 _collectionId,
      uint256 _tokenId
    ) public;


<div id='initiliazeburnToMint'/>

### How to initiliaze the burn to mint functionality?

<b>Purpose:</b> The <i>initializeBurn(..)</i> function is used to initiliaze the burn to mint functionality.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.

<!-- end of the list -->

    /**
      * @dev Initiliaze the burn to mint functionality.
      * @param _burnCollectionID Refers to the collection for which a token will be burnt.
      * @param _mintCollectionID Refers to the collection for which a new token will be minted.
      * @param _status Refers to the initilization status, if true it means that the burn to mint functionality has been initiliazed, otherwise no initilization was set yet.
    */
 
    function initializeBurn(
      uint256 _burnCollectionID,
      uint256 _mintCollectionID,
      bool _status
    ) AdminRequired;

<div id='burnToMint'/>

### How to burn an existing token and mint a new one?

<b>Purpose:</b> The <i>burnToMint(..)</i> function is used to burn an existing token and mint a new one.

<b>Notes:</b> 
* This function can only be called from a token owner or an approved adress.
* The burn to mint functionality needs to be initiliazed.

<!-- end of the list -->

    /**
      * @dev Burn an existing token and mint a new one.
      * @param _burnCollectionID Refers to the collection for which a token will be burnt.
      * @param _tokenId Refers to the token id that will be burnt.
      * @param _mintCollectionID Refers to the collection for which a new token will be minted.
    */
 
    function burnToMint(
      uint256 _burnCollectionID,
      uint256 _tokenId,
      uint256 _mintCollectionID
    ) public payable;

<div id='updateCollectionInfo'/>

### How to update the info of a Collection?

<b>Purpose:</b> The <i>updateCollectionInfo(..)</i> function is used to update the existing info of a collection.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.
* The collection needs to exist.
* The collection should not be frozen.

<!-- end of the list -->

    /**
      * @dev Update an existing NextGen collection.
      * @param _collectionID Refers to the collection that will be updated.
      * @param _newCollectionName Refers to the new collection name.
      * @param _newCollectionArtist Refers to the new artist's full name.
      * @param _newCollectionDescription Refers to the new description of the collection.
      * @param _newCollectionWebsite Refers to the new collection website.
      * @param _newCollectionLicense Refers to the new collection license, ex. CC0.
      * @param _newCollectionLibrary Refers to the new library used to create the art.
      * @param _newCollectionScript Refers to the new generative script of the collection.
    */
 
    function updateCollectionInfo(
      uint256 _collectionID,
      string memory _newCollectionName,
      string memory _newCollectionArtist,
      string memory _newCollectionDescription,
      string memory _newCollectionWebsite,
      string memory _newCollectionLicense,
      string memory _newCollectionLibrary,
      string memory _newCollectionScript
    ) public AdminRequired;

<div id='updateCollectionScriptByIndex'/>

### How to update the script of a Collection using an index?

<b>Purpose:</b> The <i>updateCollectionScriptByIndex(..)</i> function is used to update a specific part of a collection's script.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* The collection needs to exist.
* The collection should not be frozen.

<!-- end of the list -->

    /**
      * @dev Update an existing collection script.
      * @param _collectionID Refers to the collection for which the script will be updated.
      * @param _index Refers to the single part of the script that will be updated.
      * @param _newCollectionIndexScript Refers to updated script.
    */
 
    function updateCollectionScriptByIndex(
      uint256 _collectionID,
      uint256 _index,
      string memory _newCollectionIndexScript,
    ) public AdminRequired;

<div id='updateCollectionAdditionalData'/>

### How to update the additional data already set for a collection?

<b>Purpose:</b> The <i>updateCollectionAdditionalData(..)</i> function is used to update the additional data of an already existing collection.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* The collection needs to exist and the initial data already added.
* The total supply of a collection cannot be updated.
* The collection should not be frozen.

<!-- end of the list -->

    /**
      * @dev Update the additional data of an existing collection.
      * @param _collectionID Refers to the collection that the additional data will be updated.
      * @param _newCollectionArtistAddress Refers to the new artist's ETH public address.
      * @param _newCollectionMintCost Refers to the new mint cost of the collection.
      * @param _newMaxCollectionPurchases Refers to the updated value of max purchases/mints during public minting.
      * @param _newCollectionSalesPercentage Refers to updated % of royalties for the artist.
    */
 
    function updateCollectionAdditionalData(
      uint256 _collectionID,
      address _newCollectionArtistAddress,
      uint256 _newCollectionMintCost,
      uint256 _newMaxCollectionPurchases,
      uint256 _newCollectionSalesPercentage
    ) public AdminRequired;

<div id='updateBaseURI'/>

### How to update a collection's baseURI?

<b>Purpose:</b> The <i>updateBaseURI(..)</i> function is used to update a collection's baseURI.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* The collection needs to exist.
* The collection should not be frozen.

<!-- end of the list -->

    /**
      * @dev Update the baseURI of a collection.
      * @param _collectionID Refers to the collection that the baseURI will be updated.
      * @param _newCollectionBaseURI Refers to the new baseURI.
    */
 
    function updateBaseURI(
      uint256 _collectionID,
      uint256 _newCollectionBaseURI
    ) public AdminRequired;

<div id='updateImages'/>

### How to update the imageURI of a specific token for on-chain purposes?

<b>Purpose:</b> The <i>updateImages(..)</i> function is used to update the image URI of a set of tokens.

<b>Notes:</b> 
* This function can be called by the contract deployer or a contract administrator.
* Token ids should exist.
* The collection should not be frozen.

<!-- end of the list -->

    /**
      * @dev Update a token's imageURI.
      * @param _tokenId Refers to an array that holds the token ids that will be updated.
      * @param _image Refers to the images array that contains the image URI for each one of the tokens.
    */
 
    function updateImages(
      uint256[] memory _tokenId,
      string[] memory _image
    ) public AdminRequired;
