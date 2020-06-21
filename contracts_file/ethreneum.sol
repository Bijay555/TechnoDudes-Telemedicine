pragma solidity ^0.4.24;
contract Insurance{
    address Owner;
    struct citizens{
        string name;
        bool isGenerated;
        uint amountInsured;
    }
    mapping(address => citizens) citizensmapping;
    mapping(address =>bool)doctorsamappping;
    constructor(){
        Owner = msg.sender;
    }
    modifier OnlyOwner(){
      require(Owner==msg.sender);
        _;
    }
    function setDoctor(address _address) OnlyOwner{
        require(!doctorsamappping[_address]);
            doctorsamappping[_address]=true;
    }
     function setCitizen(string naam,uint _amount)   OnlyOwner returns(address){
        address Uniqueid = address(sha256(msg.sender,now));
        require(!citizensmapping[Uniqueid].isGenerated);
        citizensmapping[Uniqueid].isGenerated = true;
        citizensmapping[Uniqueid].amountInsured  = _amount;
        citizensmapping[Uniqueid].name = naam;
        return (Uniqueid);
    }
    function useInsurance(address Uniqueid,uint _amount) returns(string){
        require(doctorsamappping[msg.sender]);
        if(citizensmapping[Uniqueid].amountInsured <_amount){
        revert();
        }
        citizensmapping[Uniqueid].amountInsured-=_amount;
        return ("Insurance was successfully completed");
    }
}
