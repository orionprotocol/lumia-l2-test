const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy LumiaToken
  const LumiaToken = await hre.ethers.getContractFactory("LumiaToken");
  const initialSupply = hre.ethers.utils.parseEther("1000000000"); // 1 billion LUMIA
  const lumiaToken = await LumiaToken.deploy(initialSupply);
  await lumiaToken.deployed();
  console.log("LumiaToken deployed to:", lumiaToken.address);

  // Deploy LumiaDEX
  const LumiaDEX = await hre.ethers.getContractFactory("LumiaDEX");
  const lumiaDEX = await LumiaDEX.deploy(lumiaToken.address);
  await lumiaDEX.deployed();
  console.log("LumiaDEX deployed to:", lumiaDEX.address);

  // For demonstration purposes, deploy a mock ERC20 token
  const MockToken = await hre.ethers.getContractFactory("LumiaToken");
  const mockToken = await MockToken.deploy(initialSupply);
  await mockToken.deployed();
  console.log("MockToken deployed to:", mockToken.address);

  // Create liquidity pool for mock token
  await lumiaDEX.createLiquidityPool(mockToken.address);
  console.log("Liquidity pool created for MockToken");

  // Add initial liquidity
  const initialLiquidity = hre.ethers.utils.parseEther("1000000"); // 1 million of each token
  await lumiaToken.approve(lumiaDEX.address, initialLiquidity);
  await mockToken.approve(lumiaDEX.address, initialLiquidity);
  await lumiaDEX.addLiquidity(mockToken.address, initialLiquidity, initialLiquidity);
  console.log("Initial liquidity added to the pool");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });