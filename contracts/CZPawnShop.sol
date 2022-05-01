// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./interfaces/ICZPawnBook.sol";
import "./interfaces/ICZPawnAppraiser.sol";
import "./interfaces/ICZPawnStorage.sol";

contract CZPawnStorage is AccessControlEnumerable {
    bytes32 public constant SHOPKEEPER = keccak256("SHOPKEEPER");

    ICZPawnBook public pawnBook;
    ICZPawnStorage public pawnStorage;

    mapping(IERC721Enumerable => ICZPawnAppraiser) public nftToAppraiser;

    constructor(ICZPawnBook _pawnBook, ICZPawnStorage _pawnStorage) {
        pawnBook = _pawnBook;
        pawnStorage = _pawnStorage;
    }

    //TODO: borrow, repay, extend, purchase
}
