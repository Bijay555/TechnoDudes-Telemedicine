pragma solidity ^0.4.17;

contract ContractNameService {
    address public provider = msg.sender;
    mapping (bytes32 => ContractSet[]) public contracts;

    struct ContractSet {
        address main;
        address logic;
    }

    event SetContractEvent(bytes32 indexed name, uint version, address indexed main, address indexed logic);

    modifier onlyByProvider() {
        require(msg.sender == provider);
        _;
    }

    function setContract(bytes32 _name, uint _version, address _main, address _logic) public onlyByProvider {
        require(_version <= getLatestVersion(_name) + 1);

        ContractSet memory set = ContractSet(_main, _logic);
        if (getLatestVersion(_name) + 1 == _version) {
            contracts[_name].push(set);
        } else {
            contracts[_name][_version - 1] = set;
        }
        SetContractEvent(_name, _version, _main, _logic);
    }

    function isVersionContract(address _sender, bytes32 _name) public constant returns (bool) {
        for (uint i = 0; i < contracts[_name].length; i++) {
            if (contracts[_name][i].main == _sender) return true;
        }
        return false;
    }

    function isVersionLogic(address _sender, bytes32 _name) public constant returns (bool) {
        for (uint i = 0; i < contracts[_name].length; i++) {
            if (contracts[_name][i].logic == _sender) return true;
        }
        return false;
    }

    function getContract(bytes32 _name, uint _version) public constant returns (address) {
        if (_version == 0 || getLatestVersion(_name) < _version) return 0;
        return contracts[_name][_version - 1].main;
    }

    function getLatestVersion(bytes32 _name) public constant returns (uint) {
        return contracts[_name].length;
    }

    function getLatestContract(bytes32 _name) public constant returns (address) {
        return getContract(_name, getLatestVersion(_name));
    }
}