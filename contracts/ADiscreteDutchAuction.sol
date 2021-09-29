// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ADiscreteDutchAuction {

    struct Auction {
        uint256 startingPrice;
        uint64 startingBlock;
        uint64 decreasingConstant;
        uint64 steps;
        uint64 interval;
    }

    mapping (uint => Auction) public auctions;

    uint256 private nextAuctionId;

    function createAuction(
        uint256 startingPrice_,
        uint64 startingBlock_,
        uint64 decreasingConstant_,
        uint64 steps_, // # of total decrements
        uint64 interval_ //blocks between each decrement
    ) public {
        auctions[nextAuctionId++] = Auction(startingPrice_, startingBlock_, decreasingConstant_, steps_, interval_);
    }

    function editAuction(
        uint256 auctionId,
        uint256 startingPrice_,
        uint64 startingBlock_,
        uint64 decreasingConstant_,
        uint64 steps_, // # of total decrements
        uint64 interval_ //blocks between each decrement
    ) public {
        auctions[auctionId] = Auction(startingPrice_, startingBlock_, decreasingConstant_, steps_, interval_);
    }

    function getPrice(uint256 auctionId) public view returns (uint256) {
        Auction memory auction = auctions[auctionId];
        uint256 price = auction.startingPrice;
        uint64 step = auction.startingBlock; //dictates price
        for(uint256 i = 0; i < auction.steps; i++) {
            if (block.number > step + auction.interval) {
                step += auction.interval;
                price -= auction.decreasingConstant;
            }
        }
        return price;
    }

    modifier verifyBid(uint256 auctionId) {
        Auction memory auction = auctions[auctionId];
        require(auction.startingBlock >= block.number, "PURCHASE:AUCTION NOT STARTED");
        uint256 price = getPrice(auctionId);
        require(msg.value == price, "PURCHASE:INCORRECT MSG.VALUE");
        _;
    }
}