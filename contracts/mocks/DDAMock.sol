// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../auctions/ADiscreteDutchAuction.sol";

contract DDAMock is ADiscreteDutchAuction {

    function buy(uint auctionId) public payable {
        verifyBid(auctionId);
        //do nothing...
    }
}