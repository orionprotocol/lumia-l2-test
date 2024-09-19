# Lumia L2 Engineering Challenge

Welcome to the Lumia L2 Engineering Challenge! This repository contains a decentralized exchange (DEX) smart contract system built on Lumia L2, our zkEVM Layer 2 solution using PolygonCDK. Your task is to identify and fix a critical bug in the system and make improvements where you see fit.

## Project Structure

```
lumia-l2-test/
├── contracts/
│   ├── LumiaToken.sol
│   ├── LumiaDEX.sol
│   ├── LiquidityPool.sol
│   └── interfaces/
│       └── ILumiaToken.sol
├── test/
│   └── LumiaDEX.test.js
├── scripts/
│   └── deploy.js
├── hardhat.config.js
└── package.json
```

## Setup Instructions

1. Clone this repository:
   ```
   git clone https://github.com/lumia-l2/lumia-l2-test.git
   cd lumia-l2-test
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Compile the contracts:
   ```
   npx hardhat compile
   ```

4. Run the tests:
   ```
   npx hardhat test
   ```

## The Bug

Our LumiaDEX contract is designed to allow users to swap between LUMIA tokens and other ERC20 tokens. However, we've noticed a critical issue:

**Expected Behavior (Y)**: When a user swaps a large amount of tokens (e.g., 1,000,000 LUMIA for another token), the transaction should succeed, and they should receive the correct amount of the other token based on the current exchange rate.

**Observed Behavior (X)**: When attempting to swap large amounts of tokens, the transaction reverts with an "insufficient balance" error, even though the user has sufficient balance and has approved the DEX contract to spend their tokens.

Your task is to:

1. Identify the root cause of this bug.
2. Explain why this bug occurs and its potential impact on the DEX.
3. Propose and implement a fix for the bug.
4. Write additional test cases to verify that your fix resolves the issue and doesn't introduce new problems.

## Evaluation Criteria

You will be evaluated based on:

1. Your ability to identify and understand complex smart contract interactions.
2. The depth and clarity of your explanation of the bug and its implications.
3. The effectiveness and efficiency of your proposed fix.
4. The quality and coverage of your additional test cases.
5. Your overall code quality, including readability and adherence to Solidity best practices.

Good luck, and happy debugging!