# Mojo Music NFTs

Mojo is an audio/media streaming platform that empowers content creators through IPFS and blockchain technologies.

The Mojo web3 application allows users to upload their valuable digital assets easily and seamlessly to the IPFS Network via our upload user interface. Files can never get deleted, hacked, edited, stolen and are never saved to a server making them truly decentralised.

IPFS is a wonderful technology as it allows for content ownership, portability, and verifiability. It powers NFT marketplaces, individual websites, file-sharing platforms, and so much more. However, IPFS, the protocol, does not have a responsibility to match the experience of traditional cloud file services. Instead, that responsibility falls onto the shoulders of IPFS’s adopters.

Mojo helps fill this gap and gives musicians, artists and all creators an opportunity to broaden their social reach by offering specially crafted audio and media NFTs that allow their followers and subscribers to access special content or unique features.

Users can Mint NFTs and then create different attributes and values and assign these to the NFT based on the media type. Creators will be able to manage their NFT's metadata using Tableland's relational metadata protocol for EVM chains. This freedom allows creators to update non-essential data, yet keeping the true values of their NFT's in tack and aligned with core NFT standards. Tableland also opens up doors to cross-chain relational data for NFTs and so much more.

Music platforms and streaming is not new technology. However, IPFS is still new enough that streaming is not yet native to its content delivery. And that’s exactly why Pinata is releasing streaming video through their Dedicated Gateways. With streaming video in place, those who visit your gateway will no longer have to wait for a video file to download fully before it can be played. Just visit the URL and the video will start streaming, just like you would expect with Netflix or Youtube, just much better. Using this NFT based content, artists can already start offering content to holders using Pinata's Submarine which will be another great feature to integrate.

Mojo aims to further it's product by buidling the following key features in the Mojo web3 application:

1. Artists should be able to upload their content in a secure and friendly manner.
2. Listeners/viewers should be able to view music streams on the platform free of charge
3. The Mojo platform should offer cryptocurrency-based payments to artists and their audiences.
4. Music fans should have full access to their favorite artists with bonus content and features.
5. Upon the purchase of a NFT, smart contracts should automatically process payments of royalty fees to digital artists and content creators.
6. The platform should use blockchain to keep transactions and accounting transparent.
7. The platform should let the artists keep most of the revenue they generate with very small fees to maintain the Mojo geek-o-system.
8. Listeners/viewers shouldn’t have to contend with tacky ads. The platform should consider other monetization options,
   For e.g., artists can set up an agreement with their fans to share revenue if fans share music, helping it to reach a wider audience.
   NFT based content, artist can offer content to holders using Pinata's Submarine
   Establish a very high standard of niche advertising to followers
9. A simple user interface (UI) is important.
10. A defi element should be added to our token contracts to allow staking of NFTs

Technology Stack
Mojo was built with or uses the following technologies in it's software life cycle:
Etheruem (Solidity) - Smart contracts written in Solidity
IPFS & Filecoin - IPFS is used to store all our data including images, metadata, videos and also the Mojo website is served via IPFS and stored on Filecoin
Please note IPFS is used throughout the Mojo application including the Mint and Upload user interfaces, it is also used to store a copy of the Mojo website using Spheron. I have various services and helpers that handle the processing of files and creating direct ipfs:// links as well as gateway versions for content sharing links in case users don't have IPFS setup or their browsers don't support it yet

Sponsor Note: Kindly refer to pwa > src > services for examples of IPFS and NFT.Storage usage. These are used in the Upload and Mint functionality.
The website is also served via IPFS using Spheron, the project is then stored on Filecoin.

Tableland - Tableland was used to create a SQL table on contract creation which stores the tokenId, aid, gid, and external_url. The NFT is created in normal fashion whereby the images and metadata are created and stored on ipfs://, then in addition the same information is then stored in separate sql tables which will be joined together to provide the NFT with a new tokenUri serving the metadata from Tableland. The aim is to be able to create Tableland data for old NFTs and then we will be able to addon to these using our custom metadata templates based on file types or media types

Tableland Examples

```shell
https://testnet.tableland.network/query?mode=list&s=SELECT%20*%20FROM%20mojo_80001_1199
```

```shell
https://testnet.tableland.network/query?s=SELECT%20%27id%27,id,%27external_link%27,external_link%20FROM%20mojo_80001_1199%20WHERE%20id%3D1
```

Polygon - Mojo is deployed to the Polygon Mumbai network and uses Matic for payments and minting, Mumbai Testnet for demo purposes only please!
Spheron - The Mojo web app is deployed seemlessly using Spheron, and served to the world via IPFS, also stored on Filecoin.
Hardhat - Hardhat takes care of all my deployments and smart contract compilation.
Vue.js - I just like the vue from over here ;)
Pinia - Store management using Pinia
SCSS - Austin Powers Styling, Yeah Baby!
HTML - Ok enough, I get it! Thanks for hanging around this long, hope you enjoyed...

Please visit <https://mojo-lgp54n.spheron.app/> to view the Mojo web3 application, feel free to connect your metamask wallet and enjoy

A 🧪 buidl by Craig Moss
Twitter: [@webmoss](https://twitter.com/webmoss)
LinkedIn: (<https://www.linkedin.com/in/craig-moss-21822628/>)

## Hardhat Project Setup

This project uses Hardhat to test, compile and deploy contracts

Try running some of the following tasks from the project root to interact with the smart contracts

```shell
npx hardhat help
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
GAS_REPORT=true npx hardhat test
```

## Deployments Note

This project will only deploy to Polygon's 'Mumbai Testnet due to the address registry passed to the contract constructor function

Mojo NFT Core smart contract deployed to: 0x6b9482bD2EEd7814EE5a88Cc93f687a3961D27Fb

```shell
npx hardhat run scripts/deploy.js --network polygon-mumbai
```

## Verify Contracts Note

You will need to verify your contracts as below, replace the first address with your new contract address

```shell
npx hardhat verify --network polygon-mumbai "0x6b9482bD2EEd7814EE5a88Cc93f687a3961D27Fb"
npx hardhat --network polygon-mumbai verify "0x6b9482bD2EEd7814EE5a88Cc93f687a3961D27Fb" "0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68"
npx hardhat --network ethereum-goerli verify "0x4035ce0Df8440bd07BEf39306e4a8D785C0e13a1" "0xDA8EA22d092307874f30A1F277D1388dca0BA97a"
```

## Mojo ERC-20 Token

Mojo aims to launch a token using the ERC-20 smart contract, a dummy version has been created on Polygon to test with

Mojo Token smart contract deployed to: 0x424B6A8beF4c0807c1db53f21ea8bB8217B3AC7e

## Basic Vue 3 Project using Vite and Pinia

This project uses Vue 3 for the front-end, Pinia for store management and web3 libraries to integrate with the Ethereum blockcahin and other cutting edge blockchain technologies including Tableland, NFT.Storage, IPFS and more.

Run the following commands from the pwa folder in root to power up the main website

```shell
cd pwa
npm install
npm run lint
npm run dev
```

### If the sky falls on your head

```bash
sudo rm -rf node_modules
sudo rm -rf package-lock.json
npm install
npm run dev
```

### DEV NOTE

How this trait will be displayed (options are number, boost_percentage, boost_number, and date
