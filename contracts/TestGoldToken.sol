// Test token
// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/** 
 * @title TestGoldToken
 */
contract TestGoldToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Test GOLD", "GOLD") {
        _mint(msg.sender, initialSupply);
    }
}