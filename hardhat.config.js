require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    localdev: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
      // accounts 字段在这种情况下不会自动注入到 ethers.getSigners()，需要手动使用私钥
      accounts: ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"]
    },
  },
};