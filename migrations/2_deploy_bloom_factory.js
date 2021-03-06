const BloomFactory = artifacts.require("BloomFactory");
const MockErc20 = artifacts.require("MockErc20");
const Web3 = require("web3");

module.exports = function (deployer) {
  /*
  deployer.then(async () => {
    await deployer.deploy(
        MockErc20,
        Web3.utils.toBN("10000000000000000000000000000000000"),
        "MockToken",
        "MOCK",
        "0x4D39DC70B6C840799435d1F036D773db85FedC9A"
    );
  }); */
  deployer.then(async () => {
    await deployer.deploy(
        BloomFactory,
        "0xD62D1916bf5931Ca1715fbea4138c55F1b09650D", // mock token
        "0x4D39DC70B6C840799435d1F036D773db85FedC9A", // owner address
    );
  });
  
};