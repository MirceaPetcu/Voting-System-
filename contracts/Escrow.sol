// SPDX-License-Identifier: MIT
import "./MultiBeneficiary.sol";
pragma solidity ^0.8.19;

contract Escrow {
    MultiBeneficiary beneficiaries;

    struct Option {
        uint256 voteCount;
        uint256 totalContributions;
    }

    Option[] public options;

    event FundsReleased(MultiBeneficiary beneficiaries, uint256 amount);
    event FundsReceived(address sender, uint256 amount);

    modifier validOptionIndex(uint256 option) {
        require(option < options.length, "Invalid option index");
        _;
    }

    constructor(MultiBeneficiary  _beneficiary) {
        beneficiaries = _beneficiary;
    }

    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    function incrementVote(uint256 voteCount) private pure returns (uint256) {
        uint256 newCount = voteCount + 1;  
        return newCount;
    }

    function addAmount(uint256 totalContributions, uint256 amount) private pure returns (uint256) {
        uint256 newContribution = totalContributions + amount;  
        return newContribution;
    }

    function addVote(uint256 option, uint256 amount) external payable validOptionIndex(option){
        uint256 newCount = incrementVote(options[option].voteCount);
        options[option].voteCount = newCount ;
        uint256 newContribution = addAmount(options[option].totalContributions, amount);
        options[option].totalContributions += newContribution;
    }

    function returnAllFunds(address[] memory voters) external {
        address payable [] memory b = getBeneficiaries();
        for (uint256 i = 0; i < b.length; i++) {
            require(address(msg.sender) == b[i], "You must be one of the beneficiaries!");
        }

        for (uint i = 0; i < voters.length; i++) { 
            (bool success, ) = voters[i].call{value: address(this).balance}("");
            require(success, "Failed to send Ether"); 
        }
    }

    function setOptions (uint256 _totalVotes) public  {
         for (uint i = 0; i < _totalVotes; i++) {
             options.push(Option({ voteCount: 0, totalContributions: 0 }));
         } 
    }

    function releaseFunds() public {
        uint256 amount = address(this).balance;

        (bool success, ) = address(beneficiaries).call{value: amount}("");
        require(success, "Failed to send Ether");

        beneficiaries.distributeFunds(amount);
        emit FundsReleased(beneficiaries, amount);
    }
    
    function voteCounts() public view returns (Option[] memory) {
        return options;
    }

    function getBeneficiaries() public view returns(address payable [] memory){
        return beneficiaries.getBeneficiaries();
    }
}