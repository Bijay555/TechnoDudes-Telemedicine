pragma solidity ^0.4.17;

import "./VersionLogic.sol";
import "./AddressGroupField_v1.sol";
import "./AddressGroupEvent_v1.sol";

contract AddressGroupLogic_v1 is VersionLogic {
    AddressGroupField_v1 public field_v1;
    AddressGroupEvent_v1 public event_v1;

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

    function AddressGroupLogic_v1(ContractNameService _cns, AddressGroupField_v1 _field, AddressGroupEvent_v1 _event) VersionLogic(_cns, "AddressGroup") public {
        field_v1 = _field;
        event_v1 = _event;
    }

    function create(address _sender, bytes32 _id, address _owner, address[] _members, address _cns, bytes32 _contractName) public onlyByVersionContractOrLogic {
        field_v1.create(_id, _owner);
        event_v1.create(_sender, _id);
        event_v1.setOwner(_sender, _id, _owner);

        for (uint i = 0; i < _members.length; i++) {
            field_v1.setMember(_id, _members[i], true);
            event_v1.setMember(_sender, _id, _members[i], true);
        }

        setAllowCnsContract(_sender, _id, _cns, _contractName, true);
    }

    function createWithAllowContract(address _sender, bytes32 _id, address _owner, address[] _members, address _allowContract) public onlyByVersionContractOrLogic {
        field_v1.create(_id, _owner);
        event_v1.create(_sender, _id);
        event_v1.setOwner(_sender, _id, _owner);

        for (uint i = 0; i < _members.length; i++) {
            field_v1.setMember(_id, _members[i], true);
            event_v1.setMember(_sender, _id, _members[i], true);
        }

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

    function addMember(address _sender, bytes32 _id, address _member) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        field_v1.setMember(_id, _member, true);
        event_v1.setMember(_sender, _id, _member, true);
    }

    function removeMember(address _sender, bytes32 _id, address _member) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        field_v1.setMember(_id, _member, false);
        event_v1.setMember(_sender, _id, _member, false);
    }

    function addMembers(address _sender, bytes32 _id, address[] _members) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        for (uint i = 0; i < _members.length; i++) {
            field_v1.setMember(_id, _members[i], true);
            event_v1.setMember(_sender, _id, _members[i], true);
        }
    }

    function removeMembers(address _sender, bytes32 _id, address[] _members) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        for (uint i = 0; i < _members.length; i++) {
            field_v1.setMember(_id, _members[i], false);
            event_v1.setMember(_sender, _id, _members[i], false);
        }
    }

    function addChild(address _sender, bytes32 _id, bytes32 _child) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        field_v1.addChild(_id, _child);
        event_v1.setChild(_sender, _id, _child, true);
    }

    function removeChild(address _sender, bytes32 _id, bytes32 _child) public onlyByVersionContractOrLogic onlyFromAllowContractOrCnsContractLogic(_sender, _id) onlyActive(_id) {
        field_v1.removeChild(_id, _child);
        event_v1.setChild(_sender, _id, _child, false);
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

    function isMember(address _account, bytes32 _id) public constant returns (bool) {
        if (!isActive(_id)) return false;
        return isMemberInDescendant(_account, _id);
    }

    function getChild(bytes32 _id, uint _idx) public constant returns (bytes32) {
        if (!isActive(_id)) return 0;
        return field_v1.getChild(_id, _idx);
    }

    function getChildrenLength(bytes32 _id) public constant returns (uint) {
        if (!isActive(_id)) return 0;
        return field_v1.getChildrenLength(_id);
    }

    function setAllowCnsContract(address _sender, bytes32 _id, address _cns, bytes32 _contractName, bool _isAdded) internal {
        field_v1.setAllowCnsContract(_id, _cns, _contractName, _isAdded);
        event_v1.setAllowCnsContract(_sender, _id, _cns, _contractName, _isAdded);
    }

    function setAllowContract(address _sender, bytes32 _id, address _allowContract, bool _isAdded) internal {
        field_v1.setAllowContract(_id, _allowContract, _isAdded);
        event_v1.setAllowContract(_sender, _id, _allowContract, _isAdded);
    }

    function isMemberInDescendant(address _account, bytes32 _id) internal constant returns (bool) {
        if (!isActive(_id)) return false;
        if (field_v1.isMember(_account, _id)) return true;
        for (uint i = 0; i < field_v1.getChildrenLength(_id); i++) {
            if (isMemberInDescendant(_account, field_v1.getChild(_id, i))) return true;
        }
        return false;
    }
}
