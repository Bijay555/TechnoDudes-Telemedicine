pragma solidity ^0.4.14;

import 'zcom-contracts/contracts/VersionLogic.sol';
import './Organizations.sol';
import './Histories.sol';

contract ProxyControllerLogic_v1 is VersionLogic {
    function ProxyControllerLogic_v1(ContractNameService _cns) VersionLogic (_cns, 'ProxyController') {}

    function getNonceInOrganizations(address _organizationsAddress, address _addr) constant returns (uint) {
        return Organizations(_organizationsAddress).nonces(_addr);
    }

    function createOrganization(address _organizationsAddress, bytes32 _organizationKey, bytes32 _name, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Organizations(_organizationsAddress).createOrganizationWithSign(_organizationKey, _name, _nonce, _clientSign));
    }

    function changeOrganizationActivation(address _organizationsAddress, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Organizations(_organizationsAddress).changeActivationWithSign(_nonce, _clientSign));
    }

    function addOrganizationAdmin(address _organizationsAddress, address _addr, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Organizations(_organizationsAddress).addAdminWithSign(_addr, _nonce, _clientSign));
    }

    function removeOrganizationAdmin(address _organizationsAddress,  address _addr, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Organizations(_organizationsAddress).removeAdminWithSign(_addr, _nonce, _clientSign));
    }

    function addOrganizationMember(address _organizationsAddress, address _addr, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Organizations(_organizationsAddress).addMemberWithSign(_addr, _nonce, _clientSign));
    }

    function removeOrganizationMember(address _organizationsAddress, address _addr, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Organizations(_organizationsAddress).removeMemberWithSign(_addr, _nonce, _clientSign));
    }

    function getOrganizationName(address _organizationsAddress, bytes32 _organizationKey) public constant returns (bytes32) {
        return Organizations(_organizationsAddress).getName(_organizationKey);
    }

    function getNonceInHistories(address _historiesAddress, address _addr) public constant returns (uint) {
        return Histories(_historiesAddress).nonces(_addr);
    }

    function createHistory(address _historiesAddress, bytes32 _objectId, bytes32 _dataHash, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Histories(_historiesAddress).createHistoryWithSign(_objectId, _dataHash, _nonce, _clientSign));
    }

    function removeHistory(address _historiesAddress, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Histories(_historiesAddress).removeWithSign(_nonce, _clientSign));
    }

    function addHistoryAllowGroup(address _historiesAddress, bytes32 _organizationKey, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Histories(_historiesAddress).addAllowGroupWithSign(_organizationKey, _nonce, _clientSign));
    }

    function removeHistoryAllowGroup(address _historiesAddress, bytes32 _organizationKey, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Histories(_historiesAddress).removeAllowGroupWithSign(_organizationKey, _nonce, _clientSign));
    }

    function addHistoryRecord(address _historiesAddress, address _patient, bytes32 _objectId, bytes32 _dataHash, uint _nonce, bytes _clientSign) public onlyByVersionContractOrLogic {
        require(Histories(_historiesAddress).addRecordWithSign( _patient, _objectId, _dataHash, _nonce, _clientSign));
    }

    function isHistoryAllowGroup(address _historiesAddress, bytes32 _groupId, address _patient) public constant returns (bool) {
        return Histories(_historiesAddress).isAllowGroup(_groupId, _patient);
    }

    function getHistoryPatientDataObjectId(address _historiesAddress, address _addr) public constant returns (bytes32) {
        return Histories(_historiesAddress).getPatientDataObjectId(_addr);
    }

    function getHistoryRecordLength(address _historiesAddress, address _addr) public constant returns (uint) {
        return Histories(_historiesAddress).getRecordLength(_addr);
    }

    function getHistoryRecordDataObjectId(address _historiesAddress, address _addr, uint _index) public constant returns (bytes32) {
        return Histories(_historiesAddress).getRecordObjectId(_addr, _index);
    }
}