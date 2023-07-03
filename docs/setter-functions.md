# NextGen Smart Contract - Setter Functions
[How to create a Collection?](#createCollection)\
[How to add data on a Collection?](#addCollectionData)\
[How to set various collection minting phases?](#setCollectionPhases)\
[How to modify a collection's minting status?](#mintingStatus)\


<div id='createCollection'/>

### How to create a Collection?

<b>Purpose:</b> The <i>createCollection(..)</i> function is used to create a new collection on the NextGen smart contract.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.
* Once the function is executed the smart contract autoassigns an id to the newly created collection.
* Next you need to add the additional data for the newly created collection.

<!-- end of the list -->

    /**
      * @dev Create a new NextGen collection.
      * @param _collectionName Refers to the collection name.
      * @param _collectionArtist Refers to the artist's full name.
      * @param _collectionDescription Refers to the short description of the collection.
      * @param _collectionWebsite Refers to the collection website.
      * @param _collectionLicense Refers to the collection license, ex. CC0.
      * @param _collectionBaseURI Refers to the collection BaseURI.
      * @param _collectionLibrary Refers to the library used to create the collection.
      * @param _collectionScript Refers to the collection's generative script.
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

<b>Purpose:</b> The <i>addCollectionData(..)</i> function helps you add additional data for a Collection such as mintcost, max public purchases, total supply etc.

<b>Notes:</b> 
* This function can only be called by the contract deployer or a contract administrator.
* Once the function is executed the smart contract reserves specific min and max indeces for the collection's token ids.
* The collections circulating supply at start is 0.
* Next you need to set the phases for the collection.

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
 
    function createCollection(
      uint256 _collectionID,
      address _collectionArtistAddress,
      uint256 _collectionMintCost,
      uint256 _maxCollectionPurchases,
      uint256 _collectionTotalSupply,
      uint256 _collectionSalesPercentage
    ) public AdminRequired;

<div id='setCollectionPhases'/>

### How to set various collection minting phases?

<b>Purpose:</b> The <i>setCollectionPhases(..)</i> allows you to set the start and endtimes for allowlist and public minting. In addition for the allowlist minting you need to set the MerkleRoot that will be used for verification purposes when the allowlist minting is active.

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
 
    function createCollection(
      uint256 _collectionID,
      uint256 _allowlistStartTime,
      uint256 _allowlistEndTime,
      uint256 _publicStartTime,
      uint256 _publicEndTime,
      bytes32 _merkleRoot
    ) public collectionOrGlobalAdmin(_collectionID);

<div id='mintingStatus'/>

### How to modify a collection's minting status?

