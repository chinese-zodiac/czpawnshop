// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

interface ICZPawnBook {
    function createEntry(
        address _for,
        address _nft,
        uint256 _id,
        uint128 _debt,
        uint64 _overdueEpoch,
        uint64 _expirationEpoch
    ) external;

    function readEntry(address _nft, uint256 _id)
        external
        view
        returns (
            uint128 debt_,
            uint64 overdueEpoch_,
            uint64 expirationEpoch_
        );

    function updateEntry(
        address _for,
        address _nft,
        uint256 _id,
        uint128 _debt,
        uint64 _overdueEpoch,
        uint64 _expirationEpoch
    ) external;

    function deleteEntry(
        address _for,
        address _nft,
        uint256 _id
    ) external;

    function getEntryId(address _nft, uint256 _id)
        external
        pure
        returns (bytes32);

    function getIndexAccountEntryId(address _for, uint256 _index)
        external
        view
        returns (bytes32 entryId_);

    function getIndexEntryId(uint256 _index)
        external
        returns (bytes32 entryId_);

    function getTotalAccountEntries(address _for)
        external
        view
        returns (uint256 count_);

    function getTotalEntries() external view returns (uint256 count_);
}
