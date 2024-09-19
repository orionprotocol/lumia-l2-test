// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/ILumiaToken.sol";
import "./LiquidityPool.sol";

contract LumiaDEX is ReentrancyGuard {
    ILumiaToken public lumiaToken;
    mapping(address => LiquidityPool) public liquidityPools;

    event TokenSwapped(address indexed user, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    constructor(address _lumiaToken) {
        lumiaToken = ILumiaToken(_lumiaToken);
    }

    function createLiquidityPool(address token) external {
        require(address(liquidityPools[token]) == address(0), "Pool already exists");
        liquidityPools[token] = new LiquidityPool(address(lumiaToken), token);
    }

    function addLiquidity(address token, uint256 lumiaAmount, uint256 tokenAmount) external {
        LiquidityPool pool = liquidityPools[token];
        require(address(pool) != address(0), "Pool does not exist");

        lumiaToken.transferFrom(msg.sender, address(pool), lumiaAmount);
        IERC20(token).transferFrom(msg.sender, address(pool), tokenAmount);

        pool.addLiquidity(msg.sender, lumiaAmount, tokenAmount);
    }

    function swapLumiaForToken(address token, uint256 lumiaAmount) external nonReentrant {
        LiquidityPool pool = liquidityPools[token];
        require(address(pool) != address(0), "Pool does not exist");

        uint256 tokenAmount = pool.getTokenOutputForLumiaInput(lumiaAmount);
        require(tokenAmount > 0, "Insufficient liquidity");

        lumiaToken.transferFrom(msg.sender, address(pool), lumiaAmount);
        pool.swapLumiaForToken(msg.sender, lumiaAmount, tokenAmount);

        emit TokenSwapped(msg.sender, address(lumiaToken), token, lumiaAmount, tokenAmount);
    }

    function swapTokenForLumia(address token, uint256 tokenAmount) external nonReentrant {
        LiquidityPool pool = liquidityPools[token];
        require(address(pool) != address(0), "Pool does not exist");

        uint256 lumiaAmount = pool.getLumiaOutputForTokenInput(tokenAmount);
        require(lumiaAmount > 0, "Insufficient liquidity");

        IERC20(token).transferFrom(msg.sender, address(pool), tokenAmount);
        pool.swapTokenForLumia(msg.sender, tokenAmount, lumiaAmount);

        emit TokenSwapped(msg.sender, token, address(lumiaToken), tokenAmount, lumiaAmount);
    }
}