// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiBeneficiary {
    struct Beneficiary {
        address payable beneficiary;
        uint256 weight;
    }

    Beneficiary[] public beneficiaries;

    event FundsDistributed(address[] beneficiaries, uint256[] amounts);

    constructor(Beneficiary[] memory _beneficiaries) {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            beneficiaries.push(_beneficiaries[i]);
        }
    }

    // External function
    function distributeFunds(uint256 totalAmount) public {
        uint256 totalWeight = 0;

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            totalWeight += beneficiaries[i].weight;
        }

        uint256[] memory amounts = new uint256[](beneficiaries.length);
        address[] memory beneficiaryAddresses = new address[](beneficiaries.length);

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            Beneficiary memory beneficiary = beneficiaries[i];
            amounts[i] = (totalAmount * beneficiary.weight) / totalWeight;
            beneficiaryAddresses[i] = beneficiary.beneficiary;
            beneficiary.beneficiary.transfer(amounts[i]);
        }

        emit FundsDistributed(beneficiaryAddresses, amounts);
    }

    // View function
    function getBeneficiaries() public view returns (address[] memory) {
        address[] memory beneficiaryAddresses = new address[](beneficiaries.length);
        for (uint256 i = 0; i < beneficiaries.length; i++) {
            beneficiaryAddresses[i] = beneficiaries[i].beneficiary;
        }
        return beneficiaryAddresses;
    }
}