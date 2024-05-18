// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
    address[] public voters;

    event VoteCast(address indexed voter, uint256 indexed optionIndex, uint256 amount);

    modifier onlyBeforeDeadline() {
        require(block.timestamp < pollData.deadline, "Voting has ended");
        _;
    }

    modifier onlyAfterDeadline() {
        require(block.timestamp >= pollData.deadline, "Voting is still ongoing");
        _;
    }
    modifier onlyValidOption(uint256 optionIndex) {
        require(optionIndex < pollData.options.length, "Invalid option index");
        _;
    }

    modifier minETH() {
        require(msg.value > 0, "Must send ETH to vote");
        _;
    }

    modifier onlyOneVote() {
        require(!hasVoted[msg.sender], "Already voted");
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
        pollData.escrow.setOptions(_options.length); 
    }

    function returnMoney() external {
        address payable [] memory beneficiaries = pollData.escrow.getBeneficiaries();
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            require(address(msg.sender) == beneficiaries[i], "You must be one of the beneficiaries!");
        }
        
        pollData.escrow.returnAllFunds(voters);
    }

    function contribute() external payable onlyBeforeDeadline minETH {
        address payable [] memory beneficiaries = pollData.escrow.getBeneficiaries();
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            require(address(msg.sender) != beneficiaries[i], "Beneficiaries cannot contribute!");
        }

        uint256 amount = msg.value;
        (bool success, ) = address(pollData.escrow).call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function vote(uint256 optionIndex) external payable onlyBeforeDeadline onlyValidOption(optionIndex) minETH onlyOneVote {
        address payable [] memory beneficiaries = pollData.escrow.getBeneficiaries();
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            require(address(msg.sender) != beneficiaries[i], "Beneficiaries cannot vote!");
        }

        hasVoted[msg.sender] = true;
        voters.push(msg.sender);
        pollData.escrow.addVote{value: msg.value}(optionIndex, msg.value);
        emit VoteCast(msg.sender, optionIndex, msg.value);
    }
    
    function getAllVoters() public view  returns (address[] memory) {
        address payable [] memory beneficiaries = pollData.escrow.getBeneficiaries();
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            require(address(msg.sender) == beneficiaries[i], "You must be one of the beneficiaries!");
        }
        
        return voters;
    }
    
    function getVotes() public view returns (Escrow.Option[] memory) {
        address payable [] memory beneficiaries = pollData.escrow.getBeneficiaries();
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            require(address(msg.sender) == beneficiaries[i], "You must be one of the beneficiaries!");
        }
        
        return pollData.escrow.voteCounts();
    }

    function getWinningOption() public view onlyAfterDeadline returns (uint256) {
        address payable [] memory beneficiaries = pollData.escrow.getBeneficiaries();
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            require(address(msg.sender) == beneficiaries[i], "You must be one of the beneficiaries!");
        }
        
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

    
}
