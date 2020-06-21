const config = require('../truffle'),
    Organizations = artifacts.require('./Organizations.sol'),
    Histories = artifacts.require('./Histories.sol');
const zcbc = require('zcom-blockchain-cp');

module.exports = function(deployer, network) {
    deployer.deploy(Histories, config.networks[network].gmoCns, Organizations.address).then(() => {
        zcbc.saveContractToFile('History', Histories.address, JSON.stringify(Histories.abi));
    });
};
