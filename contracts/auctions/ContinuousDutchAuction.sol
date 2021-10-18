// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

abstract contract ContinuousDutchAuction {

    struct Auction {
        uint256 startingPrice;
        uint64 startingBlock;
        uint64 decreasingConstant;
        uint64 period; //period (in blocks) during which price will decrease
    }

    mapping (uint => Auction) public auctions;

    uint256 private nextAuctionId;

    function createAuction(
        uint256 startingPrice_,
        uint64 startingBlock_,
        uint64 decreasingConstant_,
        uint64 period_
    ) public {
        auctions[nextAuctionId++] = Auction(startingPrice_, startingBlock_, decreasingConstant_, period_);
    }

    function editAuction(
        uint256 auctionId,
        uint256 startingPrice_,
        uint64 startingBlock_,
        uint64 decreasingConstant_,
        uint64 period_
    ) public {
        auctions[auctionId] = Auction(startingPrice_, startingBlock_, decreasingConstant_, period_);
    }

    function getPrice(uint256 auctionId) public view returns (uint256) {
        Auction memory auction = auctions[auctionId];
        uint256 price = auction.startingPrice;
        uint256 floorPrice = price - auction.period * auction.decreasingConstant;
        unchecked {
            price -= auction.decreasingConstant * (block.number - auction.startingBlock);
        }
        return price >= floorPrice && price <= auction.startingPrice ? price : floorPrice;
    }

    function verifyBid(uint256 auctionId) internal returns (uint256) {
        Auction memory auction = auctions[auctionId];
        require(auction.startingBlock > 0, "AUCTION:NOT CREATED");
        require(block.number >= auction.startingBlock, "PURCHASE:AUCTION NOT STARTED");
        uint256 price = getPrice(auctionId);
        require(msg.value >= price, "PURCHASE:INCORRECT MSG.VALUE");
        if (msg.value - price > 0) Address.sendValue(payable(msg.sender), msg.value-price); //refund difference
        return price;
    }
}