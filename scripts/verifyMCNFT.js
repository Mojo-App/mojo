/* Standard `ethers` import for blockchain operations, plus `network` for logging the flagged network */
const { ethers, network } = require("hardhat");
require("@nomiclabs/hardhat-etherscan");
const dotenv = require("dotenv");
dotenv.config();

async function main() {
	await hre.run("verify:verify", {
		address: "0x22Dbbb789aE924dCA4C2366Fc4d34f269e2fC3B3", // Deployed contract address -- potentially, use `hre` to help here
		constructorArguments: ['0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68'], // Tableland Contract Address on Polygon Mumbai
	})
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
