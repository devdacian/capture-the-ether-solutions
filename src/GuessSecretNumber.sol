// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GuessTheSecretNumberChallenge {
    bytes32 answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    constructor() payable {
        require(msg.value == 1 ether);
    }
    
    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (keccak256(abi.encodePacked(n)) == answerHash) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}

contract GuessSecretNumberAttack {
  
  constructor() payable {
    require(msg.value == 1 ether);
  }

  function attack (address payable vulnContractAddr) external {
    GuessTheSecretNumberChallenge vulnContract = GuessTheSecretNumberChallenge(vulnContractAddr);

    // common tactic to bypass hard-coded checks: copy the contract's
    // checking code & simply re-calculate the result within the attack contract
    uint8 max           = type(uint8).max;
    bytes32 hashToSolve = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;
    uint8 solution      = 0;

    // brute force hash
    for(uint8 i=0; i<=max; i++) {
      if(keccak256(abi.encodePacked(i)) == hashToSolve) {
        solution = i;
        break;
      }
    }

    vulnContract.guess{value: 1 ether}(solution);
  }

  receive() external payable {}
  fallback() external payable {}
}