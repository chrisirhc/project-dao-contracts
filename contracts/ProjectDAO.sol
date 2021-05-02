// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title ProjectDAO
 * @dev Implements a kind of treasury manager.
 */
contract ProjectDAO {

    address public chairperson;

    mapping(address => uint) public balanceOfShares;
    uint public totalShares; // Total supply of shares
    
    mapping(address => uint) public balanceOfTreasury;

    /** 
     * @dev Create a new ballot to choose one of 'proposalNames'.
     * @param startingTotalShares starting number of totalShares
     */
    constructor(uint startingTotalShares) {
        chairperson = msg.sender;
        totalShares = startingTotalShares;
        // Initializer owns all the shares at the beginning
        balanceOfShares[chairperson] = totalShares;
    }
    
    /** 
     * @dev Give 'rewardee' shares
     * @param rewardee receiving shares
     * @param newShare to be received
     */
    function reward(address rewardee, uint newShare) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give rewards."
        );
        balanceOfShares[rewardee] = newShare;
        totalShares += newShare;
    }
    
    uint public SHARE_DECIMALS = 5;
    uint public SHARE_MULTIPLIER = 10^SHARE_DECIMALS;

    /**
     * @dev get the percentage share for the shareholder with 5 decimal points
     * @param shareholder address to check
     */
    function getShare(address shareholder) public view returns (uint share_) {
        return balanceOfShares[shareholder] * SHARE_MULTIPLIER / totalShares;
    }
    
    /** 
     * @dev Deposit into the treasury
     * @param erc20token to deposit
     * @param amountToDeposit into the treasury
     */
    function deposit(address erc20token, uint amountToDeposit) public {
        require(
            msg.sender != chairperson,
            "Chairperson cannot redeem shares"
        );
        
        balanceOfTreasury[erc20token] += amountToDeposit;
        // Simulate deposit happened. Need to call it here.
        // This might be weird because you need to approve the contract calling for the person first.
        // That's why you need to call approve first, which is another method that we need to pass.
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
        uint share = balanceOfShares[msg.sender];
        uint amountToRedeem = balanceOfTreasury[erc20token] * share / totalShares;
        // TransferTo needs to be called on the erc20token using the interface.
        balanceOfTreasury[erc20token] -= amountToRedeem;
        balanceOfShares[msg.sender] = 0;
        totalShares -= share;
    }
}
