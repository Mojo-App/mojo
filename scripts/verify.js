/* Standard `ethers` import for blockchain operations, plus `network` for logging the flagged network */
const { ethers, network } = require("hardhat")
require("@nomiclabs/hardhat-etherscan")
const dotenv = require("dotenv")
dotenv.config()

async function main() {
	await hre.run("verify:verify", {
		address: "0x4dBaa276d66B5dEAAc9Ca718773a7CE09f989741", // Deployed contract address -- potentially, use `hre` to help here
		constructorArguments: ['0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68'], // Tableland address on Polygon mainnet
	})
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
