const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers")
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai")
const { ethers } = require("hardhat")
const fixturesDeployment = require("../scripts/fixturesDeployment.js")

let signers
let contracts

describe("NextGen Tests", function () {
  before(async function () {
    ;({ signers, contracts } = await loadFixture(fixturesDeployment))
  })

  context("Verify Fixture", () => {
    it("Contracts are deployed", async function () {
      expect(await contracts.hhAdmin.getAddress()).to.not.equal(
        ethers.ZeroAddress,
      )
      expect(await contracts.hhCore.getAddress()).to.not.equal(
        ethers.ZeroAddress,
      )
      expect(await contracts.hhDelegation.getAddress()).to.not.equal(
        ethers.ZeroAddress,
      )
      expect(await contracts.hhMinter.getAddress()).to.not.equal(
        ethers.ZeroAddress,
      )
      expect(await contracts.hhRandomizer.getAddress()).to.not.equal(
        ethers.ZeroAddress,
      )
      expect(await contracts.hhRandoms.getAddress()).to.not.equal(
        ethers.ZeroAddress,
      )
      expect(await contracts.hhAuction.getAddress()).to.not.equal(
        ethers.ZeroAddress,
      )
      expect(await contracts.hhDependency.getAddress()).to.not.equal(
        ethers.ZeroAddress,
      )
      expect(await contracts.hhReentrant.getAddress()).to.not.equal(
        ethers.ZeroAddress,
      )
    })
  })

  context("Create a collection & Set Data", () => {
    it("#createCollection1", async function () {
      await contracts.hhCore.createCollection(
        "Test Collection 1",
        "Artist 1",
        "For testing",
        "www.test.com",
        "CCO",
        "https://ipfs.io/ipfs/hash/",
        "",
        "0xb9a5dc0048db9a7d13548781df3cd4b2334606391f75f40c14225a92f4cb3537",
        ["desc"],
      )
    })

    it("#createCollection2", async function () {
      await contracts.hhCore.createCollection(
        "Test Collection 2",
        "Artist 2",
        "For testing",
        "www.test.com",
        "CCO",
        "https://ipfs.io/ipfs/hash/",
        "",
        "0xb9a5dc0048db9a7d13548781df3cd4b2334606391f75f40c14225a92f4cb3537",
        ["desc"],
      )
    })

    it("#createCollection3", async function () {
      await contracts.hhCore.createCollection(
        "Test Collection 3",
        "Artist 3",
        "For testing",
        "www.test.com",
        "CCO",
        "https://ipfs.io/ipfs/hash/",
        "",
        "0xb9a5dc0048db9a7d13548781df3cd4b2334606391f75f40c14225a92f4cb3537",
        ["desc"],
      )
    })

    it("#createCollection4", async function () {
      await contracts.hhCore.createCollection(
        "Test Collection 4",
        "Artist 4",
        "For testing",
        "www.test.com",
        "CCO",
        "https://ipfs.io/ipfs/hash/",
        "",
        "0xb9a5dc0048db9a7d13548781df3cd4b2334606391f75f40c14225a92f4cb3537",
        ["desc"],
      )
    })

    it("#createCollection5", async function () {
      await contracts.hhCore.createCollection(
        "Test Collection 5",
        "Artist 5",
        "For testing",
        "www.test.com",
        "CCO",
        "https://ipfs.io/ipfs/hash/",
        "",
        "0xb9a5dc0048db9a7d13548781df3cd4b2334606391f75f40c14225a92f4cb3537",
        ["desc"],
      )
    })

    it("#registerCollectionAdmin", async function () {
      await contracts.hhAdmin.registerCollectionAdmin(
        1,
        signers.addr1.address,
        true,
      )
    })

    it("#registerFunctionAdmin", async function () {
      await contracts.hhAdmin.registerFunctionAdmin(
        contracts.hhAuction,
        '0xd9f303a2',
        true,
      )
    })

    it("#setCollectionData1", async function () {
      await contracts.hhCore.connect(signers.addr1).setCollectionData(
        1, // _collectionID
        signers.addr1.address, // _collectionArtistAddress
        2, // _maxCollectionPurchases
        10000, // _collectionTotalSupply
        0, // _setFinalSupplyTimeAfterMint
      )
    })

    it("#setCollectionData2", async function () {
      await contracts.hhCore.setCollectionData(
        2, // _collectionID
        signers.addr1.address, // _collectionArtistAddress
        1, // _maxCollectionPurchases
        100, // _collectionTotalSupply
        1000, // _setFinalSupplyTimeAfterMint
      )
    })

    it("#setCollectionData3", async function () {
      await contracts.hhCore.setCollectionData(
        3, // _collectionID
        signers.addr1.address, // _collectionArtistAddress
        1, // _maxCollectionPurchases
        100, // _collectionTotalSupply
        1000, // _setFinalSupplyTimeAfterMint
      )
    })

    it("#setCollectionData4", async function () {
      await contracts.hhCore.setCollectionData(
        4, // _collectionID
        signers.addr1.address, // _collectionArtistAddress
        1, // _maxCollectionPurchases
        50, // _collectionTotalSupply
        200, // _setFinalSupplyTimeAfterMint
      )
    })

    it("#setCollectionData5", async function () {
      await contracts.hhCore.setCollectionData(
        5, // _collectionID
        signers.addr1.address, // _collectionArtistAddress
        0, // _maxCollectionPurchases
        100, // _collectionTotalSupply
        200, // _setFinalSupplyTimeAfterMint
      )
    })

  })

  context("Set Minter Contract", () => {
    it("#setMinterContract", async function () {
      await contracts.hhCore.updateContracts(
        2, contracts.hhMinter,
      )
    })
  })

  context("Set Randomizer Contract", () => {
    it("#setRandomizerContract1", async function () {
      await contracts.hhCore.addRandomizer(
        1, contracts.hhRandomizer,
      )
    })

    it("#setRandomizerContract2", async function () {
      await contracts.hhCore.addRandomizer(
        2, contracts.hhRandomizer,
      )
    })

    it("#setRandomizerContract3", async function () {
      await contracts.hhCore.addRandomizer(
        3, contracts.hhRandomizer,
      )
    })

    it("#setRandomizerContract4", async function () {
      await contracts.hhCore.addRandomizer(
        4, contracts.hhRandomizer,
      )
    })

    it("#setRandomizerContract5", async function () {
      await contracts.hhCore.addRandomizer(
        5, contracts.hhRandomizer,
      )
    })

  })

  context("Set Collection Costs and Phases", () => {
    it("#setCollectionCost1", async function () {
      await contracts.hhMinter.setCollectionCosts(
        1, // _collectionID
        0, // _collectionMintCost
        0, // _collectionEndMintCost
        0, // _rate
        0, // _timePeriod
        1, // _salesOptions
        '0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B', // delAddress
      )
    })

      it("#setCollectionCost2", async function () {
        await contracts.hhMinter.setCollectionCosts(
          2, // _collectionID
          BigInt(1000000000000000000), // _collectionMintCost 1 eth
          BigInt(100000000000000000), // _collectionEndMintCost 0.1 eth
          BigInt(100000000000000000), // _rate
          200, // _timePeriod
          2, // _salesOptions
          '0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B', // delAddress
        )
      })

      it("#setCollectionCost3", async function () {
        await contracts.hhMinter.setCollectionCosts(
          3, // _collectionID
          BigInt(1000000000000000000), // _collectionMintCost 1 eth
          0, // _collectionEndMintCost 0.1 eth
          10, // _rate
          200, // _timePeriod
          3, // _salesOptions
          '0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B', // delAddress
        )
      })

      it("#setCollectionCost4", async function () {
        await contracts.hhMinter.setCollectionCosts(
          4, // _collectionID
          BigInt(1000000000000000000), // _collectionMintCost 1 eth
          BigInt(100000000000000000), // _collectionEndMintCost 0.1 eth
          0, // _rate
          200, // _timePeriod
          2, // _salesOptions
          '0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B', // delAddress
        )
      })

      it("#setCollectionCost5", async function () {
        await contracts.hhMinter.setCollectionCosts(
          5, // _collectionID
          0, // _collectionMintCost 
          0, // _collectionEndMintCost 
          0, // _rate
          10, // _timePeriod
          0, // _salesOptions
          '0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B', // delAddress
        )
      })

      it("#setCollectionPhases1", async function () {
        await contracts.hhMinter.setCollectionPhases(
          1, // _collectionID
          1696931278, // _allowlistStartTime
          1696931278, // _allowlistEndTime
          1696931278, // _publicStartTime
          1796931278, // _publicEndTime
          "0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870", // _merkleRoot
        )
      })

      it("#setCollectionPhases2", async function () {
        await contracts.hhMinter.setCollectionPhases(
          2, // _collectionID
          1698138500, // _allowlistStartTime
          1698138500, // _allowlistEndTime
          1698138500, // _publicStartTime
          1796931278, // _publicEndTime
          "0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870", // _merkleRoot
        )
      })

      it("#setCollectionPhases3", async function () {
        await contracts.hhMinter.setCollectionPhases(
          3, // _collectionID
          1698136970, // _allowlistStartTime
          1698136970, // _allowlistEndTime
          1698136970, // _publicStartTime
          1796931278, // _publicEndTime
          "0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870", // _merkleRoot
        )
      })

      it("#setCollectionPhases4", async function () {
        await contracts.hhMinter.setCollectionPhases(
          4, // _collectionID
          1698138900, // _allowlistStartTime
          1698138900, // _allowlistEndTime
          1698138900, // _publicStartTime
          1796931278, // _publicEndTime
          "0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870", // _merkleRoot
        )
      })

      it("#setCollectionPhases5", async function () {
        await contracts.hhMinter.setCollectionPhases(
          5, // _collectionID
          1727265419, // _allowlistStartTime
          1727265419, // _allowlistEndTime
          1727265419, // _publicStartTime
          1727265419, // _publicEndTime
          "0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870", // _merkleRoot
        )
      })

  })

  context("Minting", () => {
    it("#mintNFTCol1", async function () {
      await contracts.hhMinter.mint(
        1, // _collectionID
        2, // _numberOfTokens
        0, // _maxAllowance
        '{"tdh": "100"}', // _tokenData
        signers.addr1.address, // _mintTo
        ["0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870"], // _merkleRoot
        signers.addr1.address, // _delegator
        2, //_varg0
      )
    })

    it("#mintNFTCol2", async function () {
      await contracts.hhMinter.mint(
        2, // _collectionID
        1, // _numberOfTokens
        0, // _maxAllowance
        '{"tdh": "100"}', // _tokenData
        signers.addr1.address, // _mintTo
        ["0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870"], // _merkleRoot
        signers.addr1.address, // _delegator
        2, //_varg0
        { value: BigInt(900000000000000000) }
      )
    })

    it("#mintNFTCol3", async function () {
      await contracts.hhMinter.mint( 
        3, // _collectionID
        1, // _numberOfTokens
        0, // _maxAllowance
        '{"tdh": "100"}', // _tokenData
        signers.addr1.address, // _mintTo
        ["0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870"], // _merkleRoot
        signers.addr1.address, // _delegator
        2, //_varg0
        { value: await contracts.hhMinter.getPrice(3) }
      )
    })

    it("#mintNFTCol3", async function () {
      await contracts.hhMinter.connect(signers.addr2).mint(
        3, // _collectionID
        1, // _numberOfTokens
        0, // _maxAllowance
        '{"tdh": "100"}', // _tokenData
        signers.addr1.address, // _mintTo
        ["0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870"], // _merkleRoot
        signers.addr1.address, // _delegator
        2, //_varg0
        { value: await contracts.hhMinter.getPrice(3) }
      )
    })

    it("#airdrop", async function () {
      await contracts.hhMinter.airDropTokens(
        [signers.addr1.address,signers.addr2.address], // _recipients
        ['{"tdh": "100"}','{"tdh": "200"}'], // _numberOfTokens
        [1,2], // _varg0
        1, // _collectionID
        [1,2], // _numberOfTokens
      )
    })

    it("#balanceOf", async function () {
      const balance = await contracts.hhCore.balanceOf(
        signers.addr1.address, // _address
      )
      expect(parseInt(balance)).to.equal(6); // if other fails
    })

    it("#balanceOf", async function () {
      const balance = await contracts.hhCore.balanceOf(
        signers.addr2.address, // _address
      )
      expect(parseInt(balance)).to.equal(2); // if other fails
    })

  })

  context("Token Info", () => {
    it("#tokenToHash", async function () {
      const tokenHash = await contracts.hhCore.retrieveTokenHash(
        10000000001, // _tokenId
      )
      expect(tokenHash).not.equal("0x0000000000000000000000000000000000000000000000000000000000000000"); // if 0x0... fails
    })

    it("#tokenURI", async function () {
      const tokenURI = await contracts.hhCore.tokenURI(
        10000000001, // _tokenId
      )
      expect(tokenURI).exist; 
    })

    it("#tokenDataPublic", async function () {
      const tokenData = await contracts.hhCore.tokenData(
        10000000001, // _tokenId
      )
      expect(tokenData).to.equal('"public"'); // if not "public" fails
    })

    it("#tokenDataAirdrop", async function () {
      const tokenData = await contracts.hhCore.tokenData(
        10000000002, // _tokenId
      )
      expect(tokenData).to.equal('{"tdh": "100"}'); // if not "public" fails
    })

    it("#generativeScript", async function () {
      const generativeScript = await contracts.hhCore.retrieveGenerativeScript(
        10000000001, // _tokenId
      )
      expect(generativeScript).exist;
    })

    it("#collectionID", async function () {
      const collectionID = await contracts.hhCore.viewColIDforTokenID(
        10000000001, // _tokenId
      )
      expect(parseInt(collectionID)).to.equal(1);
    })


  })

  context("Get Price", () => {
    it("#getPriceCol1", async function () {
      const price = await contracts.hhMinter.getPrice(
        1, // _collectionID
      )
      expect(parseInt(price)).equal(0); //
    })

    it("#getPriceCol2", async function () {
      const price = await contracts.hhMinter.getPrice(
        2, // _collectionID
      )
      expect(parseInt(price)).equal(100000000000000000); //
    })

    it("#getPriceCol3", async function () {
      const price = await contracts.hhMinter.getPrice(
        3, // _collectionID
      )
      expect(parseInt(price)).equal(1200000000000000000); //
    })

    it("#getPriceCol4", async function () {
      const price = await contracts.hhMinter.getPrice(
        4, // _collectionID
      )
      expect(parseInt(price)).equal(100000000000000000); //
    })

  })

  context("Minting To Auction", () => {
    it("#mintToAuction", async function () {
      const currentTime = await time.latest();
      await contracts.hhMinter.mintAndAuction(
        signers.owner.address, // _recipient
        "", // _tokenData
        1, // _saltfun_o,
        5, // _collectionId
        BigInt(currentTime + 610), // _auctionEndTime > time + 600
      )
    })

    it("#mintToAuction2", async function () {
      const currentTime = await time.latest();
      await contracts.hhMinter.mintAndAuction(
        signers.owner.address, // _recipient
        "", // _tokenData
        1, // _saltfun_o,
        5, // _collectionId
        BigInt(currentTime + 5000), // _auctionEndTime > time + 600
      )
    })

    it("#mintToAuction2", async function () {
      const currentTime = await time.latest();
      await contracts.hhMinter.mintAndAuction(
        signers.owner.address, // _recipient
        "", // _tokenData
        1, // _saltfun_o,
        5, // _collectionId
        BigInt(currentTime + 5000), // _auctionEndTime > time + 600
      )
    })
  })

  context("Set Approval", () => {
    it("#setApproval", async function () {
      await contracts.hhCore.setApprovalForAll(
        contracts.hhAuction, // address
        true, // approved
      )
    })
  })

  context("Set Collection Auction Data", () => {
    it("#setCollectionAuction", async function () {
      await contracts.hhAuction.setCollectionAuctionData(
        5, // _col
        BigInt(1000000000000000000), // _minBidPrice
        5, // _incrPercent
        200, // _extensionTime
        signers.addr3.address, // payOut
        true, // _status
      )
    })
  })

  context("Participate to Auction", () => {
    it("#participateAuctionZeroBid", async function () {
      await expect(
        contracts.hhAuction.connect(signers.addr2).participateToAuction(
          50000000000, // tokenid
          { value: 0 } // zero bid
        )
      ).to.be.revertedWith("Equal or Higher than starting bid");
    });

    it("#participateAuctionInsufficientBid", async function () {
      await expect(
        contracts.hhAuction.connect(signers.addr2).participateToAuction(
          50000000000, // tokenid
          { value: BigInt(500000000000000000) } // less than min bid
        )
      ).to.be.revertedWith("Equal or Higher than starting bid");
    });

    it("#participateAuction", async function () {
      await contracts.hhAuction.connect(signers.addr1).participateToAuction(
        50000000000, // tokenid
        { value: BigInt(1000000000000000000) }
      )
    })

    it("participateAuction2", async function () {

      await time.increase(550);

      await contracts.hhAuction.connect(signers.addr1).participateToAuction(
        50000000000, // tokenid
        { value: BigInt(1050000000000000000) }
      )
    })
  });

  context("Highest Bid and Bidder", () => {
    
    it("#auctionHighestBid", async function () {
      const highBid = await contracts.hhAuction.auctionHighestBid(
        50000000000, // _tokenId
      )
      expect(parseInt(highBid)).to.equal(1050000000000000000); // if other fails
    })

    it("#auctionHighestBidder", async function () {
      const highBidder = await contracts.hhAuction.auctionHighestBidder(
        50000000000, // _tokenId
      )
      expect(highBidder).to.equal(signers.addr1.address); // if other fails
    })

  })

  context("Claim Auction", () => {
    it("#payOutBalanceCheck", async function () {
      const balance = await network.provider.send("eth_getBalance", [signers.addr3.address, "latest"]);
      expect(balance).to.equal(BigInt(10000000000000000000000)); // if other fails
    })

    it("#claimAuctionBeforeEndTime", async function () {
      await expect(
        contracts.hhAuction.claimAuction(50000000000)
      ).to.be.revertedWith("err");
    })

    it("#claimAuction", async function () {
      await time.increase(1005);
      await contracts.hhAuction.claimAuction(
        50000000000
      )
    })

    it("#newOwner", async function () {
      const newOwner = await contracts.hhCore.ownerOf(
        50000000000, // _tokenId
      )
      expect(newOwner).to.equal(signers.addr1.address); // if other fails
    })

    it("#payOutBalanceAfterClaim", async function () {
      const balance = await network.provider.send("eth_getBalance", [signers.addr3.address, "latest"]);
      expect(balance).to.be.gt(BigInt(10000000000000000000000)); // if other fails
    })

  })

  context("Check reentrancy", () => {

    it("#setCollectionAuction", async function () {
      await contracts.hhAuction.setCollectionAuctionData(
        5, // _col
        BigInt(1000000000000000000), // _minBidPrice
        5, // _incrPercent
        200, // _extensionTime
        contracts.hhReentrant.getAddress(), // payOut Malicous contract
        true, // _status
      )
    })

    it("#participateAuction2", async function () {
      await contracts.hhAuction.connect(signers.addr2).participateToAuction(
        50000000001, // tokenid
        { value: BigInt(1000000000000000000) }
      )
    })

    it("#participateAuction3", async function () {
      await contracts.hhAuction.connect(signers.addr2).participateToAuction(
        50000000002, // tokenid
        { value: BigInt(1000000000000000000) }
      )
    })

    it("#checkReentrancy", async function () {
      await time.increase(15000);
      await expect(contracts.hhReentrant.connect(signers.addr3).attack()).to.be.reverted;
    })

    it("#setCollectionAuction", async function () {
      await contracts.hhAuction.setCollectionAuctionData(
        5, // _col
        BigInt(1000000000000000000), // _minBidPrice
        5, // _incrPercent
        200, // _extensionTime
        signers.addr3.address, // payOut
        true, // _status
      )
    })

    it("#claimAuction", async function () {
      await contracts.hhAuction.claimAuction(
        50000000001
      )
    })

    it("#claimAuctionAgain", async function () {
      await expect(
        contracts.hhAuction.claimAuction(50000000001)
      ).to.be.revertedWith("err");
    })

    it("#newOwner", async function () {
      const newOwner = await contracts.hhCore.ownerOf(
        50000000001, // _tokenId
      )
      expect(newOwner).to.equal(signers.addr2.address); // if other fails
    })

  });


})