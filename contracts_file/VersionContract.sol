pragma solidity ^0.4.17;

import "./Utils.sol";
import "./CnsController.sol";

contract VersionContract is CnsController, Utils {
    function VersionContract(ContractNameService _cns, bytes32 _contractName) CnsController(_cns, _contractName) public {}

    function calcEnvHash(bytes32 _functionName) internal constant returns (bytes32) {
        bytes32 h = keccak256(cns);
        h = keccak256(h, contractName);
        h = keccak256(h, _functionName);
        return h;
    }
}