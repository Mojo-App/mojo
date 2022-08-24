import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("MojoCore", function () {
  let accounts: SignerWithAddress[];
  let registry: any;
  let mojoCore: any;

  beforeEach(async function () {
    accounts = await ethers.getSigners();

    const RegistryFactory = await ethers.getContractFactory("TablelandTables");
    registry = await RegistryFactory.deploy();
    await registry.deployed();
    await registry.connect(accounts[0]).initialize("http://localhost:8080/");

    const MojoCore = await ethers.getContractFactory("MojoCore");
    mojoCore = await MojoCore.deploy(registry.address);
    await mojoCore.deployed();
  });

  it("Should allow minting", async function () {
    const tx = await mojoCore
      .connect(accounts[0])
      .safeMint(accounts[0].address, {
        name:"Test NFT Mint No 1",
        decimals: 0,
        description: "Test NFT description no 1",
        image: "",
        properties: {
          type: "mNFT",
          authors: [{ name: "Mojo NFT" }]
        }
      }, "Fresh Jams");

    const receipt = await tx.wait();
    const [, transferEvent] = receipt.events ?? [];
    const tokenId1 = transferEvent.args!.tokenId;

    const tx2 = await mojoCore
      .connect(accounts[1])
      .safeMint(accounts[1].address, {
        name:"Test NFT Mint No 2",
        decimals: 0,
        description: "Test NFT description no 2",
        image: "",
        properties: {
          type: "mNFT",
          authors: [{ name: "Mojo NFT" }]
        }
      }, "Fresh Jams");

    const receipt2 = await tx2.wait();
    const [, transferEvent2] = receipt2.events ?? [];
    const tokenId2 = transferEvent2.args!.tokenId;

    await expect(tokenId1).to.equal(0);
    await expect(tokenId2).to.equal(1);
  });

  it("Should make contract owner of the table", async function () {
    const owner = await registry.connect(accounts[0]).ownerOf(1);

    await expect(owner).to.equal(mojoCore.address);
  });

  it("Should allow updating aid and gid", async function () {
    // mint the token
    const tx = await mojoCore
      .connect(accounts[1])
      .safeMint(accounts[1].address, {
        name:"Test NFT Mint",
        decimals: 0,
        description: "Test NFT description",
        image: "",
        properties: {
          type: "mNFT",
          authors: [{ name: "Mojo NFT" }]
        }
      }, "Fresh Jams");

    const receipt = await tx.wait();
    const [, transferEvent] = receipt.events ?? [];
    const tokenId = transferEvent.args!.tokenId;

    const statement =
      "UPDATE mojo_80001_1 SET x = 10 AND y = 10 WHERE id = 0;";

    // TODO: this fails with `expected [] to equal []` because Array literals aren't equal
    //       I can't find a way to change the comparison logic for emit tests
    await expect(mojoCore.connect(accounts[1]).makeMove(tokenId, 10, 10))
      .to.emit(registry, "RunSQL")
      .withArgs(mojoCore.address, true, 1, statement, [
        true,
        true,
        true,
        "",
        "",
        [],
        [],
      ]);
  });
});
