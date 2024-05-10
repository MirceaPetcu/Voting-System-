// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PollTimeManagement {
    struct PollDuration {
        uint startTime;
        uint endTime;
    }

    mapping(uint => PollDuration) public pollDurations;
    address public admin;

    constructor() {
        admin = msg.sender;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can set durations");
        _;
    }

    function setPollDuration(uint pollId, uint start, uint end) public onlyAdmin {
        require(start < end, "Start time must be before end time.");
        pollDurations[pollId] = PollDuration(start, end);
    }

    function isPollActive(uint pollId) public view returns (bool) {
        return block.timestamp >= pollDurations[pollId].startTime && block.timestamp <= pollDurations[pollId].endTime;
    }
}
