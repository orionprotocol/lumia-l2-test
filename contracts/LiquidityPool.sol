// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/ILumiaToken.sol";

contract LiquidityPool is ReentrancyGuard {
    ILumiaToken public lumiaToken;
    IERC20 public token;

    uint256 public lumiaReserve;
    uint256 public tokenReserve;
    uint256 public totalLiquidity;

    mapping(address => uint256) public liquidity;

    uint256 private constant FEES_NUMERATOR = 997;
    uint256 private constant FEES_DENOMINATOR = 1000;

    constructor(address _lumiaToken, address _token) {
        lumiaToken = ILumiaToken(_lumiaToken);
        token = IERC20(_token);
    }

    function addLiquidity(address provider, uint256 lumiaAmount, uint256 tokenAmount) external nonReentrant {
        if (totalLiquidity == 0) {
            totalLiquidity = 1000;
            liquidity[provider] = 1000;
            lumiaReserve = lumiaAmount;
            tokenReserve = tokenAmount;
        } else {
            uint256 liquidityMinted = (lumiaAmount * totalLiquidity) / lumiaReserve;
            require(liquidityMinted > 0, "Insufficient liquidity minted");
            liquidity[provider] += liquidityMinted;
            totalLiquidity += liquidityMinted;
            lumiaReserve += lumiaAmount;
            tokenReserve += tokenAmount;
        }
    }

    function getTokenOutputForLumiaInput(uint256 lumiaAmount) public view returns (uint256) {
        require(lumiaAmount > 0, "Invalid LUMIA amount");
        uint256 lumiaAmountWithFee = lumiaAmount * FEES_NUMERATOR;
        uint256 numerator = lumiaAmountWithFee * tokenReserve;
        uint256 denominator = (lumiaReserve * FEES_DENOMINATOR) + lumiaAmountWithFee;
        return numerator / denominator;
    }

    function getLumiaOutputForTokenInput(uint256 tokenAmount) public view returns (uint256) {
        require(tokenAmount > 0, "Invalid token amount");
        uint256 tokenAmountWithFee = tokenAmount * FEES_NUMERATOR;
        uint256 numerator = tokenAmountWithFee * lumiaReserve;
        uint256 denominator = (tokenReserve * FEES_DENOMINATOR) + tokenAmountWithFee;
        return numerator / denominator;
    }

    function swapLumiaForToken(address recipient, uint256 lumiaAmount, uint256 minTokenOut) external nonReentrant {
        uint256 tokenAmount = getTokenOutputForLumiaInput(lumiaAmount);
        require(tokenAmount >= minTokenOut, "Insufficient output amount");

        lumiaReserve += lumiaAmount;
        tokenReserve -= tokenAmount;

        token.transfer(recipient, tokenAmount);
    }

    function swapTokenForLumia(address recipient, uint256 tokenAmount, uint256 minLumiaOut) external nonReentrant {
        uint256 lumiaAmount = getLumiaOutputForTokenInput(tokenAmount);
        require(lumiaAmount >= minLumiaOut, "Insufficient output amount");

        tokenReserve += tokenAmount;
        lumiaReserve -= lumiaAmount;

        lumiaToken.transfer(recipient, lumiaAmount);
    }
}