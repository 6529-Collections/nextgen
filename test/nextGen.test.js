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
    })
  })

  context("Create a collection", () => {
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
        100, // _maxCollectionPurchases
        10000, // _collectionTotalSupply
        0, // _setFinalSupplyTimeAfterMint
      )
    })
  })
})
