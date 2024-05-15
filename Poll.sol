// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Escrow.sol";

contract Poll {
    struct PollData {
        string title;
        string description;
        string[] options;
        uint256 deadline;
        Escrow escrow;
    }

    PollData public pollData;
    mapping(address => bool) public hasVoted;
    event VoteCast(address indexed voter, uint256 indexed optionIndex, uint256 amount);

    modifier onlyBeforeDeadline() {
        require(block.timestamp < pollData.deadline, "Voting has ended");
        _;
    }

    modifier onlyValidOption(uint256 optionIndex) {
        require(optionIndex < pollData.options.length, "Invalid option index");
        _;
    }

    constructor(
        string memory _title,
        string memory _description,
        string[] memory _options,
        uint256 _deadline,
        Escrow _escrow
    ) {
        pollData.title = _title;
        pollData.description = _description;
        pollData.options = _options;
        pollData.deadline = _deadline;
        pollData.escrow = _escrow;
        pollData.escrow.setOptions(_options.length); // Assuming Escrow is modified to accept option count
    }

    function vote(uint256 optionIndex) external payable onlyBeforeDeadline onlyValidOption(optionIndex) {
        require(msg.value > 0, "Must send ETH to vote");
        require(!hasVoted[msg.sender], "Already voted");
        hasVoted[msg.sender] = true;

        pollData.escrow.addVote{value: msg.value}(optionIndex, msg.value);
        emit VoteCast(msg.sender, optionIndex, msg.value);
    }

    function getVotes() external view returns (Escrow.Option[] memory) {
        return pollData.escrow.voteCounts();
    }

    function getWinningOption() public view returns (uint256) {
        require(block.timestamp >= pollData.deadline, "Voting is still ongoing");

        Escrow.Option[] memory votes = pollData.escrow.voteCounts();
        uint256 winningOptionIndex = 0;
        uint256 maxContributions = 0;

        for (uint256 i = 0; i < votes.length; i++) {
            if (votes[i].totalContributions > maxContributions) {
                maxContributions = votes[i].totalContributions;
                winningOptionIndex = i;
            }
        }

        return winningOptionIndex;
    }

    // Adjust other functions as necessary to interact with the new `Escrow` structure
}
