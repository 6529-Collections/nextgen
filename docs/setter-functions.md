# NextGen Smart Contract - Setter Functions
[How to create a Collection?](#createCollection)\
[How to add data on a Collection?](#addCollectionData)\
[How to set various collection minting phases?](#setCollectionPhases)\
[How to modify the minting status of a collection?](#mintingStatus)\
[How to airdrop tokens?](#airdrop)\
[How to mint tokens?](#minting)\
[How to send the collected funds to the Artist?](#payArist)\
[How to sign a collection?](#artistSign)\
[How to register a global admin on the smart contract?](#globalAdmin)\
[How to register a collection admin on the smart contract?](#collectionAdmin)\
[How to modify the metadata view of a collection?](#metadataView)\
[How to modify the on-chain token data of an existing token id?](#changeTokenData)\
[How to burn an existing token id?](#tokenBurn)\
[How to initiliaze burn to mint functionality?](#initiliazeburnToMint)\
[How to burn an existing token and mint a new one?](#burnToMint)\
[How to update the info of a Collection?](#updateCollectionInfo)\
[How to update the script of a Collection using an index?](#updateCollectionScriptByIndex)\
[How to update the additional data already set for a collection?](#updateCollectionAdditionalData)\

<div id='createCollection'/>

### How to create a Collection?

<b>Purpose:</b> The <i>createCollection(..)</i> function is used to create a new collection on the NextGen smart contract.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.
* Once the function is executed the smart contract autoassigns an id to the newly created collection.
* You need to add the additional data for the newly created collection to be able to start the minting process.

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

<b>Purpose:</b> The <i>addCollectionData(..)</i> function allows you to add the additional data for a Collection such as mintcost, max public purchases, total supply etc.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.
* Once the function is executed the smart contract reserves specific min and max indices for the collection.
* The collection's circulating supply starts at 0.
* You need to set the minting phases for the collection to be able to start the minting process.

<!-- end of the list -->

    /**
      * @dev Add data for a new NextGen collection.
      * @param _collectionID Refers to the collection id for which data will be added.
      * @param _collectionArtistAddress Refers to the artist's ETH public address.
      * @param _collectionMintCost Refers to the mint cost of the collection.
      * @param _maxCollectionPurchases Refers to the collection's max purchases/mints during public minting.
      * @param _collectionTotalSupply Refers to the collection's total supply.
      * @param _collectionSalesPercentage Refers to % of royalties for the artist.
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

<b>Purpose:</b> The <i>setCollectionPhases(..)</i> function allows you to set the start and endtimes for allowlist and public minting. For the allowlist minting you need to set also the MerkleRoot that will be used for verification purposes when the allowlist minting is active.

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
      * @param _collectionSalesPercentage Refers to % of royalties for the artist.
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

<b>Purpose:</b> The <i>changeCollectionMintStatus(..)</i> function allows you to enable/disable the minting process of a collection.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.

<!-- end of the list -->

    /**
      * @dev Set the minting status of a collection.
      * @param _collectionID Refers to the collection id for which the minting status will be modified.
      * @param _status Refers to minting status, if true == minting is active, otherwise minting is not enable.
    */
 
    function changeCollectionMintStatus(
      uint256 _collectionID,
      bool _status,
    ) public AdminRequired;

<div id='airdrop'/>

### How to airdrop tokens?

<b>Purpose:</b> The <i>airDropTokens(..)</i> function allows you to aidrop tokens of a specific collection to a list of recipients.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.
* You can only airdrop tokens of a specific collection.
* For each recipient you also need to pass additional token data.

<!-- end of the list -->

    /**
      * @dev Aidrop tokens of a specific collection to a list of recipients.
      * @param _recipients Refers to the list of recipients who will receive the airdrop.
      * @param _tokenData Refers to a list that contains the additional token data that we store on-chain for each airdropped token.
      * @param _collectionID Refers to collection for which the airdrop will take place.
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
* This function can be called by anyone.
* The function supports both allowlist or public minting phases.
* The function supports allowlist minting on behalf of a delegator.
* For allowlist minting max allowance spots, additional token data as well as the merkle proofs need to be passed as inputs when executing the transaction.

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
      * @param _delegator Refers to the delegator address during allowlist minting. If the mintor will mint on his behald this value
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

<b>Purpose:</b> The <i>payArtist(..)</i> function is used to send the funds collected during minting..

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.
* The function sends the collected funds to the artist based on the Sales Percentage set when adding the additional data for a collection.

<!-- end of the list -->

    /**
      * @dev Send funds collected during minting to the Artist and Team.
      * @param _collectionID Refers to collection for which the collected funds will be sent.
    */
 
    function payArtist(
      uint256 _collectionID,
    ) AdminRequired;

<div id='artistSign'/>

### How to sign a collection?

<b>Purpose:</b> The <i>artistSignature(..)</i> function is used by the artists to sign the collection that they have created.

<b>Notes:</b> 
* This function can only be called by an artist.
* The artist ETH public address needs to be assigned when adding the collection's additional data.

<!-- end of the list -->

    /**
      * @dev Artists sign their own collections.
      * @param _collectionID Refers to the collection for which the artist is allowed to add his signature.
      * @param _signature Refers to written text/signature of the artist that will be stored on-chain.
    */
 
    function artistSignature(
      uint256 _collectionID,
      string memory _signature
    ) public;

<div id='globalAdmin'/>

### How to register a global admin on the smart contract?

<b>Purpose:</b> The <i>registerAdmin(..)</i> function is used to register global admins on the smart contract.

<b>Notes:</b> 
* This function can only be called by the contract deployer.

<!-- end of the list -->

    /**
      * @dev Register a global admin.
      * @param _admin Refers to the ETH public address of an admin.
      * @param _status Refers to the status of a global admin, if true then the ETH address is registered as a global admin, otherwise it's not registered.
    */
 
    function registerAdmin(
      address _admin,
      bool _status
    ) onlyOwner;

<div id='collectionAdmin'/>

### How to register a collection admin on the smart contract?

<b>Purpose:</b> The <i>registerCollectionAdmin(..)</i> function is used for registering collection admins on the smart contract.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.

<!-- end of the list -->

    /**
      * @dev Register an admin on a specific collection.
      * @param _collectionID Refers to the collection for which an admin will be registered.
      * @param _address Refers to the ETH public address of the admin.
      * @param _status Refers to the status of a collection admin, if true then the ETH address is registered as a collection admin, otherwise it's not registered.
    */
 
    function registerCollectionAdmin(
      uint256 _collectionID,
      address _address,
      bool _status
    ) AdminRequired;

<div id='metadataView'/>

### How to modify the metadata view of a collection?

<b>Purpose:</b> The <i>changeMetadataView(..)</i> function is used for changing how metadata will be displayed for a collection when the <i>tokenURI()</i> function is called.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.

<!-- end of the list -->

    /**
      * @dev Change the metadata view for a collection.
      * @param _collectionID Refers to the collection for which the metadata view will be modified.
      * @param _status Refers to the view status of a collection, if true the tokenURI() function once called will return the metadata of a token id directly from on-chain, 
        otherwise it will return the tokenURI as a link.
    */
 
    function changeMetadataView(
      uint256 _collectionID,
      bool _status
    ) AdminRequired;

<div id='changeTokenData'/>

### How to modify the on-chain token data of an existing token id?

<b>Purpose:</b> The <i>changeTokenData(..)</i> function is used to change the token data of an already existing token.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.

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
* This function can only be called by the owner of the token id, or an approved address.

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

### How to initiliaze burn to mint functionality?

<b>Purpose:</b> The <i>initializeBurn(..)</i> function is used to initiliaze the burn to mint functionality.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.

<!-- end of the list -->

    /**
      * @dev Initiliaze the burn to mint functionality.
      * @param _burnCollectionID Refers to the collection for which a token will be burnt.
      * @param _mintCollectionID Refers to the collection for which a token will be minted.
      * @param _status Refers to the initilization status, if true it means that the burn to mint functionality has been initiliazed, otherwise no initilization was setup.
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
* The burn to mint functionality needs to be initiliazed first.

<!-- end of the list -->

    /**
      * @dev Burn an existing token and mint a new one.
      * @param _burnCollectionID Refers to the collection for which a token id will be burnt.
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
* The collection needs to be created first.

<!-- end of the list -->

    /**
      * @dev Update an existing NextGen collection.
      * @param _collectionID Refers to the collection that will be updated.
      * @param _newCollectionName Refers to the updated collection name.
      * @param _newCollectionArtist Refers to the updated artist's full name.
      * @param _newCollectionDescription Refers to the updated description of the collection.
      * @param _newCollectionWebsite Refers to the updated collection website.
      * @param _newCollectionLicense Refers to the updated collection license, ex. CC0.
      * @param _newCollectionBaseURI Refers to the updated collection BaseURI.
      * @param _newCollectionLibrary Refers to the updated library used to create the art.
      * @param _newCollectionScript Refers to the updated generative script of the collection.
    */
 
    function updateCollectionInfo(
      uint256 _collectionID,
      string memory _newCollectionName,
      string memory _newCollectionArtist,
      string memory _newCollectionDescription,
      string memory _newCollectionWebsite,
      string memory _newCollectionLicense,
      string memory _newCollectionBaseURI,
      string memory _newCollectionLibrary,
      string memory _newCollectionScript
    ) public AdminRequired;

<div id='updateCollectionScriptByIndex'/>

### How to update the script of a Collection using an index?

<b>Purpose:</b> The <i>updateCollectionScriptByIndex(..)</i> function is used to update a specific part of a collection's script.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.
* The collection needs to be created first.

<!-- end of the list -->

    /**
      * @dev Update an existing collection script.
      * @param _collectionID Refers to the collection that the script will be updated.
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
* This function can only be called by the contract deployer or a contract administrator.
* The collection needs to be created and initial data needs to be added.
* The total supply of a collection cannot be updated.

<!-- end of the list -->

    /**
      * @dev Update the additional data of an existing collection.
      * @param _newCollectionArtistAddress Refers to the updated artist's ETH public address.
      * @param _newCollectionMintCost Refers to the updated mint cost of the collection.
      * @param _newMaxCollectionPurchases Refers to the updated collection's max purchases/mints during public minting.
      * @param _newCollectionSalesPercentage Refers to updated % of royalties for the artist.
    */
 
    function updateCollectionAdditionalData(
      uint256 _collectionID,
      address _newCollectionArtistAddress,
      uint256 _newCollectionMintCost,
      uint256 _newMaxCollectionPurchases,
      uint256 _newCollectionSalesPercentage
    ) public AdminRequired;
