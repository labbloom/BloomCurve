# BloomCurve


Run these to start:
```
npm init --yes
npm install --save-dev hardhat
```

To install truffle, web3js, open zeppelin:
```
npm install --save-dev @nomiclabs/hardhat-truffle5 @nomiclabs/hardhat-web3 web3
```

## Truffle examples
Mock factory and mock usdc to play around:

Factory address: 0x44dDcF4C5EADDb93943C10f53F5fD586c9357e6c

mock usdc address: 0xD62D1916bf5931Ca1715fbea4138c55F1b09650D

To connect to the kovan network cia the truffle console run:
```
truffle console --network kovan
```
To initiate the address(es) from the .key file within the truffle console:
```
let accounts = await web3.eth.getAccounts()
```
To use some of the web3 functionalities needed for truffle (like the toBN() function):
```
const Web3 = require("web3");
```

To create a bloom factory object within the truffle console:
```
let bloom_factory = await BloomFactory.at("insert factory address")
```

To create a bonding curve:
```
bloom_factory.createCurve("Lum","LUM", 666666, "0x4d39dc70b6c840799435d1f036d773db85fedc9a", {from: accounts[0]})
```
Where "Lum" is the token name, "LUM" the token symbol, "666666" is the bonding curve's reserve ratio, and "0x4d39dc70b6c840799435d1f036d773db85fedc9a" in this case the player's address.

To get a player's bonding curve address:
```
bloom_factory.getCurve("player's wallet address")
```

To create a bonding curve object in the truffle console:
```
let bondingCurve = await BloomCurve.at("bonding curve address")
```

To deposit tokens to the bonding curve, one needs first to approve a transfer:
```
let erc20Token = await MockErc20.at("Mock USDC address")
erc20Token.approve(bondingCurve.address, Web3.utils.toBN("1000000000000000000"), {from: accounts[0]})
```

To mint continuous tokens / to deposit usdc to the bonding curve:
```
bondingCurve.mint(Web3.utils.toBN("1000000000000000000"), {from: accounts[0]})
```

To redeem the continuous tokens:
```
bondingCurve.redeem(Web3.utils.toBN("1000"), {from: accounts[0]})
```

To see how much continuous tokens one would get for depositing a given amount of usdc:
```
bondingCurve.getContinuousMintAmount(Web3.utils.toBN("usdc_amount"))
```

To see how much usdc one would get for redeeming a given amount of continuous tokens:
```
bondingCurve.getContinuousRedeemAmount(Web3.utils.toBN("continuous_token_amount"))
```