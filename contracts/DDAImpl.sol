// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ADiscreteDutchAuction.sol";

contract DDAImpl is ADiscreteDutchAuction {

    function buy(uint auctionId) verifyBid(auctionId) public payable {
        //do nothing...
    }
}