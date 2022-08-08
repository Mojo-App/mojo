// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, upgrades, network } from "hardhat";
import { proxies, ProxyAddresses } from "@tableland/evm/proxies";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const registryAddress =
    network.name === "localhost" ?
    "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512" :
    (proxies as ProxyAddresses)[network.name];

  if (!registryAddress) throw new Error("Cannot get Registry Address for " + network.name);

  const MojoCore = await ethers.getContractFactory("MojoCore");
  const mojoCore = await upgrades.deployProxy(MojoCore, [
    "https://testnet.tableland.network/query?s=",
    "set.external.url"
  ], {
    kind: "uups",
  });
  await mojoCore.deployed();
  console.log("Proxy deployed to:", mojoCore.address, "on", network.name);

  const impl = await upgrades.erc1967.getImplementationAddress(mojoCore.address);
  console.log("New implementation address:", impl);
  console.log("Running post deploy")

  const tx = await mojoCore.createMetadataTable(registryAddress);
  const receipt = await tx.wait();
  const tableId = receipt.events[0].args.tokenId;
  console.log("tableId:", tableId.toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
