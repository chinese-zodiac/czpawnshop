// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract CZPawnStorage is Ownable {
    function recover(
        IERC721Enumerable _nft,
        uint256 _id,
        address _to
    ) public onlyOwner {
        _nft.transferFrom(address(this), _to, _id);
    }

    function recoverAll(IERC721Enumerable _nft, address _to) public onlyOwner {
        uint256 quantity = _nft.balanceOf(address(this));
        for (uint256 i = 0; i < quantity; i++) {
            _nft.transferFrom(
                address(this),
                _to,
                _nft.tokenOfOwnerByIndex(address(this), i)
            );
        }
    }
}
