// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/GuessSecretNumber.sol";

contract GuessSecretNumberTest is Test {
    GuessTheSecretNumberChallenge vulnContract;
    GuessSecretNumberAttack       attackContract;
 
    function setUp() public {
        vulnContract   = new GuessTheSecretNumberChallenge();
        attackContract = new GuessSecretNumberAttack();

        // both vulnerable & attacker contracts start with 1 ether
        deal(address(vulnContract), 1 ether);
        deal(address(attackContract), 1 ether);
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
        attackContract.attack(payable(address(vulnContract)));

        assertEq(address(vulnContract).balance, 0 ether);
        assertEq(address(attackContract).balance, 2 ether);
        assertTrue(vulnContract.isComplete());
    }

}
