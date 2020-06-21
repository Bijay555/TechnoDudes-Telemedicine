const Migrations = artifacts.require('./Migrations.sol');
const zcbc = require('zcom-blockchain-cp');

module.exports = function(deployer) {
    zcbc.confirmToken();
    deployer.deploy(Migrations);
};
