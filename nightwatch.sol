pragma solidity >=0.8.0 <0.9.0;

contract The_Nightwatch {
    mapping (address => bytes) public signatures;

    function updateSignature (bytes memory signature) public {
        address sender = msg.sender;
        signatures[sender] = signature;
    }
}