// SPDX-License-Identifier: MIT

/// @title RejectETH contract for VulnerableContractTest (BuildsWithKing-ReentrancyGuard). 
/// @author Michealking (@BuildsWithKing).
/// @notice Created on 27th of Aug, 2025. 

/// @notice This contract rejects ETH to simulate a "WithdrawalFailed" transaction. 

pragma solidity ^0.8.30;

contract RejectETHTest {

    /// @notice Rejects ETH. 
    receive() external payable {
        revert ("ETH Rejected");
    }
}