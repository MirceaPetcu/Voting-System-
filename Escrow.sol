// SPDX-License-Identifier: MIT
import "./MultiBeneficiary.sol";
pragma solidity ^0.8.0;

contract Escrow {
    MultiBeneficiary beneficiaries;

    struct Option {
        uint256 voteCount;
        uint256 totalContributions;
    }

    Option[] public options;

    event FundsReleased(MultiBeneficiary beneficiaries, uint256 amount);

    constructor(MultiBeneficiary  _beneficiary) {
        beneficiaries = _beneficiary;
        
    }

    function setOptions (uint256 _totalVotes) public  {
         for (uint i = 0; i < _totalVotes; i++) {
             options.push(Option({ voteCount: 0, totalContributions: 0 }));
         } 
     }

    function addVote(uint256 option, uint256 amount) external payable {
        require(option < options.length, "Invalid option index");
        options[option].voteCount++;
        options[option].totalContributions += amount;
    }

    function voteCounts() public view returns (Option[] memory) {
        return options;
    }

    // External function
    function releaseFunds() public {
        uint256 amount = address(this).balance;

        // Use call to send all contract's balance to the MultiBeneficiary contract
        (bool success, ) = address(beneficiaries).call{value: amount}("");
        require(success, "Failed to send Ether");

        beneficiaries.distributeFunds(amount);
        emit FundsReleased(beneficiaries, amount);
    }

    receive() external payable {
        // Optional: Emit an event when Ether is received
        emit FundsReceived(msg.sender, msg.value);
    }

    // Event to log received funds
    event FundsReceived(address sender, uint256 amount);
}