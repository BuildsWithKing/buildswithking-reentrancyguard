// SPDX-License-Identifier: MIT

/// @title VulnerableContractTest for BuildsWithKing-ReentrancyGuard. 
/// @author Michealking (@BuildsWithKing).
/// @notice Created on 27th of Aug, 2025. 

pragma solidity ^0.8.30;

/// @notice Imports Test from forge standard library, VulnerableContract and RejectETHTest. 
import {Test} from "forge-std/Test.sol";
import {VulnerableContract} from "../src/VulnerableContract.sol";
import {RejectETHTest} from "./RejectETHTest.t.sol";

contract VulnerableContractTest is Test {

// -------------------------------------------- Variable Assignment ---------------------------------

    /// @notice Assigns vulnerable contract. 
    VulnerableContract vulnerableContract;

    /// @notice Assgins owner, user1, user2, STARTING_BALANCE and ETH_AMOUNT.  
    address owner = address(this);
    address user1 = address(0x1);
    address user2 = address(0x2);
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant ETH_AMOUNT = 1 ether;

    /// @notice Setup test runs before every other tests. 
    function setUp() external {

    // Create new instance of vulnerable contract. 
    vulnerableContract = new VulnerableContract();

    // Fund user1 with 10 ether. 
    vm.deal(user1, STARTING_BALANCE);
    }
    
// ------------------------------------------- Test for depositETH Function. ----------------------------------

    /// @notice Test for "deposit ETH". 
    function testUserCanDepositETH() external {

        // Fund contract as user1. 
        vm.startPrank(user1);
        vm.expectEmit(true, false, false, true);
        emit VulnerableContract.EthDeposited(user1,ETH_AMOUNT);
        vulnerableContract.depositETH{value: ETH_AMOUNT}();

        // Assign user1 balance. 
        uint256 myBalance = vulnerableContract.getMyBalance();

        // Stop prank. 
        vm.stopPrank();

        // Assert both are Equal. 
        assertEq(myBalance, ETH_AMOUNT);
    }

    /// @notice Test users cant deposit less than the minimum ETH amount. 
    function testUserCantDepositLessThanTheMinimum() external {
        
        // Revert with error message "AmountTooLow".
        vm.expectRevert(VulnerableContract.AmountTooLow.selector);

        // Fund contract as user2. 
        vm.prank(user2);
        vulnerableContract.depositETH{value: 0}();
    }

// --------------------------------------- Test for WithdrawETH Function -----------------------------

    /// @notice Test users can withdraw ETH. 
    function testUserCanWithdrawETH() external {

        // Fund contract as user1. 
        vm.startPrank(user1);
        vm.expectEmit(true, false, false, true);
        emit VulnerableContract.EthDeposited(user1,ETH_AMOUNT);
        vulnerableContract.depositETH{value: ETH_AMOUNT}();

        // Assign contract balance before. 
        uint256 balanceBefore = address(vulnerableContract).balance;

        // Assign user1 balance before. 
        uint256 user1BalanceBefore = user1.balance;

        // Emit Message "EthWithdrawn". 
        vm.expectEmit(true, false, false, true);
        emit VulnerableContract.EthWithdrawn(user1, ETH_AMOUNT);

        // Withdraw ETH.
        vulnerableContract.withdrawETH(ETH_AMOUNT);

        uint256 user1BalanceAfter = user1.balance;

        // Assign contract balance after. 
        uint256 balanceAfter = address(vulnerableContract).balance;

        // Stop prank. 
        vm.stopPrank();

        // Assert Balance before is greater than balance after withdrawal. 
        assertGt(balanceBefore, balanceAfter); 

         // Assert user1 balance before is greater than user1 balance after withdrawal. 
        assertGt(user1BalanceAfter, user1BalanceBefore);  
    }

    /// @notice Test user with no deposit cant withdraw. 
    function testUserWithNoDepositCantWithdraw() external {

        // Revert with message "BalanceTooLow". 
        vm.expectRevert(VulnerableContract.BalanceTooLow.selector);

        // Write as user2. 
        vm.prank(user2);
        vulnerableContract.withdrawETH(ETH_AMOUNT);
    }

    /// @notice Test for withdrawal failed. 
    function testWithdrawalFailed() external {

        // Create new instance of RejectETHTest. 
        RejectETHTest rejector = new RejectETHTest();

        // Fund rejector with 10 ether.
        vm.deal(address(rejector), STARTING_BALANCE);  

        // Fund contract as rejectETH. 
        vm.startPrank(address(rejector));
        vulnerableContract.depositETH{value: ETH_AMOUNT}();

        // Revert with message "WithdrawalFailed". 
        vm.expectRevert(VulnerableContract.WithdrawalFailed.selector);
        vulnerableContract.withdrawETH(ETH_AMOUNT);

        // Stop prank. 
        vm.stopPrank();
    }

// ------------------------------------------ Test for User's Read Functions. -------------------------------

    /// @notice Test to get contract balance. 
    function testGetContractBalance() external {

        // Write as user2. 
        vm.prank(user2);
        uint256 contractBalance = vulnerableContract.getContractBalance();

        // Assert Both are Equal. 
        assertEq(contractBalance, 0);
    }

    /// @notice Test for get owner. 
    function testGetOwner() external {

        // Write as user1. 
        vm.prank(user1);

        // Assign contract owner. 
        address contractOwner = vulnerableContract.getOwner();

        // Assert both are same. 
        assertEq(contractOwner, owner);
    }

// ----------------------------------------- Test for Receive & Fallback. -------------------------------

    /// @notice Test for receive ETH.
    function testReceive() external {

        // Write as user1. 
        vm.prank(user1);
        (bool success,) = address(vulnerableContract).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assign contract balance. 
        uint256 contractBalance = address(vulnerableContract).balance;

        // Assert both are same. 
        assertEq(contractBalance, ETH_AMOUNT);
    }

      /// @notice Test for fallback.
    function testFallback() external {

        // Write as user1. 
        vm.prank(user1);
        (bool success,) = address(vulnerableContract).call{value: ETH_AMOUNT}("abcd0xx115");
        assertTrue(success);

        // Assign contract balance. 
        uint256 contractBalance = address(vulnerableContract).balance;

        // Assert both are same. 
        assertEq(contractBalance, ETH_AMOUNT);
    }
}