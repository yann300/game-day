// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

contract GameDay {

    struct Track {
        string name;
        string description;
        bytes32[] hashes;
        string[] descriptions;
        address prizeLocation;
        bytes prizeCall;
        bool locked;
        bool rewarded;
    }

    bytes[] public trackIds;
    mapping (bytes => Track) public tracks;
    mapping (address => uint) public nonces;
    mapping (bytes => uint) public started;

    event trackRegistered(bytes trackid, string name, uint nbsteps);
    event challengeStep(bytes trackid, address gamer, uint index);
    event challengeAccomplished(bytes trackid, address gamer);
    
    function registerTrack (
            string calldata _name,
            string calldata _description,
            bytes32[] calldata _hashes,
            string[] memory _descriptions,
            address prizeLocation,
            bytes calldata prizeCall
        ) public {
        require(_hashes.length == _descriptions.length, "hashes and descriptions must have the same length.");

        bytes memory trackId = abi.encodePacked(msg.sender, nonces[msg.sender]);
        nonces[msg.sender]++;
        tracks[trackId].description = _description;
        tracks[trackId].name = _name;
        tracks[trackId].hashes = _hashes;
        tracks[trackId].prizeLocation = prizeLocation;
        tracks[trackId].prizeCall = prizeCall;
        trackIds.push(trackId);

        emit trackRegistered(trackId, _name, _hashes.length);
    }

    function keccak256Of(bytes[] calldata _inputs) public pure returns (bytes32[] memory bytesReturns) {
        bytesReturns = new bytes32[](_inputs.length);
        for (uint k = 0; k < _inputs.length; k++) {
            bytesReturns[k] = keccak256(abi.encodePacked( _inputs[k]));
        }
    }

    function checkHash (bytes calldata _input, bytes calldata _trackId, uint _stepIndex) public view returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(_input));
        return hash == tracks[_trackId].hashes[_stepIndex];
    }

    function finished (bytes calldata _trackId,  bytes memory _startId) public view returns (bool) {
        return tracks[_trackId].hashes.length == started[_startId];
    }

    function moveOn (bytes calldata _trackId, bytes calldata _input) public {
        require(tracks[_trackId].hashes.length != 0, "no track found or no step declared.");
        require(!tracks[_trackId].locked, "challenge already accomplished");

        bytes memory startId = abi.encodePacked(msg.sender, _trackId);
        uint index = started[startId];
        
        if (checkHash(_input, _trackId, index)) {
            started[startId]++;     
            emit challengeStep(_trackId, msg.sender, started[startId]);
        } else revert("this is not the input we are waiting for");

        if (finished(_trackId, startId)) {
            // tracks[_trackId].locked = true;
            emit challengeAccomplished(_trackId, msg.sender);
        }
    }

    function finish (bytes calldata _trackId) public {
        bytes memory startId = abi.encodePacked(msg.sender, _trackId);
        if (finished(_trackId, startId)) {
            (bool success, ) = tracks[_trackId].prizeLocation.call(tracks[_trackId].prizeCall);
        }
    }

    function lockTrack (uint _nonce) public {
        bytes memory trackId = abi.encodePacked(msg.sender, _nonce);
        tracks[trackId].locked = true;
    }

    function position (address gamer, bytes calldata _trackId) public view returns (uint index) {
        bytes memory startId = abi.encodePacked(gamer, _trackId);
        index = started[startId];
    }
}