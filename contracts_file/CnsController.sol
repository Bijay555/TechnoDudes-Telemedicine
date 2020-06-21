pragma solidity ^0.4.17;

import "./ContractNameService.sol";

contract CnsController {
    address public provider = msg.sender;
    ContractNameService public cns;
    bytes32 public contractName;

    modifier onlyByProvider() {
        require(msg.sender == provider);
        _;
    }

    modifier onlyByVersionContract() {
        require(isVersionContract());
        _;
    }

    modifier onlyByVersionLogic() {
        require(isVersionLogic());
        _;
    }

    modifier onlyByVersionContractOrLogic() {
        require(isVersionContractOrLogic());
        _;
    }

    function CnsController(ContractNameService _cns, bytes32 _contractName) public {
        cns = _cns;
        contractName = _contractName;
    }

    function getCns() public constant returns (ContractNameService) {
        return cns;
    }

    function getContractName() public constant returns (bytes32) {
        return contractName;
    }

    function isVersionContract() public constant returns (bool) {
        return cns.isVersionContract(msg.sender, contractName);
    }

    function isVersionLogic() public constant returns (bool) {
        return cns.isVersionLogic(msg.sender, contractName);
    }

    function isVersionContractOrLogic() public constant returns (bool) {
        return cns.isVersionContract(msg.sender, contractName) || cns.isVersionLogic(msg.sender, contractName);
    }
}