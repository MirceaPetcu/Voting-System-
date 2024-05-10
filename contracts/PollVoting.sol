// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PollTimeManagement.sol";
import "./VotingSecurity.sol";

contract PollVoting {
    struct Poll {
        uint id;
        string question;
        string[] options;
        mapping(uint => uint) votes;
        bool active;
    }
    
    Poll[] public polls;
    address payable public admin;
    PollTimeManagement timeManagement;
    VotingSecurity private securityContract; 

    event PollCreated(uint pollId, string question);
    event PollVoted(uint pollId, uint optionId, address voter);

    constructor(address _timeManagement, address _securityContract) {
        admin = payable (msg.sender);
        timeManagement = PollTimeManagement(_timeManagement);
        securityContract = VotingSecurity(_securityContract);
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can create polls");
        _;
    }

    function createPoll(string memory question, string[] memory options) external onlyAdmin {
        require(msg.sender == admin, "Only admin can create polls.");
        Poll storage newPoll = polls.push();
        newPoll.id = polls.length - 1;
        newPoll.question = question;
        newPoll.options = options;
        newPoll.active = true;
        emit PollCreated(newPoll.id, question);
    }

    function vote(uint pollId, uint optionId) public {
        require(polls[pollId].active, "This poll is not active.");
        require(timeManagement.isPollActive(pollId), "Poll is not currently active.");
        require(optionId < polls[pollId].options.length, "Invalid option.");
        require(!securityContract.checkVoter(pollId, msg.sender), "You have already voted in this poll.");

        securityContract.recordVote(pollId, msg.sender);

        polls[pollId].votes[optionId]++;
    }

    function getResults(uint pollId) public view returns (uint[] memory) {
        uint[] memory results = new uint[](polls[pollId].options.length);
        for (uint i = 0; i < polls[pollId].options.length; i++) {
            results[i] = polls[pollId].votes[i];
        }
        return results;
    }
}
