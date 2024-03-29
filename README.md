# Mojo Music

Mojo is an audio/media streaming platform that empowers artists and content creators through web3 and blockchain technologies.

The Mojo web3 application allows users to upload their valuable digital assets easily and seamlessly to the IPFS Network via our user interface. Files cannot get deleted, hacked, edited, stolen and are never saved to a server making them truly decentralised.

Creators can finally mint NFTs for music and sound tracks and customize the metadata attributes based on the media type. Creators will be able to manage their Mojo Music NFTs using Tableland's relational metadata protocol for EVM chains. This freedom allows you to update non-essential data, yet keeping the true values of the non-fungible token in tack and aligned with core NFT values and standards.

Music platforms and streaming is not new technology. However, IPFS is still new enough that streaming is not yet native to its content delivery. IPFS is a wonderful technology as it allows for content ownership, portability, and verifiability. It powers NFT marketplaces, individual websites, file-sharing platforms, and so much more.

However, IPFS, the protocol, does not have a responsibility to match the experience of traditional cloud file services. Instead, that responsibility falls onto the shoulders of the IPFS adopters.

Mojo helps fill this gap and gives musicians, artists and all content creators an opportunity to broaden their social reach by offering specially crafted audio and media NFTs that allow their followers and subscribers to access bonus content and features. This can include airdrops, bonus videos or written content for example.

Mojo aims to further it's product by building the following key features in web3 application:

1. Artists should be able to upload their content in a secure and friendly manner.
2. Listeners/viewers should be able to view music streams on the platform free of charge
3. The platform should offer cryptocurrency-based payments to artists and their audiences.
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

## Technology Stack

Mojo was built with or uses the following technologies in it's software life cycle:

Etheruem (Solidity) - Smart contracts written in Solidity

### Tableland

Tableland is a web3-native database that can be used to store data in relational tables. One of the most exciting use cases is using Tableland for NFT metadata — which is a challenging problem in web3, especially for novel dynamic NFT use cases. Developers must make tradeoffs between:

1. Expensive on-chain storage with very limited query-ability
2. Centralized storage, which doesn’t enable web3 paradigms
3. Decentralized storage (e.g., IPFS), which is great for file/image storage, but immutable files (CIDs) pose a challenge for novel NFT metadata use cases

Tableland solves the web3 metadata problem with ERC721-based tables that are powered by smart contracts. Create, insert, and update tables, all using smart contracts and/or libraries built on top of Tableland smart contracts. The metadata can also be dynamic and change based on user interactions or on-chain events. The Tableland contracts are currently deployed on Polygon mainnet & Mumbai testnet, as well as a number of other chains with more coming soon.

### NFTPort Enhanced APIs 🦸🏻

NFTPort provide core products which make the developer experience as easy as possible and accelerate NFT application development. All of them enable to focus on building the best product for your users, instead of reinventing the NFT infrastructure wheel.

NFTPort provide enhanced APIs for Text Search so you don't have to build your own NFT database, Content NFTID which enables to find similar and duplicate NFTs to increase customer loyalty and an NFT Recommendation Engine to increase revenue.

### IPFS, Filecoin and NFT.Storage

The Interplanetary File System (IPFS) is a decentralized file system for building the next generation of the internet. Filecoin (opens new window) and many popular Web3 projects are built on IPFS. Some call it the hard drive for blockchain and Web3, though its power extends much further.

NFT.Storage is a long-term storage service designed for off-chain NFT data (like metadata, images, and other assets). Data is content addressed using IPFS, meaning the URI pointing to a piece of data (“ipfs://…”) is completely unique to that data (using a content identifier, or CID). IPFS URLs and CIDs can be used in NFTs and metadata to ensure the NFT forever actually refers to the intended data (eliminating things like rug pulls, and making it trustlessly verifiable what content an NFT is associated with).

🧪 Craig Moss
Twitter: [@webmoss](https://twitter.com/webmoss)
LinkedIn: (<https://www.linkedin.com/in/craig-moss-21822628/>)

## Deployments Note

Deploying to network 'polygon-mumbai' with account 0x79bFCD02241719B49Eab19630a62F3c8429F7f6D

Tableland Address :  0x4b48841d4b32C4650E4ABc117A03FE8B51f38F68

Mojo Creators NFTs contract deployed on polygon-mumbai at: 0x2c1B4950d62C522eE010158B56f9430ad0966060

Mojo Creators Main Table: Mojo_Creators_80001_3849
Mojo Creators Attributes Table : Mojo_Creators_80001_3850

<https://testnet.tableland.network/query?mode=list&s=SELECT%20json_object%28%27id%27%2Ctokenid%2C%27name%27%2Cname%2C%27description%27%2Cdescription%2C%27image%27%2Cimage%2C%27address%27%2Caddress%2C%27slogan%27%2Cslogan%2C%27profile_img%27%2Cprofile_img%2C%27banner_img%27%2Cbanner_img%2C%27website%27%2Cwebsite%2C%27attributes%27%2Cjson_group_array%28json_object%28%27icon%27%2Cicon%2C%27display_type%27%2Cdisplay_type%2C%27trait_type%27%2Ctrait_type%2C%27value%27%2Cvalue%29%29%29%20FROM%20Mojo_Creators_80001_3849%20JOIN%20Mojo_Creators_80001_3850%20ON%20Mojo_Creators_80001_3849%2Etokenid%20%3D%20Mojo_Creators_80001_3850%2Emaintable_tokenid%20WHERE%20tokenid%3D0%20group%20by%20tokenid>

Mojo Music NFTs contract deployed on polygon-mumbai at addresss: 0x4dBaa276d66B5dEAAc9Ca718773a7CE09f989741

Mojo Music NFT Main Table: Mojo_Music_80001_3847
Mojo Music NFT Attributes Table : Mojo_Music_80001_3848

<https://testnet.tableland.network/query?mode=list&s=SELECT%20json_object%28%27id%27%2Ctokenid%2C%27name%27%2Cname%2C%27description%27%2Cdescription%2C%27image%27%2Cimage%2C%27category%27%2Ccategory%2C%27external_url%27%2Cexternal_url%2C%27background_color%27%2Cbackground_color%2C%27animation_url%27%2Canimation_url%2C%27youtube_url%27%2Cyoutube_url%2C%27attributes%27%2Cjson_group_array%28json_object%28%27icon%27%2Cicon%2C%27display_type%27%2Cdisplay_type%2C%27trait_type%27%2Ctrait_type%2C%27value%27%2Cvalue%29%29%29%20FROM%20Mojo_Music_80001_3847%20JOIN%20Mojo_Music_80001_3848%20ON%20Mojo_Music_80001_3847%2Etokenid%20%3D%20Mojo_Music_80001_3848%2Emaintable_tokenid%20WHERE%20tokenid%3D0%20group%20by%20tokenid>

```shell
npx hardhat run scripts/deploy.js --network polygon-mumbai
npx hardhat run scripts/deployMCNFT.js --network polygon-mumbai
```

## Verify Contracts Note

Mojo Creators

```shell

```

Mojo Music NFTS

```shell
npx hardhat run scripts/verify.js --network polygon-mumbai
Nothing to compile
No need to generate any newer typings.
Successfully submitted source code for contract
contracts/mojo_ERC721.sol:MOJO at 0x4dBaa276d66B5dEAAc9Ca718773a7CE09f989741
for verification on the block explorer. Waiting for verification result...

Successfully verified contract MOJO on Etherscan.
https://mumbai.polygonscan.com/address/0x4dBaa276d66B5dEAAc9Ca718773a7CE09f989741#code
```

You will need to verify your contracts as below.

```shell
npx hardhat run scripts/verify.js --network polygon-mumbai
npx hardhat run scripts/verifyMCNFT.js --network polygon-mumbai
```

## Hardhat Project Setup

This project uses Hardhat to test, compile and deploy contracts.
Try running some of the following tasks from the project root to interact with the smart contracts.

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

## Basic Vue 3 Project using Vite and Pinia

This project uses Vue 3 for the front-end, Pinia for store management and web3 libraries to integrate with the Ethereum blockcahin and other cutting edge blockchain technologies including Tableland, NFT.Storage, IPFS, NFT Port, Infura and more.

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
