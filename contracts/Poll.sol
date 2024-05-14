// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Reputation.sol";
import "./MultiBeneficiary.sol";
import "./Escrow.sol";

contract Poll {
    struct PollData {
        string title;
        string description;
        string[] options;
        uint256 deadline;
        MultiBeneficiary beneficiaries;
        Escrow escrow;
    }

    PollData public pollData;

    address public reputationContract;

    mapping(address => bool) public hasVoted;

    event VoteCast(address indexed voter, uint256 indexed optionIndex);

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
        MultiBeneficiary _beneficiaries,
        Escrow _escrow,
        address _reputationContract
    ) {
        pollData.title = _title;
        pollData.description = _description;
        pollData.options = _options;
        pollData.deadline = _deadline;
        pollData.beneficiaries = _beneficiaries;
        pollData.escrow = _escrow;
        reputationContract = _reputationContract;
    }

    // External function
    function contribute() external payable {
        require(msg.value > 0, "Contribution amount must be greater than zero");
    }

    // External function
    function vote(uint256 optionIndex) external onlyBeforeDeadline onlyValidOption(optionIndex) {
        require(block.timestamp < pollData.deadline, "Voting has ended");
        require(optionIndex < pollData.options.length, "Invalid option index");

        Reputation(reputationContract).vote(address(this), true);

        // Update vote count for the selected option
        uint256[] memory voteCounts = pollData.escrow.voteCounts();
        voteCounts[optionIndex]++;

        emit VoteCast(msg.sender, optionIndex);
    }
    

    

    // View function
    function getVotes() external view returns (uint256[] memory) {
        return pollData.escrow.voteCounts();
    }

    // Pure function
    function calculateWinningOption(uint256[] memory _voteCounts) public pure returns (uint256) {
        uint256 winningOptionIndex = 0;
        uint256 maxVoteCount = 0;

        for (uint256 i = 0; i < _voteCounts.length; i++) {
            if (_voteCounts[i] > maxVoteCount) {
                maxVoteCount = _voteCounts[i];
                winningOptionIndex = i;
            }
        }

        return winningOptionIndex;
    }

    // View function
    function getWinningOption() public view returns (uint256) {
        require(block.timestamp >= pollData.deadline, "Voting is still ongoing");

        uint256[] memory voteCounts = pollData.escrow.voteCounts();
        return calculateWinningOption(voteCounts);
    }

    // External function
    function distributeFunds() external {
        require(block.timestamp >= pollData.deadline, "Voting is still ongoing");

        uint256 winningOptionIndex = getWinningOption();
        uint256 totalVotes = 0;
        uint256[] memory voteCounts = pollData.escrow.voteCounts();

        for (uint256 i = 0; i < pollData.options.length; i++) {
            totalVotes += voteCounts[i];
        }

        uint256 totalAmount = address(this).balance;

        for (uint256 i = 0; i < pollData.beneficiaries.getBeneficiaries().length; i++) {
            address beneficiary = pollData.beneficiaries.getBeneficiaries()[i];
            uint256 beneficiaryWeight = pollData;

            uint256 amount = (totalAmount * beneficiary.weight) / totalVotes;
            payable(beneficiary).transfer(amount);
        }

        pollData.escrow.releaseFunds();
    }
}
