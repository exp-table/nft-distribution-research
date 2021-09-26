// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AContinuousDutchAuction.sol";

contract CDAImpl is AContinuousDutchAuction {

    function buy(uint auctionId) verifyBid(auctionId) public payable {
        //do nothing...
    }
}