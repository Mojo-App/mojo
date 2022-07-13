// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const [deployer] = await hre.ethers.getSigners();
  const accountBalance = await deployer.getBalance();

  console.log("Deploying contracts address: ", deployer.address);
  console.log("Account balance: ", accountBalance.toString());

  const mojoCoreContractFactory = await hre.ethers.getContractFactory("MojoCore");
  const mojoContract = await mojoCoreContractFactory.deploy(deployer.address);
  await mojoContract.deployed();
  console.log("MojoCore smart contract deployed to: ", mojoContract.address);

  // Call the function.
  // let nftURI = "URI_HERE";
  // let txn = await mojoContract.safeMint(deployer.address, nftURI);
  // Wait for it to be mined.
  await txn.wait();
  console.log("Minted NFT");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
