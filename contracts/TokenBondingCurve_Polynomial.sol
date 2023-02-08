// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "hardhat/console.sol";

error LowOnTokens(uint amount, uint balance);
error LowOnEther(uint amount, uint balance);

contract TokenBondingCurve_Polynomial is ERC20, Ownable {
    uint256 private _tax;

    uint256 private immutable _exponent;

    uint256 private immutable _constant;

    // The percentage of loss when selling tokens (using two decimals)
    uint256 private constant _LOSS_FEE_PERCENTAGE = 1000;

    /**
     * @dev Constructor to initialize the contract.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param exponent_ The exponent of the equation.
     * @param constant_ The constant of the equation.
     * This works for exponential curves like (x^y)+z with z & y being the variable user controls
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint exponent_,
        uint constant_
    ) ERC20(name_, symbol_) {
        _exponent = exponent_;
        _constant = constant_;
    }

    /**
     * @dev Allows a user to buy tokens.
     * @param _amount The number of tokens to buy.
     */
    function buy(uint256 _amount) external payable {
        uint price = _calculatePriceForBuy(_amount);
        if(msg.value < price) {
            revert LowOnEther(msg.value, address(msg.sender).balance);
        }
        _mint(msg.sender, _amount);
        
        (bool sent,) = payable(owner()).call{value: msg.value - price}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @dev Allows a user to sell tokens at a 10% loss.
     * @param _amount The number of tokens to sell.
     */
    function sell(uint256 _amount) external {
        if(balanceOf(msg.sender) < _amount) {
            revert LowOnTokens(_amount, balanceOf(msg.sender));
        }
        uint256 _price = _calculatePriceForSell(_amount);
        uint tax = _calculateLoss(_price);
        _burn(msg.sender, _amount);
        // console.log(tax, _price - tax);
        _tax += tax;

        (bool sent,) = payable(owner()).call{value: _price - tax}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @dev Allows the owner to withdraw the tax in ETH.
     */
    function withdraw() external onlyOwner {
        if(_tax <= 0) {
            revert LowOnEther(_tax, _tax);
        }
        uint amount = _tax;
        _tax = 0;
        
        (bool sent,) = payable(owner()).call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @dev Returns the current price of the next token based on the bonding curve formula.
     * @return The current price of the next token in wei.
     */
    function getCurrentPrice() external view returns (uint) {
        return _calculatePriceForBuy(1);
    }

    /**
     * @dev Returns the price for buying a specified number of tokens.
     * @param _tokensToBuy The number of tokens to buy.
     * @return The price in wei.
     */
    function calculatePriceForBuy(
        uint256 _tokensToBuy
    ) external view returns (uint256) {
        return _calculatePriceForBuy(_tokensToBuy);
    }

    /**
     * @dev Returns the price for selling a specified number of tokens.
     * @param _tokensToSell The number of tokens to sell.
     * @return The price in wei.
     */
    function calculatePriceForSell(
        uint256 _tokensToSell
    ) external view returns (uint256) {
        return _calculatePriceForSell(_tokensToSell);
    }

    /**
     * @dev Calculates the price for buying tokens based on the bonding curve.
     * @param _tokensToBuy The number of tokens to buy.
     * @return The price in wei for the specified number of tokens.
     */
    function _calculatePriceForBuy(
        uint256 _tokensToBuy
    ) private view returns (uint256) {
        uint ts = totalSupply();
        uint tsa = ts + _tokensToBuy;
        return auc(tsa) - auc(ts);
    }


    /**
     * @dev Calculates the price for selling tokens based on the bonding curve.
     * @param _tokensToSell The number of tokens to sell.
     * @return The price in wei for the specified number of tokens
     */
    function _calculatePriceForSell(
        uint256 _tokensToSell
    ) private view returns (uint256) {
        uint ts = totalSupply();
        uint tsa = ts - _tokensToSell;
        return auc(ts) - auc(tsa);
    }

    /**
     * @dev calculates area under the curve 
     * @param x value of x
     */
    function auc(uint x) internal view returns (uint256) {
        uint _exp_inc = _exponent + 1;
        return ((x **_exp_inc) + (_exp_inc * _constant * x)) / _exp_inc ;
    }

    /**
     * @dev Calculates the loss for selling a certain number of tokens.
     * @param amount The price of the tokens being sold.
     * @return The loss in wei.
     */
    function _calculateLoss(uint256 amount) private pure returns (uint256) {
        return (amount * _LOSS_FEE_PERCENTAGE) / (1E4);
    }

    function viewTax() external view onlyOwner returns (uint256) {
        return _tax;
    }
}