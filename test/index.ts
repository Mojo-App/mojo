import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers, upgrades } from "hardhat";

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
    mojoCore = await upgrades.deployProxy(MojoCore, [
      "https://testnet.tableland.network/query?s=",
      "not.implemented.com",
      "Fresh Jams"
    ], {
      kind: "uups",
    });

    await mojoCore.deployed();
    await mojoCore.connect(accounts[0]).createMetadataTable(registry.address);
  });

  it("Should allow minting", async function () {
    const tx = await mojoCore
      .connect(accounts[0])
      .safeMint(accounts[0].address, {
        name:"Test NFT Mint No 1",
        decimals: 0,
        description: "Test NFT description no 1",
        image: ""
      },
      "Fresh Jams");

    const receipt = await tx.wait();
    const [, transferEvent] = receipt.events ?? [];
    const tokenId1 = transferEvent.args!.tokenId;

    const tx2 = await mojoCore
      .connect(accounts[1])
      .safeMint(accounts[1].address, {
        name:"Test NFT Mint No 2",
        decimals: 0,
        description: "Test NFT description no 2",
        image: ""
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

  it("Should allow updating category", async function () {
    // mint the token
    const tx = await mojoCore
      .connect(accounts[1])
      .safeMint(accounts[1].address, {
        name:"Test NFT Mint",
        decimals: 0,
        description: "Test NFT description",
        image: ""
      }, "Fresh Jams");

    const receipt = await tx.wait();
    const [, transferEvent] = receipt.events ?? [];
    const tokenId = transferEvent.args!.tokenId;

    const statement =
      "UPDATE mojo_80001_1199 SET category = 'Best Beats' WHERE id = 0;";

    // TODO: this fails with `expected [] to equal []` because Array literals aren't equal
    //       I can't find a way to change the comparison logic for emit tests
    await expect(mojoCore.connect(accounts[1]).updateAID(tokenId, "Best Beats"))
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

  it("Should allow updating aid", async function () {
    // mint the token
    const tx = await mojoCore
      .connect(accounts[1])
      .safeMint(accounts[1].address, {
        name:"Test NFT Mint",
        decimals: 0,
        description: "Test NFT description",
        image: ""
      }, "Fresh Jams");

    const receipt = await tx.wait();
    const [, transferEvent] = receipt.events ?? [];
    const tokenId = transferEvent.args!.tokenId;

    const statement =
      "UPDATE mojo_80001_1199 SET aid = 10 WHERE id = 0;";

    // TODO: this fails with `expected [] to equal []` because Array literals aren't equal
    //       I can't find a way to change the comparison logic for emit tests
    await expect(mojoCore.connect(accounts[1]).updateAID(tokenId, 10))
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

  it("Should allow updating gid", async function () {
    // mint the token
    const tx = await mojoCore
      .connect(accounts[1])
      .safeMint(accounts[1].address, {
        name:"Test NFT Mint",
        decimals: 0,
        description: "Test NFT description",
        image: ""
      }, "Fresh Jams");

    const receipt = await tx.wait();
    const [, transferEvent] = receipt.events ?? [];
    const tokenId = transferEvent.args!.tokenId;

    const statement =
      "UPDATE mojo_80001_1199 SET gid = 10 WHERE id = 0;";

    // TODO: this fails with `expected [] to equal []` because Array literals aren't equal
    //       I can't find a way to change the comparison logic for emit tests
    await expect(mojoCore.connect(accounts[1]).updateAID(tokenId, 10))
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
