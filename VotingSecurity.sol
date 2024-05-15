// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSecurity {
    // Admin address
    address public admin;

    // Mapping to keep track of voters' statuses in different polls
    // pollId => (voter address => hasVoted)
    mapping(uint => mapping(address => bool)) public hasVoted;
    event VoteRecorded(uint indexed pollId, address indexed voter);

    constructor() {
        admin = msg.sender; // The deployer is typically the admin.
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Function to check if the voter has already voted in a specific poll
    function checkVoter(uint pollId, address voter) public view returns (bool) {
        return hasVoted[pollId][voter];
    }

    // Function to record a voter's action of voting
    function recordVote(uint pollId, address voter) public  {
        require(!hasVoted[pollId][voter], "Voter has already voted in this poll");
        hasVoted[pollId][voter] = true;
        emit VoteRecorded(pollId, voter);
    }

    // Admin can reset the voting status in case of a new voting round or errors
    function resetVoter(uint pollId, address voter) public onlyAdmin {
        hasVoted[pollId][voter] = false;
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        admin = newAdmin;
    }
    
}
