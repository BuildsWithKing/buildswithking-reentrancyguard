// SPDX-License-Identifier: MIT

/// @title: ReentrancyGuard
/// @author: Michealking (@BuildsWithKing).
/// @notice Created on 24th of Aug, 2025. 

/**  @notice A reentrancy guard is a piece of code that causes execution to fail when reentrancy is detected.
    This provides the "nonReentrant" modifier. Applying this modifier to a function will render it “non-reentrant”, 
    and attempts to re-enter this function will be rejected by reverting the call.
*/

pragma solidity ^0.8.30;

abstract contract ReentrancyGuard {

// ------------------------------------------------ Custom Error ----------------------------------------------------

/// @dev Thrown when function state is locked. 
error NoReentrancy();

// -------------------------------------------- Enum ----------------------------------------------------------------
    /// @notice Defines function status. 
    enum Status {
        
        // O => Unlocked.
        Unlocked,

        // 1 => Locked. 
        Locked
    }

// ---------------------------------------------- Enum Assignment -----------------------------------------------------
    
    /// @notice Assigns enum variable "state". 
    Status private status;

// ---------------------------------------------- Constructor ---------------------------------------------------------
   
    /// @notice Sets status to unlocked at deployment.  
    constructor() {
        status = Status.Unlocked;
    }

// ----------------------------------------------- Modifier ------------------------------------------------------------

    /// @dev Restricts contract from calling itself directly or indirectly. 
    modifier nonReentrant() {

        // Revert with message `NoReentrancy()`.
        if (status == Status.Locked) {
            revert NoReentrancy();
        }

        // Set function status to locked. 
        status = Status.Locked;
        _;

        // Set function status to unlocked. 
        status = Status.Unlocked;
    }
}