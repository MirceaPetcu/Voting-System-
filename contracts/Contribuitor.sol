// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./MultiBeneficiary.sol";
contract Contribuitor {
    
    MultiBeneficiary mb;
    constructor(MultiBeneficiary _mb) {
        mb = _mb;
    }
    receive() external payable {
    }
    function contrib() public payable {
        uint256 amount = msg.value;
        address payable[] memory beneficiaries = mb.getBeneficiaries();

        address payable  receiver = beneficiaries[0];
        (bool success, ) = address(receiver).call{value: amount}("");
        require(success, "Failed to send Ether");
    }
}