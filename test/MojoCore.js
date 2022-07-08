const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require('hardhat');

describe('MojoCore', function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshopt in every test.
  async function mojoCoreFixture() {
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    const ONE_GWEI = 1_000_000_000;

    const lockedAmount = ONE_GWEI;
    const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const MojoCore = await ethers.getContractFactory("MojoCore");
    const mojo = await MojoCore.deploy(unlockTime, { value: lockedAmount });

    return { mojo, unlockTime, lockedAmount, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { mojo, owner } = await loadFixture(mojoCoreFixture);
      expect(await mojo.owner()).to.equal(owner.address);
    });

    it("Should return the new greeting once it's changed", async function () {
      const MojoCore = await ethers.getContractFactory('MojoCore');
      const mojo = await MojoCore.deploy('Let\'s go Boyz!');

      await mojo.deployed();

      const withdrawTx = await mojo.withdraw();
      // wait until the transaction is mined
      await withdrawTx.wait();
      expect(await mojo.withdraw()).to.equal(lockedAmount);
    });
  });
});
