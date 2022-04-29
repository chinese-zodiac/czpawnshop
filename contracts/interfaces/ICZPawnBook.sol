// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

interface ICZPawnBook {
    function createEntry(
        address _for,
        address _nft,
        uint256 _id,
        uint256 _debt,
        uint64 _overdueEpoch,
        uint64 _expirationEpoch
    ) external;

    function readEntry(
        address _for,
        address _nft,
        uint256 _id
    )
        external
        view
        returns (
            uint256 debt_,
            uint64 overdueEpoch_,
            uint64 expirationEpoch_,
            bool exists_
        );

    function updateEntry(
        address _for,
        address _nft,
        uint256 _id,
        uint256 _debt,
        uint64 _overdueEpoch,
        uint64 _expirationEpoch
    ) external;

    function deleteEntry(
        address _for,
        address _nft,
        uint256 _id
    ) external;
}
