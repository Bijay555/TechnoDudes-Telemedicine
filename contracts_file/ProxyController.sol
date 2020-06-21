pragma solidity ^0.4.14;

import 'zcom-contracts/contracts/VersionContract.sol';
import './ProxyControllerLogic_v1.sol';

contract ProxyController is VersionContract {
    ProxyControllerLogic_v1 public logic_v1;

    function ProxyController(ContractNameService _cns, ProxyControllerLogic_v1 _logic_v1) VersionContract(_cns, 'ProxyController') {
        logic_v1 = _logic_v1;
    }

    function getNonceInOrganizations(address _organizationsAddress, address _addr) public constant returns (uint) {
        return logic_v1.getNonceInOrganizations(_organizationsAddress, _addr);
    }

    function createOrganization(bytes _sign, address _organizationsAddress, bytes32 _organizationKey, bytes32 _name, uint _nonce, bytes _clientSign) public {
        logic_v1.createOrganization(_organizationsAddress, _organizationKey, _name, _nonce, _clientSign);
    }

    function changeOrganizationActivation(bytes _sign, address _organizationsAddress, uint _nonce, bytes _clientSign) public {
        logic_v1.changeOrganizationActivation(_organizationsAddress, _nonce, _clientSign);
    }

    function addOrganizationAdmin(bytes _sign, address _organizationsAddress, address _addr, uint _nonce, bytes _clientSign) public {
        logic_v1.addOrganizationAdmin(_organizationsAddress, _addr, _nonce, _clientSign);
    }

    function removeOrganizationAdmin(bytes _sign, address _organizationsAddress, address _addr, uint _nonce, bytes _clientSign) public {
        logic_v1.removeOrganizationAdmin(_organizationsAddress, _addr, _nonce, _clientSign);
    }

    function addOrganizationMember(bytes _sign, address _organizationsAddress, address _addr, uint _nonce, bytes _clientSign) public {
        logic_v1.addOrganizationMember(_organizationsAddress, _addr, _nonce, _clientSign);
    }

    function removeOrganizationMember(bytes _sign, address _organizationsAddress, address _addr, uint _nonce, bytes _clientSign) public {
        logic_v1.removeOrganizationMember(_organizationsAddress, _addr, _nonce, _clientSign);
    }

    function getOrganizationName(address _organizationsAddress, bytes32 _organizationKey) public constant returns (bytes32) {
        return logic_v1.getOrganizationName(_organizationsAddress, _organizationKey);
    }

    function getNonceInHistories(address _historiesAddress, address _addr) public constant returns (uint) {
        return logic_v1.getNonceInHistories(_historiesAddress, _addr);
    }

    function createHistory(bytes _sign, bytes32 _objectId, bytes32 _dataHash, address _historiesAddress, uint _nonce, bytes _clientSign) public {
        return logic_v1.createHistory(_historiesAddress, _objectId, _dataHash, _nonce, _clientSign);
    }

    function removeHistory(bytes _sign, address _historiesAddress, uint _nonce, bytes _clientSign) public {
        return logic_v1.removeHistory(_historiesAddress, _nonce, _clientSign);
    }

    function addHistoryAllowGroup(bytes _sign, address _historiesAddress, bytes32 _organizationKey, uint _nonce, bytes _clientSign) public {
        return logic_v1.addHistoryAllowGroup(_historiesAddress, _organizationKey, _nonce, _clientSign);
    }

    function removeHistoryAllowGroup(bytes _sign, address _historiesAddress, bytes32 _organizationKey, uint _nonce, bytes _clientSign) public {
        return logic_v1.removeHistoryAllowGroup(_historiesAddress, _organizationKey, _nonce, _clientSign);
    }

    function addHistoryRecord(bytes _sign, bytes32 _objectId, bytes32 _dataHash, address _historiesAddress, address _patient, uint _nonce, bytes _clientSign) public {
        return logic_v1.addHistoryRecord(_historiesAddress, _patient, _objectId, _dataHash, _nonce, _clientSign);
    }

    function isHistoryAllowGroup(address _historiesAddress, bytes32 _groupId, address _patient) public constant returns (bool) {
        return logic_v1.isHistoryAllowGroup(_historiesAddress, _groupId, _patient);
    }

    function getHistoryPatientDataObjectId(address _historiesAddress, address _addr) public constant returns (bytes32) {
        return logic_v1.getHistoryPatientDataObjectId(_historiesAddress, _addr);
    }

    function getHistoryRecordDataObjectIds(address _historiesAddress, address _addr) public constant returns (bytes32[]) {
        uint length = logic_v1.getHistoryRecordLength(_historiesAddress, _addr);
        bytes32[] memory objectIds = new bytes32[](length);
        for (uint i = 0; i < length; i++) {
            objectIds[i] = logic_v1.getHistoryRecordDataObjectId(_historiesAddress, _addr, i);
        }
        return objectIds;
    }
}