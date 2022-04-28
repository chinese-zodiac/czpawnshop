// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
// Credit to Pancakeswap
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IPawnAppraisal {
    function allSame() external returns (bool); //If all NFT IDs return the same values, excluding "is" statements.

    function getLockFee(uint256 _nftId) external returns (uint256 _wad);

    function getOverdueFee(uint256 _nftId) external returns (uint256 _wad);

    function getExpiredFee(uint256 _nftId) external returns (uint256 _wad);

    function getCredit(uint256 _nftId) external returns (uint256 _wad);

    function getDebt(uint256 _nftId) external returns (uint256 _wad);

    function getPeriod(uint256 _nftId) external returns (uint256 _seconds);

    function getOverdueEpoch(uint256 _nftId, uint256 _lockEpoch)
        external
        returns (uint256 _epoch);

    function getExpiredEpoch(uint256 _nftId, uint256 _lockEpoch)
        external
        returns (uint256 _epoch);

    function isOverdue(uint256 _nftId, uint256 _lockEpoch)
        external
        returns (bool _isOverdue);

    function isExpired(uint256 _nftId, uint256 _lockEpoch)
        external
        returns (bool _isOverdue);
}
