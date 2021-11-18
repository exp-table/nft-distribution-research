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

function decayedPrice(price, decFactor, blocks) {
    return toWei(price - blocks * decFactor);
}

describe("Continuous Dutch Auction", function () {
  const buyer = "0xD2927a91570146218eD700566DF516d67C5ECFAB";
  const initialPrice = 5;
  const decFactor = 0.02; //decreasing factor
  const period = 200; //200 blocks period
  let owner, start, dutch;


  /*
    i = interval

    blocks: x ---> x + i ---> x + i * 1 ---> ... ---> x + i * steps ---> no change
    price : 5      4.5        4                       1                  1
  */

  before(async function () {
    [owner] = await ethers.getSigners();

    const CDA = await ethers.getContractFactory("CDAMock");
    dutch = await CDA.deploy();
    await dutch.deployed();

    start = await ethers.provider.getBlockNumber();

    await dutch.setAuction(0, toWei(initialPrice), toWei(decFactor), start, period);

  });

  it("Initial price check", async function () {
      const price = await dutch.getPrice(0);
      expect(price).to.be.equal(decayedPrice(initialPrice, decFactor, 1));
  });

  it("Price check after 37 blocks", async function() {
    mineBlocks(37);
    const price = await dutch.getPrice(0);
    expect(price).to.be.equal(decayedPrice(initialPrice, decFactor, 38));
  });

  it("Refunds the difference", async function() {
    await dutch.buy(0, {value:toWei(5)});
    const price = await dutch.getPrice(0);
    expect(await ethers.provider.getBalance(dutch.address)).to.be.equal(price);
  });

  it("Price check after period ended - should not be decayed further", async function() {
    mineBlocks(period);
    const price = await dutch.getPrice(0);
    expect(price).to.be.equal(decayedPrice(initialPrice, decFactor, 200));
  });

});
