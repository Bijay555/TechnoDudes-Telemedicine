pragma solidity ^0.4.17;

import "./VersionEvent.sol";

contract DataObjectEvent_v1 is VersionEvent {
    event createEvent(address indexed _sender, bytes32 indexed _id);
    event removeEvent(address indexed _sender, bytes32 indexed _id);
    event setAllowCnsContractEvent(address indexed _sender, bytes32 indexed _id, address indexed _cns, bytes32 _contractName, bool _isAdded);
    event setAllowContractEvent(address indexed _sender, bytes32 indexed _id, address indexed _allowContract, bool _isAdded);
    event setOwnerEvent(address indexed _sender, bytes32 indexed _id, address indexed _owner);
    event setHashEvent(address indexed _sender, bytes32 indexed _id, address indexed _writer, bytes32 _hash, uint _targetIdx);
    event setReaderIdEvent(address indexed _sender, bytes32 indexed _id, bytes32 indexed _readerId);
    event setWriterIdEvent(address indexed _sender, bytes32 indexed _id, bytes32 indexed _writerId);

    function DataObjectEvent_v1(ContractNameService _cns) VersionEvent(_cns, "DataObject") public {}

    function create(address _sender, bytes32 _id) public onlyByVersionLogic {
        createEvent(_sender, _id);
    }

    function remove(address _sender, bytes32 _id) public onlyByVersionLogic {
        removeEvent(_sender, _id);
    }

    function setAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) public onlyByVersionLogic {
        setAllowCnsContractEvent(_sender, _id, _cns, _contractName, _isAdded);
    }

    function setAllowContract(address _sender, bytes32 _id, address _allowContract, bool _isAdded) public onlyByVersionLogic {
        setAllowContractEvent(_sender, _id, _allowContract, _isAdded);
    }

    function setOwner(address _sender, bytes32 _id, address _owner) public onlyByVersionLogic {
        setOwnerEvent(_sender, _id, _owner);
    }

    function setHash(address _sender, bytes32 _id, address _writer, bytes32 _hash, uint _targetIdx) public onlyByVersionLogic {
        setHashEvent(_sender, _id, _writer, _hash, _targetIdx);
    }

    function setReaderId(address _sender, bytes32 _id, bytes32 _readerId) public onlyByVersionLogic {
        setReaderIdEvent(_sender, _id, _readerId);
    }

    function setWriterId(address _sender, bytes32 _id, bytes32 _writerId) public onlyByVersionLogic {
        setWriterIdEvent(_sender, _id, _writerId);
    }
}