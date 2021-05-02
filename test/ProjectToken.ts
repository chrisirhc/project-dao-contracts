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

  it("Should allow you to deposit and redeem the treasury", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const ProjectToken = await ethers.getContractFactory("ProjectToken");
    const TestGoldToken = await ethers.getContractFactory("TestGoldToken");

    const INITIAL_SUPPLY = 50;
    const hardhatToken = await ProjectToken.deploy(INITIAL_SUPPLY);
    const testGoldToken = await TestGoldToken.deploy(INITIAL_SUPPLY);
 
    await testGoldToken.increaseAllowance(hardhatToken.address, INITIAL_SUPPLY);
    await hardhatToken.deposit(testGoldToken.address, 50);

    await hardhatToken.reward(addr1.address, 50);
    expect(await hardhatToken.balanceOf(addr1.address)).to.equal(50);
    
    const addr1ToProjectToken = await hardhatToken.connect(addr1);
    await addr1ToProjectToken.redeemShares(testGoldToken.address);
    expect(await testGoldToken.balanceOf(addr1.address)).to.equal(50 / 2);
  });

});
