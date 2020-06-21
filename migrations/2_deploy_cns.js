const ContractNameService = artifacts.require('solidity/contracts/ContractNameService.sol');
const zcbc = require('zcom-blockchain-cp');

module.exports = function(deployer, network, accounts) {
    deployer.deploy(ContractNameService).then(() => {
        zcbc.registerCNS(ContractNameService.address, true);
    })
}
