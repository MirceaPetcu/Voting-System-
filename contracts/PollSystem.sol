// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Escrow.sol";
import "./Poll.sol";
contract PollSystem {
    Escrow[] public escrows;
    Poll[] polls;
    
   
    constructor() {
    }

    function getPolls() public view returns(Poll[] memory) {
        return polls;
    }
    
    // function getPoll(uint256 index) public view returns(Poll.PollData memory){
    //     return polls[index].getPoll();
    // } 
     function getPoll(uint256 pollId) public view returns (string memory) {
        return polls[pollId].getPoll();
    }

    function vote(uint256 indexPoll, uint256 indexVote) public payable   {
        polls[indexPoll].vote{value: msg.value}(indexVote);
    }

    function addPoll(Poll poll) public {
        polls.push(poll);
    }

    function addEscrow(Escrow escrow) public {
        escrows.push(escrow);
    }

    function getPollCount() public view returns(uint256) {
        return polls.length;
    }

    function getAmountFromEscrow(uint256 escrowId) public view returns(uint256) {
        return address(escrows[escrowId]).balance;
    }

    function releaseFunds(uint256 escrowId) public {
        escrows[escrowId].releaseFunds();
    }

}