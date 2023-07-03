# NextGen Smart Contract - Setter Functions
[How to create a Collection?](#createCollection)\
[How to add data on a Collection?](#addCollectionData)  


<div id='createCollection'/>

### How to create a Collection?

<b>Purpose:</b> The <i>createCollection(..)</i> function is used to create a new collection on the NextGen smart contract. 

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

<b>Notes:</b> This function can only be called by the contract deployer or a contract administrator.

<div id='addCollectionData'/>

### How to add data on a Collection?

<b>Purpose:</b> The <i>addCollectionData(..)</i> function
