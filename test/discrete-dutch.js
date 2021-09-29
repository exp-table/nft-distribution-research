const { expect } = require("chai");

function toWei(price) {
  return (price * 10 ** 18).toString();
}

async function mineBlocks(blockNumber) {
  while (blockNumber > 0) {
    blockNumber--;
    await ethers.provider.send("evm_mine");
  }
}

function priceAfterIntervals(initialPrice, decFactor, intervals) {
    const price = initialPrice - (intervals * decFactor);
    return toWei(price);
}

describe("Discrete Dutch Auction", function () {
  const initialPrice = 5;
  const decFactor = 0.5; //decreasing factor
  const steps = 3;
  const interval = 50; //50 blocks interval
  let start, dutch;


  /*
    i = interval

    blocks: x ---> x + i ---> x + i * 1 ---> ... ---> x + i * steps ---> no change
    price : 5      4.5        4                       1                  1
  */

  before(async function () {
    const DDA = await ethers.getContractFactory("DDAImpl");
    dutch = await DDA.deploy();
    await dutch.deployed();

    start = await ethers.provider.getBlockNumber();

    await dutch.createAuction(toWei(initialPrice), start, toWei(decFactor), steps, interval);
  });

  it("Initial price check", async function () {
      const price = await dutch.getPrice(0);
      expect(price).to.be.equal(priceAfterIntervals(initialPrice, decFactor, 0));
  });

  it("Price check on first node x+interval", async function() {
    mineBlocks(interval);
    const price = await dutch.getPrice(0);
    expect(price).to.be.equal(priceAfterIntervals(initialPrice, decFactor, 1));
  });

  it("Price check on first node x+interval + middle of it", async function() {
    mineBlocks(interval / 2);
    const price = await dutch.getPrice(0);
    expect(price).to.be.equal(priceAfterIntervals(initialPrice, decFactor, 1));
  });

  it("Price check after last step x + steps * interval", async function() {
    mineBlocks(interval * steps);
    const price = await dutch.getPrice(0);
    expect(price).to.be.equal(priceAfterIntervals(initialPrice, decFactor, steps));
  });

});
