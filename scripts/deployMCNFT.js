// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

// Standard `ethers` import for chain interaction, `network` for logging, and `run` for verifying contracts
const { ethers, network } = require("hardhat");

// Import Tableland
const { connect } = require("@tableland/sdk");

// Import 'node-fetch' and set globally -- needed for Tableland to work with CommonJS
const fetch = (...args) => import("node-fetch").then(({ default: fetch }) => fetch(...args));
globalThis.fetch = fetch;

async function main() {

  const [signer] = await ethers.getSigners();

  console.log(`\nDeploying to network '${network.name}' with account ${signer.address}`);
  const Mojo_MC = await ethers.getContractFactory("MCNFT");

  /* Connect to Tableland */
	const tableland = await connect({ signer, chain: "polygon-mumbai" })
  console.log("Tableland Address : ", tableland.options.contract);

  const mojo_mc = await Mojo_MC.deploy(tableland.options.contract);
  await mojo_mc.deployed();

  /* Log the deployed address and call the getter on `baseURIString` (for demonstration purposes) */
	console.log(`\Mojo Creators NFTs contract deployed on ${network.name} at: ${mojo_mc.address}`);

  const mainTable = await mojo_mc.mainTable();
	console.log(`Mojo Creators Main Table: ${mainTable}`);

  const attributesTable = await mojo_mc.attributesTable();
	console.log(`Mojo Creators Attributes Table : ${attributesTable}`);
}

/* We recommend this pattern to be able to use async/await everywhere and properly handle errors */
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
