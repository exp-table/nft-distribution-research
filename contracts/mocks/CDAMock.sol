// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../auctions/AContinuousDutchAuction.sol";

contract CDAMock is AContinuousDutchAuction {

    function buy(uint auctionId) public payable {
        verifyBid(auctionId);
        //do nothing...
    }
}