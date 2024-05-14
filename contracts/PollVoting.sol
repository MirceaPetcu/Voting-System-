// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PollTimeManagement.sol";
import "./VotingSecurity.sol";

contract PollVoting {
    struct Poll {
        uint id;
        string question;
        string[] options;
        mapping(uint => uint) totalContributions;
        bool active;
    }

    
    Poll[] public polls;
    address payable public admin;
    PollTimeManagement timeManagement;
    VotingSecurity private securityContract; 

    event PollCreated(uint pollId, string question, address sender);
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


    function createPoll(string memory question, string[] memory options, uint durationDays) external {

        Poll storage newPoll = polls.push(); // Create a new Poll struct and add it to the array
        uint pollId = polls.length - 1;
        emit PollCreated(pollId, question, msg.sender);

        newPoll.id = pollId;
        newPoll.question = question;
        newPoll.options = options;
        newPoll.active = true;
        
        // Set the duration of the poll in days
        uint endTime = block.timestamp + (durationDays * 1 days);
        timeManagement.setPollDuration(pollId, block.timestamp, endTime);

        emit PollCreated(pollId, question, msg.sender);
    }

    function vote(uint pollId, uint optionId) public payable {
        require(polls[pollId].active, "This poll is not active.");
        require(timeManagement.isPollActive(pollId), "Poll is not currently active.");
        require(optionId < polls[pollId].options.length, "Invalid option.");
        require(!securityContract.checkVoter(pollId, msg.sender), "You have already voted in this poll.");
        require(msg.value > 0, "You must send ETH to vote.");

        securityContract.recordVote(pollId, msg.sender);
        polls[pollId].totalContributions[optionId] += msg.value;
    }


    function getWinner(uint pollId) public view returns (uint winningOptionId) {
        uint highestAmount = 0;
        for (uint i = 0; i < polls[pollId].options.length; i++) {
            if (polls[pollId].totalContributions[i] > highestAmount) {
                highestAmount = polls[pollId].totalContributions[i];
                winningOptionId = i;
            }
        }
        return winningOptionId;
    }

}
