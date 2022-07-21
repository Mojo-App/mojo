# Mojo

Mojo is an audio/media streaming platform that empowers artists and content creators through web3 and various blockchain technologies including Etheruem, IPFS, Tableland and is deployed to the Polygon testnet using Spheron and stored on Filecoin.

The Mojo web3 application allows you to upload your valuable digital assets to the IPFS Network. Files can never be deleted, hacked, edited, stolen and are never saved to any server making them 100% decentralised. Mojo allows creators to broaden their social reach offering custom NFTs that allow their followers and subscribers and access special content and features.

Mojo allows creators to build custom Metadata and attach this to their homemade NFTs.
Assign different attributes and values to your customised NFT. NFT Metadata is managed using Tableland which allows you to add, edit and update metadata attributes.

IPFS is a wonderful technology. It allows for content ownership, portability, and verifiability. It powers NFT marketplaces, individual websites, file-sharing platforms, and more. However, IPFS, the protocol, does not have a responsibility to match the experience of traditional cloud file services. Instead, that responsibility falls onto the shoulders of IPFS’s adoptors.

Streaming is not a new technology. However, IPFS is new enough that streaming is not yet native to its content delivery. And that’s exactly why Pinata is releasing streaming video through their Dedicated Gateways.

With streaming video in place, those who visit your gateway will no longer have to wait for a video file to download fully before it can be played. Just visit the URL and the video will start streaming, just like you would expect with Netflix or Youtube.

## Hardhat Project

This project uses Hardhat to test, compile and deploy contracts

Try running some of the following tasks from the project root to interact with the smart contracts

```shell
npx hardhat help
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
GAS_REPORT=true npx hardhat test
```

## Deployments Note

This project will only deploy to Mumbai Testnet due to the address registry passed to the contract constructor function

Mojo NFT Core smart contract deployed to: 0x9CA5D338f3cB8c76cC14B81058F9c1f7c3914bA4

Mojo Token smart contract deployed to: 0x424B6A8beF4c0807c1db53f21ea8bB8217B3AC7e

```shell
npx hardhat run scripts/deploy.js --network alchemy
```

## Basic Vue 3 Project

This project uses Vue3 for the front-end with a combination of custom CSS, SCSS and SASS. Additonal web3 libraries have been used to integrate with the ethereum blockcahin and other integrations like Tableland and more.

Run the following commands from the pwa folder in root to power up the main website

```shell
cd pwa
npm install
npm run lint
npm run dev
```
