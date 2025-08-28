// SPDX-License-Identifier: MIT

/// @title SafeContract for BuildsWithKing-ReentrancyGuard. 
/// @author Michealking (@BuildsWithKing).
/// @notice Created on 24th of Aug, 2025. 

/** This contract applied the CEI (check effect interaction pattern) and 
    uses reentrancy guard as part of its security best practices. 
 */

pragma solidity ^0.8.30;

/// @notice Imports ReentrancyGuard contract. 
import {ReentrancyGuard} from "./ReentrancyGuard.sol";

contract SafeContract is ReentrancyGuard {

// ----------------------------------- Custom Errors ------------------------------------------

/// @dev Thrown when users tries depositing ETH lower than mininum. 
error AmountTooLow();

/// @dev Thrown when user tries withdrawing on a low balance. 
error BalanceTooLow();

/// @dev Thrown when users withdrawal fails. 
error WithdrawalFailed();

// ----------------------------------- Variable Assignment --------------------------------------

    /// @notice owner's address assignment. 
    address immutable owner; 

    /// @notice Sets minimum deposit amount to $5. 
    uint256 constant MINIMUM_DEPOSIT = 0.001 ether;
    
// --------------------------------------- Mapping -----------------------------------------------

    /// @dev Maps user's address to their balance. 
    mapping (address => uint256) private userBalance;

// ---------------------------------------- Events ------------------------------------------------

    /// @notice Emits EthDeposited.
    /// @param userAddress The depositor's address. 
    /// @param ethAmount Amount of ETH deposited. 
    event EthDeposited(
        address indexed userAddress,
        uint256 ethAmount
    );

    /// @notice Emit EthWithdrawn.
    /// @param userAddress The user's withdrawal address. 
    /// @param ethAmount Amount of ETH withdrawn. 
    event EthWithdrawn(
         address indexed userAddress,
        uint256 ethAmount
    );

// ---------------------------------------- Constructor -------------------------------------------

    /// @notice Set owner as contract deployer.
    constructor() {
        owner = msg.sender;
    }

// ------------------------------------- Users Write Functions -------------------------------------

    /// @notice Allows users deposit ETH. 
    function depositETH() external payable {
        
        // Prevent users from depositing amount less than minimum. 
        if (msg.value < MINIMUM_DEPOSIT) 
        revert AmountTooLow();

        // Increment user's balance.
        userBalance[msg.sender] += msg.value;

        // Emit event EthDeposited. 
        emit EthDeposited(msg.sender, msg.value);
    }

    /// @notice Allows users withdraw ETH. 
    /// @param _amount ETH amount. 
    function withdrawETH(uint256 _amount) external nonReentrant {

        // Prevent users from withdrawing funds greater than balance. 
        if(_amount > userBalance[msg.sender]) 
        revert BalanceTooLow(); 

        // Deduct amount from user's balance. 
        userBalance[msg.sender] -= _amount;

        // Fund user amount withdrawn. 
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if(!success) 
        revert WithdrawalFailed(); 

        // Emit event EthWithdrawn. 
        emit EthWithdrawn(msg.sender, _amount);
    }

// ----------------------------------------- Users Read Functions ------------------------------------------

    /// @notice Returns contract balance.
    /// @return Contract balance. 
    function getContractBalance() external view returns(uint256) {
        return address(this).balance;
    }

    /// @notice Returns user's balance.
    /// @return User's balance. 
    function getMyBalance() external view returns(uint256) {
        return userBalance[msg.sender];
    }

    /// @notice Returns owner's address.
    /// @return Owner's address. 
    function getOwner() external view returns(address) {
        return owner;
    }

// ----------------------------------------- Receive & FallBack Function ----------------------------------

    /// @notice Accepts ETH deposit without calldata. 
    receive() external payable {
         
        // Prevent users from depositing amount less than minimum. 
        if (msg.value < MINIMUM_DEPOSIT) 
        revert AmountTooLow();

        // Increment user's balance.
        userBalance[msg.sender] += msg.value;

         // Emit event EthDeposited. 
        emit EthDeposited(msg.sender, msg.value);
    }

    /// @notice Accepts ETH deposit with calldata. 
    fallback() external payable {

        // Prevent users from depositing amount less than minimum. 
        if (msg.value < MINIMUM_DEPOSIT) 
        revert AmountTooLow();

        // Increment user's balance.
        userBalance[msg.sender] += msg.value;
         
         // Emit event EthDeposited. 
        emit EthDeposited(msg.sender, msg.value);
    }
}