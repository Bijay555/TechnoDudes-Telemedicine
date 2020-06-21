pragma solidity ^0.4.17;

import "./VersionLogic.sol";
import "./AddressGroup.sol";
import "./DataObjectField_v1.sol";
import "./DataObjectEvent_v1.sol";

contract DataObjectLogic_v1 is VersionLogic {
    DataObjectField_v1 public field_v1;
    DataObjectEvent_v1 public event_v1;

    address[] public fixers;

    enum Modification {
        Add,
        Remove
    }

    event ModifyFixerEvent(address indexed fixer, Modification modification);

    modifier onlyFromAllowContractOrCnsContractLogic(address _sender, bytes32 _id) {
        if (!isAllowContract(_sender, _id)) {
            VersionLogic logic = VersionLogic(_sender);
            require(isAllowCnsContract(logic.getCns(), logic.getContractName(), _id) && logic.getCns().isVersionLogic(_sender, logic.getContractName()));
        }
        _;
    }

    modifier onlyActive(bytes32 _id) {
        require(isActive(_id));
        _;
    }

    modifier onlyFromOwnerOrWriter(address _sender, bytes32 _id) {
        require(canWrite(_sender, _id));
        _;
    }

    modifier onlyFromFixers(address _sender) {
        require(isFixer(_sender));
        _;
    }

    function DataObjectLogic_v1(ContractNameService _cns, DataObjectField_v1 _field, DataObjectEvent_v1 _event) VersionLogic(_cns, "DataObject") public {
        field_v1 = _field;
        event_v1 = _event;
    }

    function isFixer(address _addr) public constant returns (bool) {
        for (uint i = 0; i < fixers.length; i++) {
            if (fixers[i] == _addr) return true;
        }
        return false;
    }

    function addFixer(address _fixer) public onlyByProvider {
        require(!isFixer(_fixer));
        fixers.push(_fixer);
        ModifyFixerEvent(_fixer, Modification.Add);
    }

    function removeFixer(address _fixer) public onlyByProvider {
        require(isFixer(_fixer));
        for (uint i = 0; i < fixers.length; i++) {
            if (fixers[i] == _fixer) {
                fixers[i] = fixers[fixers.length - 1];
                fixers.length--;
                ModifyFixerEvent(_fixer, Modification.Remove);
                return;
            }
        }
    }

    function create(address _sender, bytes32 _id, address _owner, bytes32 _hash, address _cns, bytes32 _contractName) public onlyByVersionContractOrLogic {
        var (readerId, writerId) = createReaderWriter(_id, _owner, _cns, _contractName);
        createDataObject(_sender, _id, _owner, _hash, readerId, writerId);

        setAllowCnsContract(_sender, _id, _cns, _contractName, true);
    }

    function createWithAllowContract(address _sender, bytes32 _id, address _owner, bytes32 _hash, address _allowContract) public onlyByVersionContractOrLogic {
        var (readerId, writerId) = createReaderWriterWithAllowContract(_id, _owner, _allowContract);
        createDataObject(_sender, _id, _owner, _hash, readerId, writerId);

        setAllowContract(_sender, _id, _allowContract, true);
    }

    function remove(address _sender, bytes32 _id) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        field_v1.remove(_id);
        event_v1.remove(_sender, _id);
    }

    function addAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        setAllowCnsContract(_sender, _id, _cns, _contractName, true);
    }

    function removeAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        setAllowCnsContract(_sender, _id, _cns, _contractName, false);
    }

    function addAllowContract(address _sender, bytes32 _id, address _allowContract) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        setAllowContract(_sender, _id, _allowContract, true);
    }

    function removeAllowContract(address _sender, bytes32 _id, address _allowContract) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        setAllowContract(_sender, _id, _allowContract, false);
    }

    function setOwner(address _sender, bytes32 _id, address _owner) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        field_v1.setOwner(_id, _owner);
        event_v1.setOwner(_sender, _id, _owner);
    }

    function setHashByWriter(address _sender, bytes32 _id, address _writer, bytes32 _hash) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyFromOwnerOrWriter(_writer, _id) onlyActive(_id) {
        setHash(_sender, _id, _writer, _hash, 2, 1);
    }

    function setHashByProvider(address _sender, bytes32 _id, bytes32 _hash) public onlyByVersionContractOrLogic onlyFromFixers(_sender) onlyActive(_id) {
        setHash(_sender, _id, _sender, _hash, 1, 2);
    }

    function setReaderId(address _sender, bytes32 _id, bytes32 _readerId) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        field_v1.setReaderId(_id, _readerId);
        event_v1.setReaderId(_sender, _id, _readerId);
    }

    function setWriterId(address _sender, bytes32 _id, bytes32 _writerId) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        field_v1.setWriterId(_id, _writerId);
        event_v1.setWriterId(_sender, _id, _writerId);
    }

    function exist(bytes32 _id) public constant returns (bool) {
        return field_v1.exist(_id);
    }

    function isActive(bytes32 _id) public constant returns (bool) {
        return exist(_id) && !field_v1.getIsRemoved(_id);
    }

    function isAllowCnsContract(address _cns, bytes32 _contractName, bytes32 _id) public constant returns (bool) {
        if (!isActive(_id)) return false;
        return field_v1.isAllowCnsContract(_cns, _contractName, _id);
    }

    function isAllowContract(address _allowContract, bytes32 _id) public constant returns (bool) {
        if (!isActive(_id)) return false;
        return field_v1.isAllowContract(_allowContract, _id);
    }

    function getOwner(bytes32 _id) public constant returns (address) {
        if (!isActive(_id)) return 0;
        return field_v1.getOwner(_id);
    }

    function getHash(bytes32 _id) public constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getHash(_id, 0);
    }

    function getWriteTimestamp(bytes32 _id) public constant returns (uint) {
        if (!isActive(_id)) return 0;
        return field_v1.getWriteTimestamp(_id);
    }

    function getReaderId(bytes32 _id) public constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getReaderId(_id);
    }

    function getWriterId(bytes32 _id) public constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getWriterId(_id);
    }

    function canRead(address _account, bytes32 _id) public constant returns (bool) {
        if (!isActive(_id)) return false;
        if (getOwner(_id) == _account) return true;
        return getAddressGroupInstance().isMember(_account, field_v1.getReaderId(_id));
    }

    function canWrite(address _account, bytes32 _id) public constant returns (bool) {
        if (!isActive(_id)) return false;
        if (getOwner(_id) == _account) return true;
        return getAddressGroupInstance().isMember(_account, field_v1.getWriterId(_id));
    }

    function createDataObject(address _sender, bytes32 _id, address _owner, bytes32 _hash, bytes32 _readerId, bytes32 _writerId) internal {
        bytes32[3] memory hashes;
        hashes[2] = _hash;
        field_v1.create(_id, _owner, hashes, _readerId, _writerId, now);
        event_v1.create(_sender, _id);
        event_v1.setOwner(_sender, _id, _owner);
        event_v1.setHash(_sender, _id, _owner, _hash, 2);
        event_v1.setReaderId(_sender, _id, _readerId);
        event_v1.setWriterId(_sender, _id, _writerId);
    }

    function createReaderWriter(bytes32 _id, address _owner, address _cns, bytes32 _contractName) internal returns (bytes32 readerId, bytes32 writerId) {
        address[] memory emptyAddresses;
        readerId = calculateUniqueGroupId(_id);
        getAddressGroupInstance().create(readerId, _owner, emptyAddresses, _cns, _contractName);
        writerId = calculateUniqueGroupId(readerId);
        getAddressGroupInstance().create(writerId, _owner, emptyAddresses, _cns, _contractName);
    }

    function createReaderWriterWithAllowContract(bytes32 _id, address _owner, address _allowContract) internal returns (bytes32 readerId, bytes32 writerId) {
        address[] memory emptyAddresses;
        readerId = calculateUniqueGroupId(_id);
        getAddressGroupInstance().createWithAllowContract(readerId, _owner, emptyAddresses, _allowContract);
        writerId = calculateUniqueGroupId(readerId);
        getAddressGroupInstance().createWithAllowContract(writerId, _owner, emptyAddresses, _allowContract);
    }

    function setAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) internal {
        field_v1.setAllowCnsContract(_id, _cns, _contractName, _isAdded);
        event_v1.setAllowCnsContract(_sender, _id, _cns, _contractName, _isAdded);
    }

    function setAllowContract(address _sender, bytes32 _id, address _allowContract, bool _isAdded) internal {
        field_v1.setAllowContract(_id, _allowContract, _isAdded);
        event_v1.setAllowContract(_sender, _id, _allowContract, _isAdded);
    }

    function setHash(address _sender, bytes32 _id, address _writer, bytes32 _hash, uint _targetIdx, uint _compareIdx) internal {
        field_v1.setHash(_id, _targetIdx, _hash);
        event_v1.setHash(_sender, _id, _writer, _hash, _targetIdx);
        if (_targetIdx == 2) field_v1.setTmpWriteTimestamp(_id, now);

        if (_hash == field_v1.getHash(_id, _compareIdx) && _hash != field_v1.getHash(_id, 0)) {
            field_v1.setHash(_id, 0, _hash);
            field_v1.setWriteTimestamp(_id, field_v1.getTmpWriteTimestamp(_id));
            event_v1.setHash(_sender, _id, _writer, _hash, 0);
        }
    }

    function getAddressGroupInstance() internal constant returns (AddressGroup) {
        return AddressGroup(cns.getLatestContract("AddressGroup"));
    }

    function calculateUniqueGroupId(bytes32 _seed) internal constant returns (bytes32) {
        bytes32 tmpId = transferUniqueId(_seed);
        while(true) {
            if (!getAddressGroupInstance().exist(tmpId)) {
                return tmpId;
            }
            tmpId = transferUniqueId(tmpId);
        }
    }
}