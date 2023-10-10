const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers")
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
    })
  })

  context("Create a collection & Set Data", () => {
    it("#createCollection", async function () {
      await contracts.hhCore.createCollection(
        "Test Collection 1",
        "Artist 1",
        "For testing",
        "www.test.com",
        "CCO",
        "https://ipfs.io/ipfs/hash/",
        "",
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

    it("#setCollectionData", async function () {
      await contracts.hhCore.connect(signers.addr1).setCollectionData(
        1, // _collectionID
        signers.addr1.address, // _collectionArtistAddress
        2, // _maxCollectionPurchases
        10000, // _collectionTotalSupply
        0, // _setFinalSupplyTimeAfterMint
      )
    })
  })

  context("Set Minter Contract", () => {
    it("#setMinterContract", async function () {
      await contracts.hhCore.addMinterContract(
        contracts.hhMinter,
      )
    })
  })

  context("Set Collection Costs and Phases", () => {
    it("#setCollectionCost", async function () {
      await contracts.hhMinter.setCollectionCosts(
        1, // _collectionID
        0, // _collectionMintCost
        0, // _collectionEndMintCost
        0, // _rate
        0, // _timePeriod
        1, // _salesOptions
      )
    })

    it("#setCollectionPhases", async function () {
      await contracts.hhMinter.setCollectionPhases(
        1, // _collectionID
        1696931278, // _allowlistStartTime
        1696931278, // _allowlistEndTime
        1696931278, // _publicStartTime
        1796931278, // _publicEndTime
        "0x8e3c1713145650ce646f7eccd42c4541ecee8f07040fc1ac36fe071bbfebb870", // _merkleRoot
      )
    })

  })

  context("Minting", () => {
    it("#mintNFT", async function () {
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

    it("#balanceOf", async function () {
      const balance = await contracts.hhCore.balanceOf(
        signers.addr1.address, // _address
      )
      expect(parseInt(balance)).to.equal(2); // if 3 fails
    })

    it("#tokenToHash", async function () {
      const tokenHash = await contracts.hhCore.tokenToHash(
        10000000001, // _tokenId
      )
      expect(tokenHash).not.equal("0x0000000000000000000000000000000000000000000000000000000000000000"); // if 0x0... fails
    })

  })






})