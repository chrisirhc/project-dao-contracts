// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

/** 
 * @title ProjectToken
 * @dev Implements a kind of treasury manager.
 */
contract ProjectToken is ERC20 {
    using SafeERC20 for IERC20;

    address public chairperson;
    address public erc20Token;
    uint256 public balanceOfTreasury;

    /** 
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param initialSupply starting number of totalShares
     * @param _erc20Token to use for treasury
     */
    constructor(uint256 initialSupply, address _erc20Token) ERC20("Project", "PRJ") {
        chairperson = msg.sender;
        erc20Token = _erc20Token;
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
    uint public SHARE_MULTIPLIER = 10 ** SHARE_DECIMALS;

    /**
     * @dev get the percentage share for the shareholder with 5 decimal points
     * @param shareholder address to check
     */
    function getShare(address shareholder) public view returns (uint256 share_) {
        return balanceOf(shareholder) * SHARE_MULTIPLIER / totalSupply();
    }
    
    /** 
     * @dev Deposit into the treasury
     * @param amountToDeposit into the treasury
     */
    function deposit(uint256 amountToDeposit) public {
        IERC20(erc20Token).safeTransferFrom(msg.sender, address(this), amountToDeposit);
        balanceOfTreasury += amountToDeposit;
    }

    /**
     * @dev Transactions that give a cut to the treasury of the project.
     * This will be critical to figure out what the right values are in here.
     * But I'd imagine this to be the critical component of the project.
     * @param depositor with the coins to transfer
     * @param recipient of the coins
     * @param percentageToTreasury to be given to treasury * 10 ** SHARE_DECIMALS
     * @param newShare to be given to the recipient (what about depositor?)
     * Should this have a memo?
     */
    function transact(address depositor, address recipient, uint256 amountToSend,
                      uint256 percentageToTreasury, uint256 newShare) public {
        uint256 amountToTreasury = amountToSend * percentageToTreasury / (100 * 10 ** SHARE_DECIMALS);
        IERC20(erc20Token).safeTransferFrom(depositor, address(this), amountToTreasury);
        IERC20(erc20Token).safeTransferFrom(depositor, recipient, amountToSend - amountToTreasury);
        
        // Key part here is that new shares are only minted once new work is done. ??
        // Incentivizing more work to be done. However, you must make sure that the amount to treasury is always > than 
        // newShare.
        // Why? Because the project needs to gain more than the dilution amount.
        // Everyone else must benefit more than the new depsitor and recipient. 
        // Otherwise, depositor and recipient can coordinate to add "work" in order to gain more shares.
        // In other words newShare / totalNewSupply * treasuryTotal < amountToTreasury
        // In fact, you want it to be much less than the amountToTreasury. You might want it to be even lower than a multiplier
        // of the treasury.
        require(
            balanceOfTreasury * newShare / totalSupply() < amountToTreasury,
            "Minted shares need to be strictly less than the amount to treasury"
        );

        uint256 newShareForRecipient = newShare / 2;
        uint256 newShareForDepositor = newShare - newShareForRecipient;
        _mint(depositor, newShareForDepositor);
        _mint(recipient, newShareForRecipient);
    }

    /** 
     * @dev Deposit into the treasury
     */
    function redeemShares() public {
        require(
            msg.sender != chairperson,
            "Chairperson cannot redeem shares"
        );
        uint share = balanceOf(msg.sender);
        uint amountToRedeem = balanceOfTreasury * share / totalSupply();
        // Pretty sketchy to have this here. Reconsider later.
        IERC20(erc20Token).approve(address(this), amountToRedeem);
        IERC20(erc20Token).safeTransferFrom(address(this), msg.sender, amountToRedeem);
        balanceOfTreasury -= amountToRedeem;
        _burn(msg.sender, share);
    }
}
