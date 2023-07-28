// merkle tree/proofs generation
const { MerkleTree } = require('merkletreejs');
const { keccak256 } = require("@ethersproject/keccak256");
const { hexConcat } = require('@ethersproject/bytes');

// wallet addresses
const allowList = [
  '5B38Da6a701c568545dCfcB03FcB875f56beddC4',
  '78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB',
  '4B20993Bc481177ec7E8f571ceCaE8A9e22C02db',
  'Ab8483F64d9C6d1EcF9b849Ae677dD3315835cb2'
];

// number of spots per address

const spots = [
  '0000000000000000000000000000000000000000000000000000000000000002',
  '0000000000000000000000000000000000000000000000000000000000000003',
  '0000000000000000000000000000000000000000000000000000000000000002',
  '0000000000000000000000000000000000000000000000000000000000000001'
];

// extra info per address

const txinfo = [
  '7B68656C6C6F7D', //{hello}
  '7B70756E6B7D', // {punk}
  '7B7365697A657D', // {seize}
  '7B6E65787467656E7D' // {nextgen}
];

// calculate leaves hash

let leaves = allowList.map((addr, index) => {
  const concatenatedData = addr + spots[index] + txinfo[index];
  console.log(concatenatedData);
  const bufferData = Buffer.from(concatenatedData , 'hex');
  return keccak256(bufferData);
});


console.log(leaves);

const merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true });


// Construct Merkle Tree
console.log(merkleTree.toString());

// Generate Merkle root hash
// Get the Merkle root hash, save this to the contract
const merkleRoot = merkleTree.getHexRoot();
console.log(`merkleRoot is:\n ${merkleRoot} \n`);
