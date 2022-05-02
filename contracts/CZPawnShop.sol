// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "./interfaces/ICZPawnBook.sol";
import "./interfaces/ICZPawnAppraiser.sol";
import "./interfaces/ICZPawnStorage.sol";

contract CZPawnStorage is AccessControlEnumerable, Ownable {
    bytes32 public constant SHOPKEEPER = keccak256("SHOPKEEPER");

    ICZPawnBook public pawnBook;
    ICZPawnStorage public pawnStorage;
    ERC20PresetMinterPauser public czusd;

    mapping(IERC721 => ICZPawnAppraiser) public nftToAppraiser;

    constructor(
        ICZPawnBook _pawnBook,
        ICZPawnStorage _pawnStorage,
        ERC20PresetMinterPauser _czusd
    ) {
        pawnBook = _pawnBook;
        pawnStorage = _pawnStorage;
        czusd = _czusd;
    }

    function borrow(IERC721 _nft, uint256 _id) external payable {
        _nft.safeTransferFrom(msg.sender, address(pawnStorage), _id);
        ICZPawnAppraiser appraiser = nftToAppraiser[_nft];
        require(
            msg.value >= appraiser.getPawnFee(_id),
            "CZPawnShop: Not enough BNB to cover service fee."
        );
        pawnBook.createEntry(
            msg.sender,
            address(_nft),
            _id,
            uint128(appraiser.getQuote(_id)),
            uint64(appraiser.getOverdueEpoch(_id, block.timestamp)),
            uint64(appraiser.getExpiredEpoch(_id, block.timestamp))
        );
        czusd.mint(msg.sender, appraiser.getQuote(_id));
        if (msg.value != 0) payable(owner()).transfer(msg.value);
    }

    function repay(IERC721 _nft, uint256 _id) external payable {
        ICZPawnAppraiser appraiser = nftToAppraiser[_nft];
        (uint128 debt, uint64 overdueEpoch, uint64 expirationEpoch) = pawnBook
            .readEntry(address(_nft), _id);
        czusd.burnFrom(msg.sender, debt);
        uint256 bnbFee = 0;
        if (block.timestamp > overdueEpoch) {
            bnbFee = appraiser.getOverdueFee(_id);
        } else if (block.timestamp > expirationEpoch) {
            bnbFee = appraiser.getExpiredFee(_id);
        }
        if (!(block.timestamp > overdueEpoch)) {
            //When not expired, ONLY the owner can repay the loan.
            require(
                pawnBook.isEntryOwnedByAccount(msg.sender, address(_nft), _id),
                "CZPawnShop: Only creator can repay loan that is not expired."
            );
        }
        if (bnbFee > 0) {
            require(
                msg.value >= bnbFee,
                "CZPawnShop: Not enough BNB to cover overdue/expiration fee."
            );
            payable(owner()).transfer(msg.value);
        }
        pawnStorage.withdraw(IERC721Enumerable(address(_nft)), _id, msg.sender);
        pawnBook.deleteEntry(msg.sender, address(_nft), _id);
    }

    function extend(IERC721 _nft, uint256 _id) external payable {
        ICZPawnAppraiser appraiser = nftToAppraiser[_nft];
        (uint128 debt, uint64 overdueEpoch, uint64 expirationEpoch) = pawnBook
            .readEntry(address(_nft), _id);
        uint256 bnbFee;
        uint128 newDebt;
        uint64 newOverdueEpoch;
        uint64 newExpirationEpoch;
        if (block.timestamp > overdueEpoch) {
            bnbFee = appraiser.getOverdueFee(_id);
            newOverdueEpoch = uint64(
                appraiser.getOverdueEpoch(_id, block.timestamp)
            );
            newExpirationEpoch = uint64(
                appraiser.getExpiredEpoch(_id, block.timestamp)
            );
        } else if (block.timestamp > expirationEpoch) {
            bnbFee = appraiser.getExpiredFee(_id);
            newOverdueEpoch = uint64(
                appraiser.getOverdueEpoch(_id, block.timestamp)
            );
            newExpirationEpoch = uint64(
                appraiser.getExpiredEpoch(_id, block.timestamp)
            );
        } else {
            uint64 period = uint64(appraiser.getTerm(_id));
            newOverdueEpoch = overdueEpoch + period;
            newExpirationEpoch = expirationEpoch + period;
        }
        if (bnbFee > 0) {
            require(
                msg.value >= bnbFee,
                "CZPawnShop: Not enough BNB to cover overdue/expiration fee."
            );
            payable(owner()).transfer(msg.value);
        }
        uint128 quote = uint128(appraiser.getQuote(_id));
        if (quote > debt) {
            newDebt = quote;
            czusd.mint(msg.sender, newDebt - debt);
        } else {
            newDebt = debt;
        }
        pawnBook.updateEntry(
            msg.sender,
            address(_nft),
            _id,
            newDebt,
            newOverdueEpoch,
            newExpirationEpoch
        );
    }

    function setNftToAppraiser(IERC721 _nft, ICZPawnAppraiser _appraiser)
        external
        onlyOwner
    {
        nftToAppraiser[_nft] = _appraiser;
    }

    function setPawnBook(ICZPawnBook _book) external onlyOwner {
        pawnBook = _book;
    }

    function setPawnStorage(ICZPawnStorage _pawnStorage) external onlyOwner {
        pawnStorage = _pawnStorage;
    }
}
