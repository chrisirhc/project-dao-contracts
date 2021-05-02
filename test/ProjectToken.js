const { expect } = require("chai");

describe("ProjectToken contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    const [owner] = await ethers.getSigners();

    const ProjectToken = await ethers.getContractFactory("ProjectToken");

    const INITIAL_SUPPLY = 100;
    const hardhatToken = await ProjectToken.deploy(INITIAL_SUPPLY);

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(ownerBalance).to.equal(INITIAL_SUPPLY);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });
});
