// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "./interfaces/ICZPawnBook.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract CZPawnBook is ICZPawnBook, Ownable, AccessControlEnumerable {
    bytes32 BOOKKEEPER = keccak256("BOOKKEEPER");

    struct Entry {
        uint256 debt;
        uint64 overdueEpoch;
        uint64 expirationEpoch;
        bool exists;
    }

    mapping(address => mapping(address => mapping(uint256 => Entry))) accountNftIdToEntry;

    constructor() Ownable() {
        _grantRole(BOOKKEEPER, msg.sender);
    }

    function getEntry(
        address _for,
        address _nft,
        uint256 _id
    )
        external
        view
        override
        returns (
            uint256 debt_,
            uint64 overdueEpoch_,
            uint64 expirationEpoch_,
            bool exists_
        )
    {
        Entry memory entry = accountNftIdToEntry[_for][_nft][_id];
        return (
            entry.debt,
            entry.overdueEpoch,
            entry.expirationEpoch,
            entry.exists
        );
    }

    function recordLoanCreation(
        address _for,
        address _nft,
        uint256 _id,
        uint256 _debt,
        uint64 _overdueEpoch,
        uint64 _expirationEpoch
    ) external override onlyRole(BOOKKEEPER) {
        Entry storage entry = accountNftIdToEntry[_for][_nft][_id];
        require(
            !entry.exists,
            "CZPawnBook: Attempting to register loan for active entry"
        );
        entry.debt = _debt;
        entry.overdueEpoch = _overdueEpoch;
        entry.expirationEpoch = _expirationEpoch;
        entry.exists = true;
    }

    function recordLoanExtension(
        address _for,
        address _nft,
        uint256 _id,
        uint64 _overdueExtensionSeconds,
        uint64 _expirationExtensionSeconds,
        int256 _debtDelta
    ) external override onlyRole(BOOKKEEPER) {
        Entry storage entry = accountNftIdToEntry[_for][_nft][_id];
        require(
            entry.exists,
            "CZPawnBook: Attempting to extend non-existant loan"
        );
        entry.overdueEpoch += _overdueExtensionSeconds;
        entry.expirationEpoch += _expirationExtensionSeconds;
        entry.debt = uint256(int256(entry.debt) + _debtDelta);
    }

    function recordLoanRepayment(
        address _for,
        address _nft,
        uint256 _id
    ) external override onlyRole(BOOKKEEPER) {
        Entry memory entry = accountNftIdToEntry[_for][_nft][_id];
        require(
            entry.exists,
            "CZPawnBook: Attempting to extend non-existant loan"
        );
        delete accountNftIdToEntry[_for][_nft][_id];
    }
}
