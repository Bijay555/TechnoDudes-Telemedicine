pragma solidity ^0.4.17;

import "./AddressGroupLogic_v1.sol";
import "./VersionContract.sol";

contract AddressGroup is VersionContract {
    AddressGroupLogic_v1 public logic_v1;

    function AddressGroup(ContractNameService _cns, AddressGroupLogic_v1 _logic) VersionContract(_cns, "AddressGroup") public {
        logic_v1 = _logic;
    }

    function create(bytes32 _id, address _owner, address[] _members, address _cns, bytes32 _contractName) public {
        return logic_v1.create(msg.sender, _id, _owner, _members, _cns, _contractName);
    }

    function createWithAllowContract(bytes32 _id, address _owner, address[] _members, address _allowContract) public {
        return logic_v1.createWithAllowContract(msg.sender, _id, _owner, _members, _allowContract);
    }

    function remove(bytes32 _id) public {
        logic_v1.remove(msg.sender, _id);
    }

    function exist(bytes32 _id) public constant returns (bool) {
        return logic_v1.exist(_id);
    }

    function isActive(bytes32 _id) public constant returns (bool) {
        return logic_v1.isActive(_id);
    }

    function setOwner(bytes32 _id, address _new) public {
        logic_v1.setOwner(msg.sender, _id, _new);
    }

    function getOwner(bytes32 _id) public constant returns (address) {
        return logic_v1.getOwner(_id);
    }

    function addAllowCnsContract(bytes32 _id, address _cns, bytes32 _contractName) public {
        logic_v1.addAllowCnsContract(msg.sender, _id, _cns, _contractName);
    }

    function removeAllowCnsContract(bytes32 _id, address _cns, bytes32 _contractName) public {
        logic_v1.removeAllowCnsContract(msg.sender, _id, _cns, _contractName);
    }

    function isAllowCnsContract(address _cns, bytes32 _contractName, bytes32 _id) public constant returns (bool) {
        return logic_v1.isAllowCnsContract(_cns, _contractName, _id);
    }

    function addAllowContract(bytes32 _id, address _allowContract) public {
        logic_v1.addAllowContract(msg.sender, _id, _allowContract);
    }

    function removeAllowContract(bytes32 _id, address _allowContract) public {
        logic_v1.removeAllowContract(msg.sender, _id, _allowContract);
    }

    function isAllowContract(address _allowContract, bytes32 _id) public constant returns (bool) {
        return logic_v1.isAllowContract(_allowContract, _id);
    }

    function addMember(bytes32 _id, address _member) public {
        logic_v1.addMember(msg.sender, _id, _member);
    }

    function removeMember(bytes32 _id, address _member) public {
        logic_v1.removeMember(msg.sender, _id, _member);
    }

    function addMembers(bytes32 _id, address[] _members) public {
        logic_v1.addMembers(msg.sender, _id, _members);
    }

    function removeMembers(bytes32 _id, address[] _members) public {
        logic_v1.removeMembers(msg.sender, _id, _members);
    }

    function isMember(address _account, bytes32 _id) public constant returns (bool) {
        return logic_v1.isMember(_account, _id);
    }

    function addChild(bytes32 _id, bytes32 _child) public {
        logic_v1.addChild(msg.sender, _id, _child);
    }

    function removeChild(bytes32 _id, bytes32 _child) public {
        logic_v1.removeChild(msg.sender, _id, _child);
    }

    function getChild(bytes32 _id, uint _idx) public constant returns (bytes32) {
        return logic_v1.getChild(_id, _idx);
    }

    function getChildrenLength(bytes32 _id) public constant returns (uint) {
        return logic_v1.getChildrenLength(_id);
    }
}
