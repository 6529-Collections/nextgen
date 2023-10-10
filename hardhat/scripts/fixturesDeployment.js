const { ethers } = require("hardhat")

// Setup test environment:
const fixturesDeployment = async () => {
  const signersList = await ethers.getSigners()
  const owner = signersList[0]
  const addr1 = signersList[1]
  const addr2 = signersList[2]
  const addr3 = signersList[3]

  const randoms = await ethers.getContractFactory("randomText")
  const hhRandoms = await randoms.deploy()

  const nextGenAdmins = await ethers.getContractFactory("NextGenAdmins")
  const hhAdmin = await nextGenAdmins.deploy()

  const randomizer = await ethers.getContractFactory("NextGenRandomizer")
  const hhRandomizer = await randomizer.deploy(
    await hhRandoms.getAddress(),
    await hhAdmin.getAddress(),
  )

  const nextGenCore = await ethers.getContractFactory("NextGenCore")
  const hhCore = await nextGenCore.deploy(
    "Next Gen Core",
    "NEXTGEN",
    await hhRandomizer.getAddress(),
    await hhAdmin.getAddress(),
  )

  const delegation = await ethers.getContractFactory(
    "DelegationManagementContract",
  )
  const hhDelegation = await delegation.deploy()

  const nextGenMinter = await ethers.getContractFactory("NextGenMinterContract")
  const hhMinter = await nextGenMinter.deploy(
    await hhCore.getAddress(),
    await hhDelegation.getAddress(),
    await hhAdmin.getAddress(),
  )

  const contracts = {
    hhAdmin: hhAdmin,
    hhCore: hhCore,
    hhDelegation: hhDelegation,
    hhMinter: hhMinter,
    hhRandomizer: hhRandomizer,
    hhRandoms: hhRandoms,
  }

  const signers = {
    owner: owner,
    addr1: addr1,
    addr2: addr2,
    addr3: addr3,
  }

  return {
    signers,
    contracts,
  }
}

module.exports = fixturesDeployment