// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/// @title  YFToken
/// @author YieldForge
/// @notice Governance and utility token for the YieldForge protocol.
///         Capped supply, role-based minting, and pausable transfers.
contract YFToken is ERC20, ERC20Burnable, AccessControl, Pausable {
    // ─────────────────────────────────────────────────────────────────────────
    // Roles
    // ─────────────────────────────────────────────────────────────────────────

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // ─────────────────────────────────────────────────────────────────────────
    // State
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Hard cap on total token supply. Cannot be changed after deployment.
    uint256 public immutable MAX_SUPPLY;

    // ─────────────────────────────────────────────────────────────────────────
    // Errors
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Thrown when a mint would exceed MAX_SUPPLY.
    error CapExceeded(uint256 requested, uint256 available);

    /// @dev Thrown when the zero address is passed as admin.
    error ZeroAddress();

    /// @dev Thrown when maxSupply is zero.
    error ZeroMaxSupply();

    // ─────────────────────────────────────────────────────────────────────────
    // Constructor
    // ─────────────────────────────────────────────────────────────────────────

    /// @param name_      ERC20 token name.
    /// @param symbol_    ERC20 token symbol.
    /// @param maxSupply_ Immutable maximum supply (in token base units, i.e. with decimals).
    /// @param admin_     Address granted DEFAULT_ADMIN_ROLE, MINTER_ROLE and PAUSER_ROLE.
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        address admin_
    ) ERC20(name_, symbol_) {
        if (admin_ == address(0)) revert ZeroAddress();
        if (maxSupply_ == 0)     revert ZeroMaxSupply();

        MAX_SUPPLY = maxSupply_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(MINTER_ROLE,        admin_);
        _grantRole(PAUSER_ROLE,        admin_);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Minting
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Mints `amount` tokens to `to`.
    /// @dev    Reverts if the resulting total supply would exceed MAX_SUPPLY.
    ///         Can only be called by an account with MINTER_ROLE.
    ///         Minting is blocked while the contract is paused.
    /// @param to     Recipient address.
    /// @param amount Amount of tokens to mint (base units).
    function mint(address to, uint256 amount)
        external
        onlyRole(MINTER_ROLE)
        whenNotPaused
    {
        uint256 supply = totalSupply();
        if (supply + amount > MAX_SUPPLY) revert CapExceeded(amount, MAX_SUPPLY - supply);

        _mint(to, amount);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Pause controls
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Pauses all token transfers and minting.
    /// @dev    Can only be called by an account with PAUSER_ROLE.
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpauses token transfers and minting.
    /// @dev    Can only be called by an account with PAUSER_ROLE.
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Overrides
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Blocks all transfers while the contract is paused.
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20)
        whenNotPaused
    {
        super._update(from, to, value);
    }
}
