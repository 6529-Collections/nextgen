# NextGen Smart Contract - Getter Functions
[How to retrieve the tokenURI?](#tokenURI)\
[How to find the reserved tokens indices of a collection?](#tokenIndices)\
[How to retrieve the info of a specific collection?](#collectionInfo)\
[How to find the library and the script that are used by a collection?](#collectionLibraryAndScript)\
[How to retrieve the Additional data that were set for a collection?](#CollectionAdditionalData)\
[How to retrieve a collection's minting phases times and merkle root?](#CollectionPhases)\
[How to get the generative script of a tokenId?](#GenerativeScript)\
[How to get the total supply of a collection?](#totalSupply)\
[How to get the token data stored on-chain for each token id?](#tokenData)\
[How to get the amount of tokens airdropped/minted during the allowlist or public minting?](#mintedTokens)
[How to get the current price of a live collection sale?](#getPrice)

<div id='tokenURI'/>

### How to retrieve the tokenURI?

<b>Purpose:</b> The <i>tokenURI(..)</i> function retrieves the tokenuri of a specific tokenid.

<b>Notes:</b> 
* This function overrides the standard ERC721 function.
* This function can return the tokenURI based just on on-chain data rather than returning a .json URI.

<!-- end of the list -->

    /**
      * @dev Retrieve the tokenURI of a tokenID.
      * @param tokenId Refers to the token for which the metadata will be returned.
    */
 
    function tokenURI(
      uint256 tokenId
    ) public view returns (string memory) {
      return (baseURI, tokenId) or
      return _uri;
    }

<div id='tokenIndices'/>

### How to find the reserved token indices of a collection?

<b>Purpose:</b> The <i>viewTokensIndexForCollection(..)</i> function retrieves the token indices reserved for a collection.

<b>Notes:</b> 
* The collection must exist and data already added.

<!-- end of the list -->

    /**
      * @dev Retrieve the token indices of a collection.
      * @param _collectionID Refers to the specific collection for which the token indices will be returned.
    */
 
    function viewTokensIndexForCollection(
      uint256 _collectionID
    ) public view returns (uint256, uint256) {
      return (reservedMinTokensIndex, reservedMaxTokensIndex);
    }

<div id='collectionInfo'/>

### How to retrieve the info of a specific collection?

<b>Purpose:</b> The <i>retrieveCollectionInfo(..)</i> function retrieves the full info of a collection.

<b>Notes:</b> 
* The collection must exist.

<!-- end of the list -->

    /**
      * @dev Retrieve a collection's information.
      * @param _collectionID Refers to the specific collection for which the info will be returned.
    */
 
    function retrieveCollectionInfo(
      uint256 _collectionID
    ) public view returns (string memory, sring memory, string memory, string memory, string memory, string memory) {
      return (collectionName, collectionArtist, collectionDescription, collectionWebsite, collectionLicense, collectionBaseURI);
    }

<div id='collectionLibraryAndScript'/>

### How to find the library and the script that are used by a collection?

<b>Purpose:</b> The <i>retrieveCollectionLibraryAndScript(..)</i> function retrieves the library and script that are used for generating a collection.

<b>Notes:</b> 
* The collection must exist.

<!-- end of the list -->

    /**
      * @dev Retrieve a collection's library and script.
      * @param _collectionID Refers to the specific collection for which the library and script will be returned.
    */
 
    function retrieveCollectionLibraryAndScript(
      uint256 _collectionID
    ) public view returns (string memory, sring[] memory) {
      return (collectionLibrary, collectionScript);
    }

<div id='CollectionAdditionalData'/>

### How to retrieve the Additional data that were set for a collection?

<b>Purpose:</b> The <i>retrieveCollectionAdditionalData(..)</i> function retrieves the additional data set when creating a collection.

<b>Notes:</b> 
* The collection must exist.
* Additional Data must be added for a collection.

<!-- end of the list -->

    /**
      * @dev Retrieve a collection's additional data.
      * @param _collectionID Refers to the specific collection for which the additional data will be returned.
    */
 
    function retrieveCollectionAdditionalData(
      uint256 _collectionID
    ) public view returns (address, uint256, uint256, uint256, uint256, uint256) {
      return (collectionArtistAddress, collectionMintCost, maxCollectionPurchases, collectionCirculationSupply, collectionTotalSupply, collectionSalesPercentage);
    }

<div id='CollectionPhases'/>

### How to retrieve a collection's minting phases times and merkle root?

<b>Purpose:</b> The <i>retrieveCollectionPhases(..)</i> function retrieves a collection's minting phases times and merkle root.

<b>Notes:</b> 
* The collection must exist.
* Additional Data must be added for a collection.
* Collection Phases data must exist.

<!-- end of the list -->

    /**
      * @dev Retrieve the minting phases times and merkle root of a collection.
      * @param _collectionID Refers to the specific collection for which the collection phases data will be returned.
    */
 
    function retrieveCollectionPhases(
      uint256 _collectionID
    ) public view returns (uint, uint, bytes32, uint, uint, uint256, uint256 ) {
      return (allowlistStartTime, allowlistEndTime, merkleRoot, publicStartTime, publicEndTime, rate, salesOption);
    }

<div id='GenerativeScript'/>

### How to get the generative script of a tokenId?

<b>Purpose:</b> The <i>retrieveGenerativeScript(..)</i> function retrieves the generative script given a tokenid.

<b>Notes:</b> 
* The token must exist.

<!-- end of the list -->

    /**
      * @dev Retrieve the generative script given a tokenid.
      * @param tokenId Refers to the specific token for which the generative script will be returned.
    */
 
    function retrieveGenerativeScript(
      uint256 tokenId
    ) public view returns (string memory) {
      return string();
    }

<div id='totalSupply'/>

### How to get the total supply of a collection?

<b>Purpose:</b> The <i>totalSupplyOfCollection(..)</i> function retrieves the total token supply of a collection.

<b>Notes:</b> 
* The collection must exist.

<!-- end of the list -->

    /**
      * @dev Retrieve the total circulating supply of a collection.
      * @param _collectionID Refers to the specific collection for which the total supply will be returned.
    */
 
    function totalSupplyOfCollection(
      uint256 _collectionID
    ) public view returns (uint256) {
      return collectionCirculationSupply - burnAmount;
    }

<div id='tokenData'/>

### How to get the token data stored on-chain for a token id?

<b>Purpose:</b> The <i>retrieveTokenData(..)</i> function retrieves the data stored on the smart contract for a specific token id.

<b>Notes:</b> 
* The token must exist.

<!-- end of the list -->

    /**
      * @dev Retrieve the token data stored on-chain for a token id.
      * @param tokenId Refers to the specific token for which the token data will be returned.
    */
 
    function retrieveTokenData(
      uint256 tokenId
    ) public view returns (string memory) {
      return tokenData;
    }

<div id='mintedTokens'/>

### How to get the amount of tokens airdropped/minted during the allowlist or public minting?

<b>Purpose:</b> The <i>retrieveTokensPerAddress(..)</i> function retrieves the tokens airdropped/minted during the allowlist or public minting.

<b>Notes:</b> 
* The collection must exist.

<!-- end of the list -->

    /**
      * @dev Retrieve the tokens airdropped/minted during the allowlist or public minting given an address.
      * @param _collectionID Refers to the specific collection for which the airdropped/minted tokens will be returned.
      * @param _address Refers to the specific wallet address for which the amount of tokens during each phase will be returned.
    */
 
    function retrieveTokensPerAddress(
      uint256 _collectionID, 
      address _address
    ) public view returns (uint256, uint256, uint256) {
      return (Airdrop, Allowlist, Public);
    }

<div id='getPrice'/>

### How to get the current price of a live collection sale?

<b>Purpose:</b> The <i>getPrice(..)</i> function retrieves current minting price of a live collection.

<b>Notes:</b> 
* The collection must exist.
* Additional Data must be added for a collection.
* Minting phases must be setup.

<!-- end of the list -->

    /**
      * @dev Retrieve the current minting price of a live collection
      * @param _collectionID Refers to the specific collection for which the the current price will be returned.
    */
 
    function getPrice(
      uint256 _collectionID
    ) public view returns (uint256) {
      return (MintingCost);
    }
