pragma solidity ^0.4.17;

import "./CnsController.sol";

contract VersionField is CnsController {
    VersionField public prevVersion;
    VersionField public nextVersion;

    modifier onlyByNextVersionOrVersionLogic() {
        require(isVersionLogic() || msg.sender == address(nextVersion));
        _;
    }

    function VersionField(ContractNameService _cns, bytes32 _contractName) CnsController(_cns, _contractName) public {}

    function setPrevVersion(VersionField _prevVersion) public onlyByProvider {
        prevVersion = _prevVersion;
    }

    function setNextVersion(VersionField _nextVersions) public onlyByProvider {
        nextVersion = _nextVersions;
    }

    function exist(bytes32 _id) public constant returns (bool) {
        return existIdBeforeVersion(_id) || existIdAtCurrentVersion(_id) || existIdAfterVersion(_id);
    }

    function existIdAfterVersion(bytes32 _id) public constant returns (bool) {
        if (address(nextVersion) == 0) return false;
        if (nextVersion.existIdAtCurrentVersion(_id)) return true;
        return nextVersion.existIdAfterVersion(_id);
    }

    function existIdBeforeVersion(bytes32 _id) public constant returns (bool) {
        if (address(prevVersion) == 0) return false;
        if (prevVersion.existIdAtCurrentVersion(_id)) return true;
        return prevVersion.existIdBeforeVersion(_id);
    }

    function prepare(bytes32 _id) internal {
        require(exist(_id));
        if (!existIdAtCurrentVersion(_id)) setDefault(_id);
    }

    function shouldReturnDefault(bytes32 _id) internal constant returns (bool) {
        return exist(_id) && !existIdAtCurrentVersion(_id);
    }

    function setDefault(bytes32 _id) private;
    function existIdAtCurrentVersion(bytes32 _id) public constant returns (bool);
}