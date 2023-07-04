
const hre = require("hardhat");

async function main() {
    // const Cfo = await hre.ethers.getContractFactory("cfoToken");
    // const cfo = await Cfo.deploy();
    // await cfo.deployed();
    // console.log("CFO Token deploy sucessful", cfo.address); // 0xAc17A24dc039ddaBE3C04d294A6A82382901F267
    // const Abc = await hre.ethers.getContractFactory("abcToken");
    // const abc = await Abc.deploy();
    // await abc.deployed();
    // console.log("ABC Token deploy sucessful", abc.address);



    console.log("Now deploying bulk");
    const Bulk = await hre.ethers.getContractFactory("BulkFactory");
    const bulk = await Bulk.deploy(); 
    await bulk.deployed();
    console.log("BulkFactory deploy sucessful", bulk.address); // 0xFC1f2517b07BDF376cBBE246a7De87eDeE4979de
}

// https://testnet.snowtrace.io/address/0x7847fa7B9eBe31cb960E9Ac1f3a6F0c4276c9C1f#code
//  0x7847fa7B9eBe31cb960E9Ac1f3a6F0c4276c9C1f Bulk factory
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
