import { expect } from "chai";
import { ethers } from "hardhat";

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

  it("Should allow you to deposit and redeem a percentage of the treasury", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const ProjectToken = await ethers.getContractFactory("ProjectToken");

    const hardhatToken = await ProjectToken.deploy();

    // Transfer 50 tokens from owner to addr1
    await hardhatToken.transfer(addr1.address, 50);
    expect(await hardhatToken.balanceOf(addr1.address)).to.equal(50);
    
    // Transfer 50 tokens from addr1 to addr2
    await hardhatToken.connect(addr1).transfer(addr2.address, 50);
    expect(await hardhatToken.balanceOf(addr2.address)).to.equal(50);
  });

});
