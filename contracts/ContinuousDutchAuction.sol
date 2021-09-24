pragma solidity ^0.8.0;

contract ContinuousDutchAuction {

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
        price -= auction.decreasingConstant * (block.number - auction.startingBlock);
        return price >= floorPrice ? price : floorPrice;
    }

    modifier verifyBid(uint256 auctionId) {
        Auction memory auction = auctions[auctionId];
        require(auction.startingBlock >= block.number, "PURCHASE:AUCTION NOT STARTED");
        uint256 price = getPrice(auctionId);
        require(msg.value == price, "PURCHASE:INCORRECT MSG.VALUE");
        _;
    }
}