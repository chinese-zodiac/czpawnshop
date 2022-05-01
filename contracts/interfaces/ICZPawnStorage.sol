// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface ICZPawnStorage {
    function withdraw(
        IERC721Enumerable _nft,
        uint256 _id,
        address _to
    ) external;

    function withdrawAll(IERC721Enumerable _nft, address _to) external;
}
