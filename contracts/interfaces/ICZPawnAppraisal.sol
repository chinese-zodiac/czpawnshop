// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface ICZPawnAppraisal {
    function allSame() external view returns (bool); //If all NFT IDs return the same values

    function getPawnFee(uint256 _nftId) external view returns (uint256 _wad);

    function getOverdueFee(uint256 _nftId) external view returns (uint256 _wad);

    function getExpiredFee(uint256 _nftId) external view returns (uint256 _wad);

    function getQuote(uint256 _nftId) external view returns (uint256 _wad);

    function getTerm(uint256 _nftId) external view returns (uint256 _seconds);

    function getOverdueEpoch(uint256 _nftId, uint256 _lockEpoch)
        external
        view
        returns (uint256 _epoch);

    function getExpiredEpoch(uint256 _nftId, uint256 _lockEpoch)
        external
        view
        returns (uint256 _epoch);

    function isOverdue(uint256 _nftId, uint256 _lockEpoch)
        external
        view
        returns (bool _isOverdue);

    function isExpired(uint256 _nftId, uint256 _lockEpoch)
        external
        view
        returns (bool _isOverdue);
}
