// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./interfaces/ICZPawnStorage.sol";

contract CZPawnStorage is ICZPawnStorage, AccessControlEnumerable {
    bytes32 public constant CUSTODIAN = keccak256("CUSTODIAN");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function withdraw(
        IERC721Enumerable _nft,
        uint256 _id,
        address _to
    ) public override onlyRole(CUSTODIAN) {
        _nft.transferFrom(address(this), _to, _id);
    }

    function withdrawAll(IERC721Enumerable _nft, address _to)
        public
        override
        onlyRole(CUSTODIAN)
    {
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
