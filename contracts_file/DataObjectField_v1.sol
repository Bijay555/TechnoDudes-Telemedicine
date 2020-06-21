pragma solidity ^0.4.17;

import "./VersionField.sol";

contract DataObjectField_v1 is VersionField {
    struct Field {
        bool isCreated;
        address owner;
        bool isRemoved;
        mapping(address => mapping (bytes32 => bool)) allowCnsContracts;
        mapping(address => bool) allowContracts;
        bytes32[3] hashes;
        bytes32 readerId;
        bytes32 writerId;
        uint tmpWriteTimestamp;
        uint writeTimestamp;
    }

    mapping (bytes32 => Field) public fields;

    function allowCnsContracts(bytes32 _id, address _cns, bytes32 _contractName) public constant returns (bool) {
        return fields[_id].allowCnsContracts[_cns][_contractName];
    }

    function allowContracts(bytes32 _id, address _allowContract) public constant returns (bool) {
        return fields[_id].allowContracts[_allowContract];
    }

    function hashes(bytes32 _id) public constant returns (bytes32[3]) {
        return fields[_id].hashes;
    }

    function DataObjectField_v1(ContractNameService _cns) VersionField(_cns, "DataObject") public {}

    /** OVERRIDE */
    function setDefault(bytes32 _id) private {
        bytes32[3] memory emptyArray;
        fields[_id] = Field({ isCreated: true, owner: 0, isRemoved: false, hashes: emptyArray, readerId: 0, writerId: 0, tmpWriteTimestamp: 0, writeTimestamp: 0 });
    }

    /** OVERRIDE */
    function existIdAtCurrentVersion(bytes32 _id) public constant returns (bool) {
        return fields[_id].isCreated;
    }

    function create(bytes32 _id, address _owner, bytes32[3] _hashes, bytes32 _readerId, bytes32 _writerId, uint _tmpWriteTimestamp) public onlyByNextVersionOrVersionLogic {
        require(!exist(_id));
        fields[_id] = Field({ isCreated: true, owner: _owner, isRemoved: false, hashes: _hashes, readerId: _readerId, writerId: _writerId, tmpWriteTimestamp: _tmpWriteTimestamp, writeTimestamp: 0 });
    }

    function remove(bytes32 _id) public onlyByNextVersionOrVersionLogic {
        require(exist(_id));
        fields[_id].isRemoved = true;
    }

    function getIsRemoved(bytes32 _id) public constant returns (bool) {
        if (shouldReturnDefault(_id)) return false;
        return fields[_id].isRemoved;
    }

    function setAllowCnsContract(bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) public onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].allowCnsContracts[_cns][_contractName] = _isAdded;
    }

    function isAllowCnsContract(address _cns, bytes32 _contractName, bytes32 _id) public constant returns (bool) {
        if (shouldReturnDefault(_id)) return false;
        return fields[_id].allowCnsContracts[_cns][_contractName];
    }

    function setAllowContract(bytes32 _id, address _allowContract, bool _isAdded) public onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].allowContracts[_allowContract] = _isAdded;
    }

    function isAllowContract(address _allowContract, bytes32 _id) public constant returns (bool) {
        if (shouldReturnDefault(_id)) return false;
        return fields[_id].allowContracts[_allowContract];
    }

    function setOwner(bytes32 _id, address _owner) public onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].owner = _owner;
    }

    function getOwner(bytes32 _id) public constant returns (address) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].owner;
    }

    function setHash(bytes32 _id, uint _idx, bytes32 _hash) public onlyByNextVersionOrVersionLogic {
        require(_idx <= 2);
        prepare(_id);
        fields[_id].hashes[_idx] = _hash;
    }

    function getHash(bytes32 _id, uint _idx) public constant returns (bytes32) {
        if (_idx > 2) return 0;
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].hashes[_idx];
    }

    function setReaderId(bytes32 _id, bytes32 _readerId) public onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].readerId = _readerId;
    }

    function setWriterId(bytes32 _id, bytes32 _writerId) public onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].writerId = _writerId;
    }

    function getReaderId(bytes32 _id) public constant returns (bytes32) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].readerId;
    }

    function getWriterId(bytes32 _id) public constant returns (bytes32) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].writerId;
    }

    function setTmpWriteTimestamp(bytes32 _id, uint _tmpWriteTimestamp) public onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].tmpWriteTimestamp = _tmpWriteTimestamp;
    }

    function getTmpWriteTimestamp(bytes32 _id) public constant returns (uint) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].tmpWriteTimestamp;
    }

    function setWriteTimestamp(bytes32 _id, uint _writeTimestamp) public onlyByNextVersionOrVersionLogic {
        prepare(_id);
        fields[_id].writeTimestamp = _writeTimestamp;
    }

    function getWriteTimestamp(bytes32 _id) public constant returns (uint) {
        if (shouldReturnDefault(_id)) return 0;
        return fields[_id].writeTimestamp;
    }
}