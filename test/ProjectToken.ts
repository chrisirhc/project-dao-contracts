import { expect } from "chai";
import { ethers } from "hardhat";

describe("ProjectToken contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    const [owner] = await ethers.getSigners();

    const ProjectToken = await ethers.getContractFactory("ProjectToken");
    const TestGoldToken = await ethers.getContractFactory("TestGoldToken");

    const INITIAL_SUPPLY = 100;
    const testGoldToken = await TestGoldToken.deploy(INITIAL_SUPPLY);
    const hardhatToken = await ProjectToken.deploy(INITIAL_SUPPLY, testGoldToken.address);

    const ownerBalance = await hardhatToken.balanceOf(owner.address);
    expect(ownerBalance).to.equal(INITIAL_SUPPLY);
    expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
  });

  it("Should allow you to deposit and redeem the treasury", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const ProjectToken = await ethers.getContractFactory("ProjectToken");
    const TestGoldToken = await ethers.getContractFactory("TestGoldToken");

    const INITIAL_SUPPLY = 50;
    const testGoldToken = await TestGoldToken.deploy(INITIAL_SUPPLY);
    const hardhatToken = await ProjectToken.deploy(INITIAL_SUPPLY, testGoldToken.address);
 
    await testGoldToken.increaseAllowance(hardhatToken.address, INITIAL_SUPPLY);
    await hardhatToken.deposit(50);

    await hardhatToken.reward(addr1.address, 50);
    expect(await hardhatToken.balanceOf(addr1.address)).to.equal(50);
    
    const addr1ToProjectToken = hardhatToken.connect(addr1);
    await addr1ToProjectToken.redeemShares();
    expect(await testGoldToken.balanceOf(addr1.address)).to.equal(50 / 2);
  });

  it("Should allow you to reward a bounty but also take a cut for the project", async function () {
    const [owner, depositorAddr, recipientAddr] = await ethers.getSigners();

    const ProjectToken = await ethers.getContractFactory("ProjectToken");
    const TestGoldToken = await ethers.getContractFactory("TestGoldToken");

    const INITIAL_SUPPLY = 50;
    const testGoldToken = await TestGoldToken.deploy(INITIAL_SUPPLY);
    const projectToken = await ProjectToken.deploy(INITIAL_SUPPLY, testGoldToken.address);
 
    await testGoldToken.transfer(depositorAddr.address, 50);
    const depositorToProjectToken = testGoldToken.connect(depositorAddr);
    await depositorToProjectToken.increaseAllowance(projectToken.address, 50);

    const share = 0.5;
    await projectToken.transact(depositorAddr.address, recipientAddr.address, 50,
        share * 100 * 10 ** 5, 2);

    expect(await testGoldToken.balanceOf(depositorAddr.address)).to.equal(0);

    // Recipient gets part of the bounty
    expect(await testGoldToken.balanceOf(recipientAddr.address)).to.equal(50 * share);

    // Project treasury has increased
    expect(await testGoldToken.balanceOf(projectToken.address)).to.equal(50 * share);

    // Depositor receives a share
    expect(await projectToken.balanceOf(depositorAddr.address)).to.equal(1);
    // Recipient receives a share
    expect(await projectToken.balanceOf(recipientAddr.address)).to.equal(1);

    // If you go through the ProjectDAO contract, you can reward the project's treasury, and take an increased
    // stake/share in the project.
    // Why would you want to do this? You want to incentivize further development on the project?

    // Why don't people pay the person directly? They could. Then there's no stake.

    // If you stop caring for a project, you can simply swap away your tokens or burn to claim the treasury.

  });

});
