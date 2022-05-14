const Configurator = artifacts.require("Configurator");

module.exports = async function (deployer, network) {
    const CONFIG = require('dotenv').config().parsed;
    const owner = CONFIG.FROM_ADDRESS;
    const test_owner = CONFIG.TEST_FROM_ADDRESS;

    if(network == "mainnet") {
        await deployer.deploy(Configurator, owner);
    } else {
        await deployer.deploy(Configurator, test_owner);
    }
}
