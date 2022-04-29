// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

interface ICZPawnBook {
    function getEntry(
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

    function recordLoanCreation(
        address _for,
        address _nft,
        uint256 _id,
        uint256 _debt,
        uint64 _overdueEpoch,
        uint64 _expirationEpoch
    ) external;

    function recordLoanExtension(
        address _for,
        address _nft,
        uint256 _id,
        uint64 _overdueExtensionSeconds,
        uint64 _expirationExtensionSeconds,
        int256 _debtDelta
    ) external;

    function recordLoanRepayment(
        address _for,
        address _nft,
        uint256 _id
    ) external;
}
