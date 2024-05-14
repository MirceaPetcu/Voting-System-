pragma solidity ^0.8.0;

contract Escrow {
    address payable public beneficiary;
    uint256[] private voteCount;

    event FundsReleased(address beneficiary, uint256 amount);

    constructor(address payable _beneficiary) {
        beneficiary = _beneficiary;
    }

    // View function
    function voteCounts() public view returns (uint256[] memory) {
        return voteCount;
    }

    // External function
    function releaseFunds() public {
        uint256 amount = address(this).balance;
        beneficiary.transfer(amount);

        emit FundsReleased(beneficiary, amount);
    }
}