const config = require('../truffle'),
    Organizations = artifacts.require('./Organizations.sol');
const zcbc = require('zcom-blockchain-cp');

module.exports = function(deployer, network) {
    deployer.deploy(Organizations, config.networks[network].gmoCns).then(() => {
        return zcbc.saveContractToFile('Organization', Organizations.address, JSON.stringify(Organizations.abi));
    });
};
