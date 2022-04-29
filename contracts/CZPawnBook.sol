// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "./interfaces/ICZPawnBook.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract CZPawnBook is ICZPawnBook, AccessControlEnumerable {
    bytes32 public constant BOOKKEEPER = keccak256("BOOKKEEPER");

    struct Entry {
        uint256 debt;
        uint64 overdueEpoch;
        uint64 expirationEpoch;
        bool exists;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    mapping(address => mapping(address => mapping(uint256 => Entry))) accountNftIdToEntry;

    function createEntry(
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

    function readEntry(
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

    function updateEntry(
        address _for,
        address _nft,
        uint256 _id,
        uint256 _debt,
        uint64 _overdueEpoch,
        uint64 _expirationEpoch
    ) external override onlyRole(BOOKKEEPER) {
        Entry storage entry = accountNftIdToEntry[_for][_nft][_id];
        require(
            entry.exists,
            "CZPawnBook: Attempting to update non-existant entry"
        );
        entry.debt = _debt;
        entry.overdueEpoch = _overdueEpoch;
        entry.expirationEpoch = _expirationEpoch;
    }

    function deleteEntry(
        address _for,
        address _nft,
        uint256 _id
    ) external override onlyRole(BOOKKEEPER) {
        Entry memory entry = accountNftIdToEntry[_for][_nft][_id];
        require(
            entry.exists,
            "CZPawnBook: Attempting to delete non-existant entry"
        );
        delete accountNftIdToEntry[_for][_nft][_id];
    }
}
