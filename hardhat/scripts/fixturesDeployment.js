const { ethers } = require("hardhat")

// Setup test environment:
const fixturesDeployment = async () => {
  const signersList = await ethers.getSigners()
  const owner = signersList[0]
  const addr1 = signersList[1]
  const addr2 = signersList[2]
  const addr3 = signersList[3]


  const delegation = await ethers.getContractFactory("DelegationManagementContract")
  const hhDelegation = await delegation.deploy()

  const randoms = await ethers.getContractFactory("randomPool")
  const hhRandoms = await randoms.deploy()

  const nextGenAdmins = await ethers.getContractFactory("NextGenAdmins")
  const hhAdmin = await nextGenAdmins.deploy()

  const dependencyContract = await ethers.getContractFactory("DependencyRegistry")
  const hhDependency = await dependencyContract.deploy(
    await hhAdmin.getAddress(),
  )

  const nextGenCore = await ethers.getContractFactory("NextGenCore")
  const hhCore = await nextGenCore.deploy(
    "Next Gen Core",
    "NEXTGEN",
    await hhAdmin.getAddress(),
    await hhDependency.getAddress(),
  )

  // This example uses the NXT Randomizer

  const randomizer = await ethers.getContractFactory("NextGenRandomizerNXT")
  const hhRandomizer = await randomizer.deploy(
    await hhRandoms.getAddress(),
    await hhAdmin.getAddress(),
    await hhCore.getAddress()
  )

  const nextGenMinter = await ethers.getContractFactory("NextGenMinterContract")
  const hhMinter = await nextGenMinter.deploy(
    await hhCore.getAddress(),
    await hhDelegation.getAddress(),
    await hhAdmin.getAddress(),
  )

  const nextAuction = await ethers.getContractFactory("NextGenAuctions")
  const hhAuction = await nextAuction.deploy(
    await hhMinter.getAddress(),
    await hhCore.getAddress(),
    await hhAdmin.getAddress(),
  )

  const reentrant = await ethers.getContractFactory("MaliciousReentrant")
  const hhReentrant = await reentrant.deploy(
    await hhAuction.getAddress(),
    50000000001
  )

  const contracts = {
    hhAdmin: hhAdmin,
    hhCore: hhCore,
    hhDelegation: hhDelegation,
    hhMinter: hhMinter,
    hhRandomizer: hhRandomizer,
    hhRandoms: hhRandoms,
    hhDependency: hhDependency,
    hhAuction: hhAuction,
    hhReentrant: hhReentrant
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