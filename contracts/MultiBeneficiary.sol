// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Escrow.sol";
import "./Poll.sol";
contract MultiBeneficiary {
    struct PollProposition {
        string title;
        string description;
        string[] options;
        uint256 deadline;
    }
    address payable[] public beneficiaries;
    PollProposition[] public pollProposions;
    Poll[] public polls;
    event FundsDistributed(address payable[] beneficiaries, uint256 amount);
    event BeneficiaryAdded(address beneficiary);
    event PollCreated(address indexed pollAddress);
    event EscrowCreated(address indexed escrowAddress);
    event FundsReceived(address sender, uint256 amount);

    
   
    constructor() {
        beneficiaries.push(payable(msg.sender));
    }
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
    function calculateAmount(uint256 totalAmount, uint256 length) private  pure returns (uint256) {
        uint256 amount = totalAmount / length;
        return amount;
    }
    function distributeFundsLogic(uint256 amount) internal {
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            beneficiaries[i].transfer(amount);
        }
    }
    function proposePoll(string memory _title, string memory _description, string[] memory _options, uint256 _deadline) external {
        PollProposition memory poll = PollProposition({
            title: _title,
            description: _description,
            options: _options,
            deadline: _deadline
        });
        pollProposions.push(poll);
    }
    function acceptPoll(uint256 pollId) external {

        Escrow escrow = new Escrow(this);
        PollProposition storage proposition = pollProposions[pollId];
        Poll newPoll = new Poll(proposition.title, proposition.description, proposition.options, proposition.deadline, escrow);
        polls.push(newPoll);

        emit PollCreated(address(newPoll));  
        emit EscrowCreated(address(escrow));
    }
    function denyPoll(uint256 pollId) external {

        for (uint i = pollId; i < pollProposions.length - 1; i++) {
            pollProposions[i] = pollProposions[i + 1];
        }
        pollProposions.pop();
    }
    function createPoll(string memory _title, string memory _description, string[] memory _options, uint256 _deadline) external returns (Poll){
        Escrow escrow = new Escrow(this);
        Poll newPoll = new Poll(_title, _description, _options, _deadline, escrow);
        polls.push(newPoll);
        
        emit PollCreated(address(newPoll));  
        emit EscrowCreated(address(escrow));

        return newPoll;
    }
    function getPolls() external view returns (Poll[] memory) {
        return polls;
    }
    function addBeneficiary(address _beneficiary) public {
        require(_beneficiary != address(0), "Cannot add zero address as beneficiary");

        address payable newBeneficiary = payable(_beneficiary);
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            require(beneficiaries[i] != newBeneficiary, "Address already a beneficiary");
        }
        beneficiaries.push(newBeneficiary);
        emit BeneficiaryAdded(newBeneficiary);
    }
    function distributeFunds(uint256 totalAmount) public {
        uint256 amount = calculateAmount(totalAmount, beneficiaries.length);

        distributeFundsLogic(amount);

        emit FundsDistributed(beneficiaries, amount);
    }
    function getBeneficiaries() public view returns (address payable [] memory) {
        return beneficiaries;
    }

}