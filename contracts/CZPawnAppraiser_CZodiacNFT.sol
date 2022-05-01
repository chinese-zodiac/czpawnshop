// SPDX-License-Identifier: GPL-3.0
// Authored by Plastic Digits
pragma solidity ^0.8.4;

import "./interfaces/ICZPawnAppraiser.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CZPawnAppraiser_CZodiacNFT is ICZPawnAppraiser, Ownable {
    bool public override allSame = true;

    uint256 pawnFee = 0.01 ether;
    uint256 overdueFee = 0.02 ether;
    uint256 expiredFee = 0.02 ether;

    uint256 quote = 30 ether;

    uint256 term = 31 days;

    function getPawnFee(uint256) external view override returns (uint256 _wad) {
        return pawnFee;
    }

    function getOverdueFee(uint256)
        external
        view
        override
        returns (uint256 _wad)
    {
        return overdueFee;
    }

    function getExpiredFee(uint256)
        external
        view
        override
        returns (uint256 _wad)
    {
        return expiredFee;
    }

    function getQuote(uint256) external view override returns (uint256 _wad) {
        return quote;
    }

    function getTerm(uint256)
        external
        view
        override
        returns (uint256 _seconds)
    {
        return term;
    }

    function getOverdueEpoch(uint256, uint256 _lockEpoch)
        public
        view
        override
        returns (uint256 _epoch)
    {
        return _lockEpoch + term;
    }

    function getExpiredEpoch(uint256, uint256 _lockEpoch)
        public
        view
        override
        returns (uint256 _epoch)
    {
        return _lockEpoch + term * 2;
    }

    function isOverdue(uint256 _nftId, uint256 _lockEpoch)
        external
        view
        override
        returns (bool _isOverdue)
    {
        return block.timestamp > getOverdueEpoch(_nftId, _lockEpoch);
    }

    function isExpired(uint256 _nftId, uint256 _lockEpoch)
        external
        view
        override
        returns (bool _isOverdue)
    {
        return block.timestamp > getExpiredEpoch(_nftId, _lockEpoch);
    }

    function setPawnFee(uint256 _to) external onlyOwner {
        pawnFee = _to;
    }

    function setOverdueFee(uint256 _to) external onlyOwner {
        overdueFee = _to;
    }

    function setExpiredFee(uint256 _to) external onlyOwner {
        expiredFee = _to;
    }

    function setQuote(uint256 _to) external onlyOwner {
        quote = _to;
    }

    function setTerm(uint256 _to) external onlyOwner {
        term = _to;
    }
}
