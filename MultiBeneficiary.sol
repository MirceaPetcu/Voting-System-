// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiBeneficiary {

    address payable[] public beneficiaries;

    event FundsDistributed(address payable[] beneficiaries, uint256 amount);

    constructor(address[] memory _beneficiaries) {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            // Explicitly casting address to address payable
            beneficiaries.push(payable(_beneficiaries[i]));
        }
    }

    // External function
    function distributeFunds(uint256 totalAmount) public {
        uint256 amount = totalAmount / beneficiaries.length;

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            beneficiaries[i].transfer(amount);
        }

        emit FundsDistributed(beneficiaries, amount);
    }

    // View function
    function getBeneficiaries() public view returns (address payable [] memory) {
        return beneficiaries;
    }

    receive() external payable {
        // Optional: Emit an event when Ether is received
        emit FundsReceived(msg.sender, msg.value);
    }

    // Event to log received funds
    event FundsReceived(address sender, uint256 amount);
}