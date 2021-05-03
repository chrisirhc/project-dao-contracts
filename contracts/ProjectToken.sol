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
