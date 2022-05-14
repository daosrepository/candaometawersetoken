const CandaoToken = artifacts.require("CandaoToken");
const { BN } = require("web3-utils");

module.exports = async function (deployer, network) {
    const CONFIG = require('dotenv').config().parsed;
    const owner = CONFIG.FROM_ADDRESS;
    const test_owner = CONFIG.TEST_FROM_ADDRESS;

    if(network == "mainnet") {
        await deployer.deploy(CandaoToken, "Candao", "CDO", [owner], [new BN("2000000000000000000000000000")]);
    } else {
        await deployer.deploy(CandaoToken, "Candao", "CDO", [test_owner], [new BN("2000000000000000000000000000")]);
    }
}
