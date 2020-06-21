pragma solidity ^0.4.17;

import 'zcom-contracts/contracts/ContractNameService.sol';
import 'zcom-contracts/contracts/AddressGroup.sol';

contract Organizations {

    struct Organization {
        bool created;
        bool active;
        bytes32 name;
        uint adminCount;
        bytes32 adminGroupId;
        bytes32 memberGroupId;
    }

    mapping (bytes32 => Organization) public organizations; // organizationKey => Organization
    mapping (address => bytes32) public adminOrganizationKeys; // adminAddress => OrganizationKey
    mapping (address => bytes32) public memberOrganizationKeys; // memberAddress => OrganizationKey

    // nonce for each account
    mapping(address => uint) public nonces;

    ContractNameService gmoCns;

    enum OrganizationAction {
        Create,
        Activate,
        Deactivate
    }

    enum AccountAction {
        Add,
        Remove
    }

    event OranizationEvent(bytes32 indexed _organizationKey, OrganizationAction action);
    event AdminEvent(bytes32 indexed _organizationKey, AccountAction action, address _address);
    event MemberEvent(bytes32 indexed _organizationKey, AccountAction action, address _address);

    function Organizations (ContractNameService _gmoCns) {
        gmoCns = _gmoCns;
    }

    /* ----------- modifiers ----------------- */

    modifier onlyByAdmin(address _addr) {
        require(isAdmin(_addr));
        _;
    }


    /* ----------- methods ----------------- */

    function getAddressGroupInstance() public constant returns (AddressGroup) {
        return AddressGroup(gmoCns.getLatestContract('AddressGroup'));
    }

    function isAdmin(address _addr) constant returns (bool) {
        bytes32 organizationKey = adminOrganizationKeys[_addr];
        return organizationKey != 0 && getAddressGroupInstance().isMember(_addr, organizations[organizationKey].adminGroupId);
    }

    function isMember(address _addr) constant returns (bool) {
        bytes32 organizationKey = memberOrganizationKeys[_addr];
        return organizationKey != 0 && getAddressGroupInstance().isMember(_addr, organizations[organizationKey].memberGroupId);
    }

    function isActive(bytes32 _organizationKey) constant returns (bool) {
        return organizations[_organizationKey].active;
    }

    function createOrganization(bytes32 _organizationKey, bytes32 _name) returns (bool) {
        return createOrganizationPrivate(msg.sender, _organizationKey, _name);
    }

    function createOrganizationWithSign(bytes32 _organizationKey, bytes32 _name, uint _nonce, bytes _sign) returns (bool) {
        bytes32 hash = calcEnvHash('createOrganizationWithSign');
        hash = keccak256(hash, _organizationKey);
        hash = keccak256(hash, _name);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return createOrganizationPrivate(from, _organizationKey, _name);
    }

    function createOrganizationPrivate(address _from, bytes32 _organizationKey, bytes32 _name) private returns (bool) {
        if (organizations[_organizationKey].created) return false;
        OranizationEvent(_organizationKey, OrganizationAction.Create);
        AdminEvent(_organizationKey, AccountAction.Add, _from);
        bytes32 adminGroupId = calculateUniqueGroupId(bytes32(_from));
        bytes32 memberGroupId = calculateUniqueGroupId(adminGroupId);
        address[] memory members = new address[](1);
        members[0] = _from;
        getAddressGroupInstance().createWithAllowContract(adminGroupId, _from, members, this);
        address[] memory empty;
        getAddressGroupInstance().createWithAllowContract(memberGroupId, _from, empty, this);
        organizations[_organizationKey] = Organization({created:true, active:true, name: _name, adminCount:1, adminGroupId: adminGroupId, memberGroupId: memberGroupId});
        adminOrganizationKeys[_from] = _organizationKey;
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

    /**
     * change activate by admin
     */
    function changeActivation() returns (bool) {
        return changeActivationPrivate(msg.sender);
    }

    function changeActivationWithSign(uint _nonce, bytes _sign) returns (bool) {
        bytes32 hash = calcEnvHash('changeActivationWithSign');
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return changeActivationPrivate(from);
    }

    function changeActivationPrivate(address _from) onlyByAdmin(_from) private returns (bool) {
        bytes32 organizationKey = adminOrganizationKeys[_from];
        if (organizationKey == 0) return false;
        bool changeTo = !organizations[organizationKey].active;
        OranizationEvent(organizationKey, (changeTo ? OrganizationAction.Activate : OrganizationAction.Deactivate));
        organizations[organizationKey].active = changeTo;
        return true;
    }

    /**
     * add admin by admin
     */
    function addAdmin(address _addr) returns (bool) {
        return addAdminPrivate(msg.sender, _addr);
    }

    function addAdminWithSign(address _addr, uint _nonce, bytes _sign) returns (bool) {
        bytes32 hash = calcEnvHash('addAdminWithSign');
        hash = keccak256(hash, _addr);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return addAdminPrivate(from, _addr);
    }

    function addAdminPrivate(address _from, address _addr) onlyByAdmin( _from) private returns (bool) {
        bytes32 organizationKey = adminOrganizationKeys[_from];
        if (!organizations[organizationKey].created) return false;
        if (adminOrganizationKeys[_addr] != 0 && adminOrganizationKeys[_addr] != organizationKey) return false;
        if (memberOrganizationKeys[_addr] != 0 && memberOrganizationKeys[_addr] != organizationKey) return false;

        AdminEvent(organizationKey, AccountAction.Add, _addr);
        organizations[organizationKey].adminCount++;
        getAddressGroupInstance().addMember(organizations[organizationKey].adminGroupId, _addr);
        adminOrganizationKeys[_addr] = organizationKey;
        return true;
    }

    /**
     * remove admin by admin
     */
    function removeAdmin(address _addr) returns (bool) {
        return removeAdminPrivate(msg.sender, _addr);
    }

    function removeAdminWithSign(address _addr, uint _nonce, bytes _sign) returns (bool) {
        bytes32 hash = calcEnvHash('removeAdminWithSign');
        hash = keccak256(hash, _addr);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return removeAdminPrivate(from, _addr);
    }

    function removeAdminPrivate(address _from, address _addr) onlyByAdmin(_from) private returns (bool) {
        bytes32 organizationKey = adminOrganizationKeys[_from];
        if (organizationKey == 0 || adminOrganizationKeys[_addr] == 0  || !organizations[organizationKey].created || organizations[organizationKey].adminCount == 1) return false;
        AdminEvent(organizationKey, AccountAction.Remove, _addr);
        organizations[organizationKey].adminCount--;
        getAddressGroupInstance().removeMember(organizations[organizationKey].adminGroupId, _addr);
        // Because the account do not allow to become another admin or member.
        // adminOrganizationKeys[_addr] = 0;
        return true;
    }

    /**
     * add member by member
     */
    function addMember(address _addr) returns (bool) {
        return addMemberPrivate(msg.sender, _addr);
    }

    function addMemberWithSign(address _addr, uint _nonce, bytes _sign) returns (bool) {
        bytes32 hash = calcEnvHash('addMemberWithSign');
        hash = keccak256(hash, _addr);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return addMemberPrivate(from, _addr);
    }

    function addMemberPrivate(address _from, address _addr) onlyByAdmin(_from) private returns (bool) {
        bytes32 organizationKey = adminOrganizationKeys[_from];
        if (!organizations[organizationKey].created) return false;
        if (adminOrganizationKeys[_addr] != 0 && adminOrganizationKeys[_addr] != organizationKey) return false;
        if (memberOrganizationKeys[_addr] != 0 && memberOrganizationKeys[_addr] != organizationKey) return false;

        MemberEvent(organizationKey, AccountAction.Add, _addr);
        getAddressGroupInstance().addMember(organizations[organizationKey].memberGroupId, _addr);
        memberOrganizationKeys[_addr] = organizationKey;
        return true;
    }

    /**
     * remove member by admin
     */
    function removeMember(address _addr) returns (bool) {
        return removeMemberPrivate(msg.sender, _addr);
    }

    function removeMemberWithSign(address _addr, uint _nonce, bytes _sign) returns (bool) {
        bytes32 hash = calcEnvHash('removeMemberWithSign');
        hash = keccak256(hash, _addr);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce != nonces[from]) return false;
        nonces[from]++;

        return removeMemberPrivate(from, _addr);
    }

    function removeMemberPrivate(address _from, address _addr) onlyByAdmin(_from) private returns (bool) {
        bytes32 organizationKey = adminOrganizationKeys[_from];
        if (organizationKey == 0 || memberOrganizationKeys[_addr] == 0 || !organizations[organizationKey].created) return false;
        MemberEvent(organizationKey, AccountAction.Remove, _addr);
        getAddressGroupInstance().removeMember(organizations[organizationKey].memberGroupId, _addr);
        // Because the account do not allow to become another admin or member.
        //memberOrganizationKeys[_addr] = 0;
        return true;
    }

    function getMemberGroupId(bytes32 _organizationKey) public constant returns (bytes32) {
        return organizations[_organizationKey].memberGroupId;
    }

    function getName(bytes32 _organizationKey) public constant returns (bytes32) {
        return organizations[_organizationKey].name;
    }

    /* ----------- recover address ----------------- */

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