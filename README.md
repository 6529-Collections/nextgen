# NextGen

## Intro

NextGen is a series of contracts whose purpose is to explore:

- More experimental directions in generative art and
- Other non-art use cases of 100% on-chain NFTs

At a high-level, you can think of NextGen as:

- A classic on-chain generative contract with extended functionality
- With the phase-based, allowlist-based, delegation-based minting philosophy of The Memes
- With the ability to pass arbitrary data to the contract for specific addresses to customize the outputs
- With a wide range of minting models, each of which can be assigned to a phase

## Architecture

The NextGen smart contract architecture is as follows:

- Core: Core is the contract where the ERC721 tokens are minted and includes all the core functions of the ERC721 standard as well as additional setter & getter functions. The Core contract holds the data of a collection such as name, artist's name, library, script as well as the total supply of a collection. In addition, the Core contract integrates with the other NextGen contracts to provide a flexible, adjustable, and scalable functionality.
- Minter: The Minter contract is used to mint an ERC721 token for a collection on the Core contract based on certain requirements that are set prior to the minting process. The Minter contract holds all the information regarding an upcoming drop such as starting/ending times of various phases, Merkle roots, sales model, funds, and the primary and secondary addresses of artists.
- Admin: The Admin contract is responsible for adding or removing global or function-based admins who are allowed to call certain functions in both the Core and Minter contracts.
- Randomizer: The Randomizer contract is responsible for generating a random hash for each token during the minting process. Once the hash is generated is sent to the Core contract that stores it to be used to generate the generative art token.

NextGen currently considers 3 different Randomizer contracts that can be used for generating the tokenHash.
- A Randomizer contract that uses the Chainlink VRF.
- A Randomizer contract that uses ARRNG.
- A custom-made implementation Randomizer contract.

## Smart contracts

[View here](https://github.com/6529-Collections/nextgen/tree/main/hardhat/smart-contracts)

## Documentation

[View Docs](https://seize-io.gitbook.io/nextgen/)

