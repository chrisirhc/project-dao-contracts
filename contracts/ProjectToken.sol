// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/** 
 * @title ProjectToken
 * @dev Implements a kind of treasury manager.
 */
contract ProjectToken is ERC20 {
    using SafeERC20 for IERC20;

    address public chairperson;
    mapping(address => uint) public balanceOfTreasury;

    /** 
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param initialSupply starting number of totalShares
     */
    constructor(uint256 initialSupply) ERC20("Project", "PRJ") {
        chairperson = msg.sender;
        _mint(msg.sender, initialSupply);
    }
    
    /** 
     * @dev Give 'rewardee' shares
     * @param rewardee receiving shares
     * @param newShare to be received
     */
    function reward(address rewardee, uint256 newShare) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give rewards."
        );
        _mint(rewardee, newShare);
    }
    
    uint public SHARE_DECIMALS = 5;
    uint public SHARE_MULTIPLIER = 10^SHARE_DECIMALS;

    /**
     * @dev get the percentage share for the shareholder with 5 decimal points
     * @param shareholder address to check
     */
    function getShare(address shareholder) public view returns (uint256 share_) {
        return balanceOf(shareholder) * SHARE_MULTIPLIER / totalSupply();
    }
    
    /** 
     * @dev Deposit into the treasury
     * @param erc20token to deposit
     * @param amountToDeposit into the treasury
     */
    function deposit(address erc20token, uint256 amountToDeposit) public {
        // That's why you need to call approve first, which is another method that we need to pass.
        IERC20(erc20token).safeTransfer(address(this), amountToDeposit);
        balanceOfTreasury[erc20token] += amountToDeposit;
    }

    /** 
     * @dev Deposit into the treasury
     * @param erc20token to redeem
     */
    function redeemShares(address erc20token) public {
        require(
            msg.sender != chairperson,
            "Chairperson cannot redeem shares"
        );
        uint share = balanceOf(msg.sender);
        uint amountToRedeem = balanceOfTreasury[erc20token] * share / totalSupply();
        IERC20(erc20token).safeTransferFrom(address(this), msg.sender, amountToRedeem);
        balanceOfTreasury[erc20token] -= amountToRedeem;
        _burn(msg.sender, share);
    }
}
