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

    mapping (bytes => Track) tracks;
    mapping (address => uint) nonces;
    mapping (bytes => uint) started;

    event trackRregistered(bytes trackid, string name, uint nbsteps);
    event challengeStep(bytes trackid, address gamer, uint index);
    event challengeAccomplished(bytes trackid, address gamer);


    function registerTrack (string calldata _name, string calldata _description, bytes32[] calldata _hashes, string[] memory _descriptions) public {
        require(_hashes.length == _descriptions.length, "hashes and descriptions must have the same length.");

        bytes memory trackId = abi.encode(msg.sender, nonces[msg.sender]);
        nonces[msg.sender]++;
        tracks[trackId].description = _description;
        tracks[trackId].name = _name;
        tracks[trackId].hashes = _hashes;
        tracks[trackId].descriptions = _descriptions;

        emit trackRregistered(trackId, _name, _hashes.length);
    }

    function checkHash (bytes calldata _input, bytes calldata _trackId, uint _stepIndex) public view returns (bool) {
        bytes32 hash = keccak256(_input);
        return hash == tracks[_trackId].hashes[_stepIndex];
    }

    function finished (bytes calldata _trackId,  bytes memory _startId) public view returns (bool) {
        return tracks[_trackId].hashes.length - 1 == started[_startId];
    }

    function moveOn (bytes calldata _trackId, bytes calldata _input) public {
        require(tracks[_trackId].hashes.length != 0, "no track found or no step declared.");
        require(!tracks[_trackId].locked, "challenge already accomplished");

        bytes memory startId = abi.encode(msg.sender, _trackId);
        uint index = started[startId];
        if (index == 0 || checkHash(_input, _trackId, index)) {
            started[startId]++;     
            emit challengeStep(_trackId, msg.sender, started[startId]);
        }
        if (finished(_trackId, startId)) {
            tracks[_trackId].locked = true;
            emit challengeAccomplished(_trackId, msg.sender);
        }
    }

    function finish (bytes calldata _trackId) public {
        bytes memory startId = abi.encode(msg.sender, _trackId);
        if (finished(_trackId, startId) && !tracks[_trackId].rewarded) {
            tracks[_trackId].rewarded = true;
            (bool success, ) = tracks[_trackId].prizeLocation.call(tracks[_trackId].prizeCall);   
        }
    }
}