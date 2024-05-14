// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollTimeManagement {
    struct PollDuration {
        uint startTime;
        uint endTime;
    }

    event PollDurationEvent(address sender);

    mapping(uint => PollDuration) public pollDurations;
    address public admin;

    constructor() {
        admin = msg.sender;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can set durations");
        _;
    }

    function setPollDuration(uint pollId, uint start, uint end) public  {
        emit PollDurationEvent(msg.sender);
        require(start < end, "Start time must be before end time.");
        pollDurations[pollId] = PollDuration(start, end);
    }

    function isPollActive(uint pollId) public view returns (bool) {
        return block.timestamp >= pollDurations[pollId].startTime && block.timestamp <= pollDurations[pollId].endTime;
    }
}
