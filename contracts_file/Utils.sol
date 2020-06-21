pragma solidity ^0.4.17;

contract Utils {
    function transferUniqueId(bytes32 _id) internal constant returns (bytes32) {
        return keccak256(keccak256(this), _id);
    }

    function recoverAddress(bytes32 _hash, bytes _sign) internal pure returns (address) {
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

        address recAddr = ecrecover(_hash, v, r, s);
        require(recAddr != 0);
        return recAddr;
    }
}