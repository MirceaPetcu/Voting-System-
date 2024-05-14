// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Reputation {
    struct VoterReputation {
        uint256 positiveVotes;
        uint256 negativeVotes;
    }

    mapping(address => VoterReputation) public voterReputation;

    event VoteRecorded(address voter, bool isPositive);

    // External function
    function vote(address pollAddress, bool isPositive) public {
        VoterReputation storage reputation = voterReputation[msg.sender];

        if (isPositive) {
            reputation.positiveVotes++;
        } else {
            reputation.negativeVotes++;
        }

        emit VoteRecorded(msg.sender, isPositive);
    }

    // View function
    function getReputation(address voter) public view returns (uint256, uint256) {
        VoterReputation storage reputation = voterReputation[voter];
        return (reputation.positiveVotes, reputation.negativeVotes);
    }
}