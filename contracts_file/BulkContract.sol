pragma solidity ^0.4.17;

import "./DataObject.sol";

contract BulkContract {
    DataObject public dataObject;

    function BulkContract(DataObject _dataObject) public {
        dataObject = _dataObject;
    }

    function getHashInDataObject(bytes32[] _ids) public constant returns (bytes32[]) {
        bytes32[] memory hashes = new bytes32[](_ids.length);

        for (uint i; i<_ids.length; i++) {
            hashes[i] = dataObject.getHash(_ids[i]);
        }
        return hashes;
    }

    function canReadInDataObject(address _account, bytes32[] _ids) public constant returns (bool[]) {
        bool[] memory canReads = new bool[](_ids.length);
        for (uint i; i<_ids.length; i++) {
            canReads[i] = dataObject.canRead(_account, _ids[i]);
        }
        return canReads;
    }

    function getExists(bytes32[] _ids) public constant returns (bool[]) {
        bool[] memory exists = new bool[](_ids.length);
        for (uint i; i<_ids.length; i++) {
            exists[i] = dataObject.exist(_ids[i]);
        }
        return exists;
    }

    function getWriteTimestamps(bytes32[] _ids) public constant returns (uint[]) {
        uint[] memory writeTimestamps = new uint[](_ids.length);
        for (uint i; i<_ids.length; i++) {
            writeTimestamps[i] = dataObject.getWriteTimestamp(_ids[i]);
        }
        return writeTimestamps;
    }
}