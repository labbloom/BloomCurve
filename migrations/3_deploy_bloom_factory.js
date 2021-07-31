const BloomFactory = artifacts.require("BloomFactory");

module.exports = function (deployer) {
  deployer.then(async () => {
    await deployer.deploy(
        BloomFactory,
      "0x7F7fD0432d6B1fe3fA58B92e76187c0215B778C4",
      "0x4D39DC70B6C840799435d1F036D773db85FedC9A",
    );
  });
};