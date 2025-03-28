const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying contract...");

    const privateKey = "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d";
    const deployer = new ethers.Wallet(privateKey, ethers.provider);
    console.log("Deployer address: ", deployer.address);

    const Ape = await ethers.getContractFactory("Ape", deployer);
    console.log("Ape contract factory created.");

    const ape = await Ape.deploy("camt_ape", "camt");
    console.log("Transaction sent. Waiting for deployment...");
    await ape.waitForDeployment();

    console.log("Ape contract deployed at:", await ape.getAddress());
}

main().catch((error) => {
    console.error("Deployment error:", error);
    process.exit(1);
})