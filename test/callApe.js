const { ethers } = require("hardhat");

async function main() {
  // 获取部署者的签名
  const [deployer] = await ethers.getSigners();

  // 部署合约地址
  const contractAddress = "0x948B3c65b89DF0B4894ABE91E6D02FE579834F8F"; // 替换为您实际的合约地址

  // 获取合约工厂
  const Ape = await ethers.getContractFactory("Ape");

  // 连接到已部署的合约
  const ape = Ape.attach(contractAddress);

  // 调用合约中的函数
  const result = await ape.mint(
    "0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6",11); // 替换为您要调用的实际函数名和参数

  console.log("函数调用结果:", result);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

//error
//error
