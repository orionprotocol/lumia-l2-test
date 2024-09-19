const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LumiaDEX", function () {
  let LumiaToken, LumiaDEX, lumiaToken, lumiaDEX, owner, user1, user2;
  const INITIAL_SUPPLY = ethers.utils.parseEther("1000000000");
  const LARGE_AMOUNT = ethers.utils.parseEther("1000000");

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    LumiaToken = await ethers.getContractFactory("LumiaToken");
    lumiaToken = await LumiaToken.deploy(INITIAL_SUPPLY);
    await lumiaToken.deployed();

    LumiaDEX = await ethers.getContractFactory("LumiaDEX");
    lumiaDEX = await LumiaDEX.deploy(lumiaToken.address);
    await lumiaDEX.deployed();

    // Create a mock ERC20 token for testing
    const MockToken = await ethers.getContractFactory("LumiaToken");
    mockToken = await MockToken.deploy(INITIAL_SUPPLY);
    await mockToken.deployed();

    // Create liquidity pool
    await lumiaDEX.createLiquidityPool(mockToken.address);

    // Add initial liquidity
    const initialLiquidity = ethers.utils.parseEther("1000000");
    await lumiaToken.approve(lumiaDEX.address, initialLiquidity);
    await mockToken.approve(lumiaDEX.address, initialLiquidity);
    await lumiaDEX.addLiquidity(mockToken.address, initialLiquidity, initialLiquidity);

    // Transfer some tokens to user1
    await lumiaToken.transfer(user1.address, LARGE_AMOUNT);
    await mockToken.transfer(user1.address, LARGE_AMOUNT);
  });

  it("should allow swapping large amounts of tokens", async function () {
    // Approve DEX to spend user's tokens
    await lumiaToken.connect(user1).approve(lumiaDEX.address, LARGE_AMOUNT);

    // Attempt to swap a large amount of LUMIA for the mock token
    await expect(
      lumiaDEX.connect(user1).swapLumiaForToken(mockToken.address, LARGE_AMOUNT)
    ).to.be.revertedWith("Insufficient balance");

    // This test should fail, revealing the bug
  });
});