pragma solidity ^0.4.17;

import './ContractNameService.sol';
import './AddressGroup.sol';
import './DataObject.sol';
import './Organizations.sol';

contract Histories {

    struct History {
        bool isCreated;
        bytes32 allowGroupId;
        bytes32 userDataObjectId;
        bytes32[] recordObjectIds;
    }

    mapping(address => History) public histories; // patiend address => medical record

    ContractNameService public gmoCns;
    Organizations public organizations;
    mapping(address => uint) public nonces;

    function Histories(ContractNameService _gmoCns, Organizations _organizations) {
        gmoCns = _gmoCns;
        organizations = _organizations;
    }


    function getAddressGroupInstance() public constant returns (AddressGroup) {
        return AddressGroup(gmoCns.getLatestContract('AddressGroup'));
    }

    function getDataObjectInstance() public constant returns (DataObject) {
        return DataObject(gmoCns.getLatestContract('DataObject'));
    }

    modifier onlyByOrganizationMember(address _addr) {
        bytes32 organizationKey = organizations.memberOrganizationKeys(_addr);
        assert(organizations.isMember(_addr) && organizations.isActive(organizationKey));
        _;
    }

    function createHistory(bytes32 _objectId, bytes32 _dataHash) public returns (bool) {
        return createHistoryPrivate(msg.sender, _objectId, _dataHash);
    }

    function createHistoryWithSign(bytes32 _objectId, bytes32 _dataHash, uint _nonce, bytes _sign) public returns (bool) {
        bytes32 hash = calcEnvHash('createHistoryWithSign');
        hash = keccak256(hash, _objectId);
        hash = keccak256(hash, _dataHash);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return createHistoryPrivate(from, _objectId, _dataHash);
    }

    function createHistoryPrivate(address _from, bytes32 _objectId, bytes32 _dataHash) private returns (bool) {
        if (histories[_from].isCreated) return false;

        bytes32 allowGroupId = calculateUniqueGroupId(bytes32(_from));
        address[] memory empty;
        getAddressGroupInstance().createWithAllowContract(allowGroupId, _from, empty, this);

        getDataObjectInstance().createWithAllowContract(_objectId, _from, _dataHash, this);
        bytes32 readerId = getDataObjectInstance().getReaderId(_objectId);
        bytes32 writerId = getDataObjectInstance().getWriterId(_objectId);
        getAddressGroupInstance().addChild(readerId, allowGroupId);
        getAddressGroupInstance().addChild(writerId, allowGroupId);

        bytes32[] memory recordObjectIds;

        histories[_from] = History({isCreated:true, allowGroupId:allowGroupId, userDataObjectId: _objectId, recordObjectIds: recordObjectIds});
        return true;
    }

    function calculateUniqueGroupId(bytes32 _seed) private constant returns (bytes32) {
        bytes32 tmpId = keccak256(_seed);
        while(true) {
            if (!getAddressGroupInstance().exist(tmpId)) {
                return tmpId;
            }
            tmpId = keccak256(tmpId);
        }
    }

    function remove() public returns (bool) {
        return removePrivate(msg.sender);
    }

    function removeWithSign(uint _nonce, bytes _sign) public returns (bool) {
        bytes32 hash = calcEnvHash('removeWithSign');
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return removePrivate(from);
    }

    function removePrivate(address _from) private returns (bool) {
        if (!histories[_from].isCreated) return false;
        histories[_from].isCreated = false;
        getAddressGroupInstance().remove(histories[_from].allowGroupId);
        getDataObjectInstance().remove(histories[_from].userDataObjectId);
        delete histories[_from].allowGroupId;
        delete histories[_from].userDataObjectId;
        for (uint i=0; i<histories[_from].recordObjectIds.length; i++) {
            getDataObjectInstance().remove(histories[_from].recordObjectIds[i]);
        }
        delete histories[_from].recordObjectIds;
        return true;
    }

    function addAllowGroup(bytes32 _organizationKey) public returns (bool) {
        return addAllowGroupPrivate(msg.sender, _organizationKey);
    }

    function addAllowGroupWithSign(bytes32 _organizationKey, uint _nonce, bytes _sign) public returns (bool) {
        bytes32 hash = calcEnvHash('addAllowGroupWithSign');
        hash = keccak256(hash, _organizationKey);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return addAllowGroupPrivate(from, _organizationKey);
    }

    function addAllowGroupPrivate(address _from, bytes32 _organizationKey) private returns (bool) {
        if (!histories[_from].isCreated) return false;
        if (!organizations.isActive(_organizationKey)) return false;
        bytes32 memberGroupId = organizations.getMemberGroupId(_organizationKey);
        getAddressGroupInstance().addChild(histories[_from].allowGroupId, memberGroupId);
        return true;
    }

    function removeAllowGroup(bytes32 _organizationKey) public returns (bool) {
        return removeAllowGroupPrivate(msg.sender, _organizationKey);
    }

    function removeAllowGroupWithSign(bytes32 _organizationKey, uint _nonce, bytes _sign) public returns (bool) {
        bytes32 hash = calcEnvHash('removeAllowGroupWithSign');
        hash = keccak256(hash, _organizationKey);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return removeAllowGroupPrivate(from, _organizationKey);
    }

    function removeAllowGroupPrivate(address _from, bytes32 _organizationKey) private returns (bool) {
        if (!histories[_from].isCreated) return false;
        bytes32 memberGroupId = organizations.getMemberGroupId(_organizationKey);
        getAddressGroupInstance().removeChild(histories[_from].allowGroupId, memberGroupId);
        return true;
    }

    function addRecord(address _patient, bytes32 _objectId, bytes32 _dataHash) public returns (bool) {
        return addRecordPrivate(msg.sender, _patient, _objectId, _dataHash);
    }

    function addRecordWithSign(address _patient, bytes32 _objectId, bytes32 _dataHash, uint _nonce, bytes _sign) public returns (bool) {
        bytes32 hash = calcEnvHash('addRecordWithSign');
        hash = keccak256(hash, _patient);
        hash = keccak256(hash, _objectId);
        hash = keccak256(hash, _dataHash);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return addRecordPrivate(from, _patient, _objectId, _dataHash);
    }

    function addRecordPrivate(address _from, address _patient, bytes32 _objectId, bytes32 _dataHash) private returns (bool) {
        if (!histories[_patient].isCreated) return false;
        if (!getAddressGroupInstance().isMember(_from, histories[_patient].allowGroupId)) return false;
        getDataObjectInstance().createWithAllowContract(_objectId, _patient, _dataHash, this);

        bytes32 readerId = getDataObjectInstance().getReaderId(_objectId);
        bytes32 writerId = getDataObjectInstance().getWriterId(_objectId);
        getAddressGroupInstance().addChild(readerId, histories[_patient].allowGroupId);
        getAddressGroupInstance().addChild(writerId, histories[_patient].allowGroupId);
        histories[_patient].recordObjectIds.push(_objectId);

        return true;
    }

    function isAllowGroup(bytes32 _organizationKey, address _patient) public constant returns (bool) {
        if (!histories[_patient].isCreated) return false;
        bytes32 memberGroupId = organizations.getMemberGroupId(_organizationKey);
        for (uint i = 0; i < getAddressGroupInstance().getChildrenLength(histories[_patient].allowGroupId); i++) {
            if (getAddressGroupInstance().getChild(histories[_patient].allowGroupId, i) == memberGroupId) return true;
        }
        return false;
    }

    function getPatientDataObjectId(address _patient) public constant returns (bytes32) {
        if (!histories[_patient].isCreated) return 0;
        return histories[_patient].userDataObjectId;
    }

    function getRecordObjectId(address _patient, uint _index) public constant returns (bytes32) {
        if (!histories[_patient].isCreated) return 0;
        return histories[_patient].recordObjectIds[_index];
    }

    function getRecordLength(address _patient) public constant returns (uint) {
        if (!histories[_patient].isCreated) return 0;
        return histories[_patient].recordObjectIds.length;
    }

    function calcEnvHash(bytes32 _functionName) constant returns (bytes32 hash) {
        hash = keccak256(this);
        hash = keccak256(hash, _functionName);
    }

    function recoverAddress(bytes32 _hash, bytes _sign) constant returns (address recoverdAddr) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        require(_sign.length == 65);

        assembly {
            r := mload(add(_sign, 32))
            s := mload(add(_sign, 64))
            v := byte(0, mload(add(_sign, 96)))
        }

        if (v < 27) v += 27;
        require(v == 27 || v == 28);

        recoverdAddr = ecrecover(_hash, v, r, s);
        require(recoverdAddr != 0);
    }
}


