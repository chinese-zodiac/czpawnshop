// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "./interfaces/ICZPawnBook.sol";
import "./libs/IterableMapping.sol";
import "./libs/IterableArrayWithoutDuplicateKeys.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract CZPawnBook is ICZPawnBook, AccessControlEnumerable {
    using IterableMapping for IterableMapping.Map;
    using IterableArrayWithoutDuplicateKeys for IterableArrayWithoutDuplicateKeys.Map;

    struct Entry {
        uint64 overdueEpoch;
        uint64 expirationEpoch;
        uint128 debt;
    }

    bytes32 public constant BOOKKEEPER = keccak256("BOOKKEEPER");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    mapping(bytes32 => Entry) entryIdToEntry;
    mapping(address => IterableArrayWithoutDuplicateKeys.Map) acountToEntryIds;
    IterableArrayWithoutDuplicateKeys.Map entryIds;

    function createEntry(
        address _for,
        address _nft,
        uint256 _id,
        uint128 _debt,
        uint64 _overdueEpoch,
        uint64 _expirationEpoch
    ) external override onlyRole(BOOKKEEPER) {
        bytes32 entryId = getEntryId(_nft, _id);
        require(
            acountToEntryIds[_for].getIndexOfKey(entryId) == -1,
            "CZPawnBook: Cannot create entry when already exists."
        );

        Entry storage entry = entryIdToEntry[entryId];
        entry.debt = _debt;
        entry.overdueEpoch = _overdueEpoch;
        entry.expirationEpoch = _expirationEpoch;

        acountToEntryIds[_for].add(entryId);
        entryIds.add(entryId);
    }

    function readEntry(address _nft, uint256 _id)
        external
        view
        override
        returns (
            uint128 debt_,
            uint64 overdueEpoch_,
            uint64 expirationEpoch_
        )
    {
        Entry memory entry = entryIdToEntry[getEntryId(_nft, _id)];
        return (entry.debt, entry.overdueEpoch, entry.expirationEpoch);
    }

    function updateEntry(
        address _for,
        address _nft,
        uint256 _id,
        uint128 _debt,
        uint64 _overdueEpoch,
        uint64 _expirationEpoch
    ) external override onlyRole(BOOKKEEPER) {
        bytes32 entryId = getEntryId(_nft, _id);
        require(
            acountToEntryIds[_for].getIndexOfKey(entryId) != -1,
            "CZPawnBook: Attempting to update non-existant entry"
        );
        Entry storage entry = entryIdToEntry[entryId];
        entry.debt = _debt;
        entry.overdueEpoch = _overdueEpoch;
        entry.expirationEpoch = _expirationEpoch;
    }

    function deleteEntry(
        address _for,
        address _nft,
        uint256 _id
    ) external override onlyRole(BOOKKEEPER) {
        bytes32 entryId = getEntryId(_nft, _id);
        require(
            acountToEntryIds[_for].getIndexOfKey(entryId) == -1,
            "CZPawnBook: Attempting to delete non-existant entry"
        );
        acountToEntryIds[_for].remove(entryId);
        entryIds.remove(entryId);
        delete entryIdToEntry[entryId];
    }

    function getEntryId(address _nft, uint256 _id)
        public
        pure
        override
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_nft, _id));
    }

    function getIndexAccountEntryId(address _for, uint256 _index)
        external
        view
        override
        returns (bytes32 entryId_)
    {
        return acountToEntryIds[_for].getKeyAtIndex(_index);
    }

    function getIndexEntryId(uint256 _index)
        external
        view
        override
        returns (bytes32 entryId_)
    {
        return entryIds.getKeyAtIndex(_index);
    }

    function getTotalAccountEntries(address _for)
        external
        view
        override
        returns (uint256 count_)
    {
        return acountToEntryIds[_for].size();
    }

    function getTotalEntries() external view override returns (uint256 count_) {
        return entryIds.size();
    }
}
