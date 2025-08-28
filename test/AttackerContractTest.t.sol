// SPDX-License-Identifier: MIT

/// @title AttackerContractTest for BuildsWithKing-ReentrancyGuard. 
/// @author Michealking (@BuildsWithKing).
/// @notice Created on 27th of Aug, 2025. 

pragma solidity ^0.8.30;

/// @notice Imports Test from forge standard library, AttackerContract, 
//  VulnerableContract, RejectETHTest and SafeContract. 
import {Test} from "forge-std/Test.sol";
import {AttackerContract} from "../src/AttackerContract.sol";
import {VulnerableContract} from "../src/VulnerableContract.sol";
import {RejectETHTest} from "./RejectETHTest.t.sol";
import {SafeContract} from "../src/SafeContract.sol";

contract AttackerContractTest is Test {

// -------------------------------------- Variable Assignment ----------------------------------------

    /// @notice Assigns attackerContract. 
    AttackerContract attackerContract;

    /// @notice Assigns vulnerableContract.
    VulnerableContract vulnerableContract;

    /// @notice Assigns safe contract.
    SafeContract safeContract;

    /// @notice Assigns STARTING_BALANCE, ETH_AMOUNT, twoEther and user1. 
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant ETH_AMOUNT = 1 ether;
    address user1 = address(0x1);
    address attacker = address(this);

// ----------------------------------------- SetUp Function ------------------------------------------

    /// @notice Runs before every other test. 
    function setUp() external {

        // Create new instance of vulnerable Contract.
        vulnerableContract = new VulnerableContract();

        // Create new instance of safe contract.
        safeContract = new SafeContract();
    
        // Create new instance of AttackerContract while deploying vulnerable contract. 
        attackerContract = new AttackerContract (payable(address(vulnerableContract)));

        // Fund attacker with 10 ether. 
        vm.deal(address(attackerContract), STARTING_BALANCE);

        // Fund user1 with 10 ether. 
        vm.deal(user1, STARTING_BALANCE);
    }

// ------------------------------------------ Test for startAttack Function --------------------------
    function testAttackerCanAttack() external {

        // Fund contract as user1. 
        vm.prank(user1);
        vulnerableContract.depositETH{value: ETH_AMOUNT}();

        // Assign vulnerable contract balance before attack.
        uint256 balanceBefore = address(vulnerableContract).balance;

        // Attack vulnerable contract as attacker contract. 
        attackerContract.startAttack{value: ETH_AMOUNT}();

        // Assign vulnerable contract balance after attack. 
        uint256 balanceAfter = address(vulnerableContract).balance;

        // Assert balance after is less than balance before. 
        assertLt(balanceAfter, balanceBefore);
    }

// -------------------------------------- Test for WithdrawETH function ------------------------------

    /// @notice Test for withdrawal failed.
    function testWithdrawalFailed() external {
       
        // Create new instance of RejectETHTest. 
        RejectETHTest rejector = new RejectETHTest();

        // Write as attacker. 
        vm.startPrank(attacker);
        
        // Revert With message "WithdrawalFailed".
        vm.expectRevert(AttackerContract.WithdrawalFailed.selector);
        attackerContract.withdrawETH(ETH_AMOUNT, address(rejector));
        vm.stopPrank();
    }

     /// @notice Test to ensure attacker can withdraw ETH. 
    function testOnlyAttackerCanWithdraw() external {

        // Fund contract as user1. 
        vm.startPrank(user1);
        vulnerableContract.depositETH{value: ETH_AMOUNT}();

        // Revert With message "Unauthorized".
        vm.expectRevert(AttackerContract.Unauthorized.selector);
        attackerContract.withdrawETH(ETH_AMOUNT, user1);

        // Stop prank.
        vm.stopPrank();
    }

    /// @notice Test to ensure attacker can withdraw ETH. 
    function testAttackerCanWithdraw() external {

        // Fund contract as user1. 
        vm.prank(user1);
        vulnerableContract.depositETH{value: ETH_AMOUNT}();

        // Attack vulnerable contract as attacker contract. 
        attackerContract.startAttack{value: ETH_AMOUNT}();

        // Withdraw ETH as the attacker. 
        vm.prank(attacker);

         // Emit Message "EthWithdrawn". 
        vm.expectEmit(true, false, false, true);
        emit AttackerContract.EthWithdrawn(attacker, ETH_AMOUNT);

        attackerContract.withdrawETH(ETH_AMOUNT, attacker);

        // Assign balance. 
        uint256 balance = attacker.balance;

        // Assert balance is greater than ETH_Amount. 
        assertGt(balance, ETH_AMOUNT);
    }

    /// @notice Test for get contract balance. 
    function testGetContractBalance() external {
        
        // Write as the attacker. 
        vm.prank(attacker);

        // Assign contract balance. 
       uint256 contractBalance = attackerContract.getContractBalance();

        // Assert both are same. 
        assertEq(contractBalance, STARTING_BALANCE);
    }

    /// @notice Test for get attacker. 
    function testGetAttacker() external {

        // Read as attacker.
        vm.prank(attacker);

        // Assert Both are same.
        assertEq(attacker, attackerContract.getAttacker());
    }

    /// @notice Receives ETH with no calldata. 
    receive() external payable {}

// ----------------------------------- Test for ReentrancyGuard on Safe Contract ---------------------------
    
    /// @notice Test for nonreentrant on withdrawETH. 
    function testNonReentrant() external {

        // Create new instance of AttackerContract while deploying safe contract. 
       attackerContract = new AttackerContract (payable(address(safeContract)));

        // Fund contract as user1. 
        vm.startPrank(user1);
        safeContract.depositETH{value: ETH_AMOUNT}();
        vm.stopPrank();

        // Revert with message "WithdrawalFailed". 
        vm.expectRevert(SafeContract.WithdrawalFailed.selector);

        // Write as Attacker. 
        attackerContract.startAttack{value: ETH_AMOUNT}();
    }
}