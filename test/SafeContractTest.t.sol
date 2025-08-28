// SPDX-License-Identifier: MIT

/// @title SafeContractTest for BuildsWithKing-ReentrancyGuard. 
/// @author Michealking (@BuildsWithKing).
/// @notice Created on 27th of Aug, 2025. 

pragma solidity ^0.8.30;

/// @notice Imports Test from forge standard library, SafeContract and RejectETHTest. 
import {Test} from "forge-std/Test.sol";
import {SafeContract} from "../src/SafeContract.sol";
import {RejectETHTest} from "./RejectETHTest.t.sol";

contract SafeContractTest is Test {

// -------------------------------------------- Variable Assignment ---------------------------------

    /// @notice Assigns safe contract. 
   SafeContract safeContract;

    /// @notice Assgins owner, user1, user2, STARTING_BALANCE and ETH_AMOUNT.  
    address owner = address(this);
    address user1 = address(0x1);
    address user2 = address(0x2);
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant ETH_AMOUNT = 1 ether;

    /// @notice Setup test runs before every other tests. 
    function setUp() external {

    // Create new instance of safe contract. 
    safeContract = new SafeContract();

    // Fund user1 with 10 ether. 
    vm.deal(user1, STARTING_BALANCE);
    }
    
// ------------------------------------------- Users Write Function. ----------------------------------

    /// @notice Test for "deposit ETH". 
    function testUserCanDepositETH() external {

        // Fund contract as user1. 
        vm.startPrank(user1);
        vm.expectEmit(true, false, false, true);
        emit SafeContract.EthDeposited(user1,ETH_AMOUNT);
        safeContract.depositETH{value: ETH_AMOUNT}();

        // Assign user1 balance. 
        uint256 myBalance = safeContract.getMyBalance();

        // Stop prank. 
        vm.stopPrank();

        // Assert both are Equal. 
        assertEq(myBalance, ETH_AMOUNT);
    }

    /// @notice Test users cant deposit less than the minimum ETH amount. 
    function testUserCantDepositLessThanTheMinimum() external {
        
        // Revert with error message "AmountTooLow".
        vm.expectRevert(SafeContract.AmountTooLow.selector);

        // Fund contract as user2. 
        vm.prank(user2);
        safeContract.depositETH{value: 0}();
    }

    /// @notice Test users can withdraw ETH. 
    function testUserCanWithdrawETH() external {

        // Fund contract as user1. 
        vm.startPrank(user1);
        vm.expectEmit(true, false, false, true);
        emit SafeContract.EthDeposited(user1,ETH_AMOUNT);
        safeContract.depositETH{value: ETH_AMOUNT}();

        // Assign contract balance before. 
        uint256 balanceBefore = address(safeContract).balance;

         // Emit Message "EthWithdrawn". 
        vm.expectEmit(true, false, false, true);
        emit SafeContract.EthWithdrawn(user1, ETH_AMOUNT);

        // Withdraw ETH. 
        safeContract.withdrawETH(ETH_AMOUNT);

        // Assign contract balance after. 
        uint256 balanceAfter = address(safeContract).balance;

        // Stop prank. 
        vm.stopPrank();

        // Assert Balance before is greater than balance after withdrawal. 
        assertGt(balanceBefore, balanceAfter); 
    }

    /// @notice Test user with no deposit cant withdraw. 
    function testUserWithNoDepositCantWithdraw() external {

        // Revert with message "BalanceTooLow". 
        vm.expectRevert(SafeContract.BalanceTooLow.selector);

        // Write as user2. 
        vm.prank(user2);
        safeContract.withdrawETH(ETH_AMOUNT);
    }

    /// @notice Test for withdrawal failed. 
    function testWithdrawalFailed() external {

        // Create new instance of RejectETHTest. 
        RejectETHTest rejector = new RejectETHTest();

        // Fund rejector with 10 ether.
        vm.deal(address(rejector), STARTING_BALANCE);  

        // Fund contract as rejectETH. 
        vm.startPrank(address(rejector));
        safeContract.depositETH{value: ETH_AMOUNT}();

        // Revert with message "WithdrawalFailed". 
        vm.expectRevert(SafeContract.WithdrawalFailed.selector);
        safeContract.withdrawETH(ETH_AMOUNT);

        // Stop prank. 
        vm.stopPrank();
    }

    /// @notice Test to get contract balance. 
    function testGetContractBalance() external {

        // Write as user2. 
        vm.prank(user2);
        uint256 contractBalance = safeContract.getContractBalance();

        // Assert Both are Equal. 
        assertEq(contractBalance, 0);
    }

    /// @notice Test for get owner. 
    function testGetOwner() external {

        // Write as user1. 
        vm.prank(user1);

        // Assign contract owner. 
        address contractOwner = safeContract.getOwner();

        // Assert both are same. 
        assertEq(contractOwner, owner);
    }

    /// @notice Test for receive ETH.
    function testReceive() external {

        // Write as user1. 
        vm.startPrank(user1);
        (bool success,) = address(safeContract).call{value: ETH_AMOUNT}("");
        assertTrue(success);

        // Assign myBalance. 
        uint256 myBalance = safeContract.getMyBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert both are Equal. 
        assertEq(myBalance, ETH_AMOUNT);
    }

    /// @notice Test for amount too low on receieve.
    function testReceiveAmountTooLow() external {
        
        // Revert with message "AmountTooLow".
        vm.expectRevert(SafeContract.AmountTooLow.selector);

        // Write as user1. 
        vm.prank(user1);
        (bool success,) = address(safeContract).call{value: 0}("");
    }

      /// @notice Test for fallback.
    function testFallback() external {

        // Write as user1. 
        vm.startPrank(user1);
        (bool success,) = address(safeContract).call{value: ETH_AMOUNT}("abcd0xx115");
        assertTrue(success);

       // Assign myBalance. 
        uint256 myBalance = safeContract.getMyBalance();

        // Stop prank.
        vm.stopPrank();

        // Assert both are Equal. 
        assertEq(myBalance, ETH_AMOUNT);
    }

    /// @notice Test for amount too low on fallback.
    function testFallbackAmountTooLow() external {
        
        // Revert with message "AmountTooLow".
        vm.expectRevert(SafeContract.AmountTooLow.selector);

        // Write as user1. 
        vm.prank(user1);
        (bool success,) = address(safeContract).call{value: 0}("abcd0xx115");
    }

}