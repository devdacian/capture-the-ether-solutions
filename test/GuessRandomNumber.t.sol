// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/GuessRandomNumber.sol";

contract GuessRandomNumberTest is Test {
    GuessTheRandomNumberChallenge vulnContract;
    GuessRandomNumberAttack       attackContract;
 
    function setUp() public {
        vulnContract   = new GuessTheRandomNumberChallenge();
        attackContract = new GuessRandomNumberAttack();

        // attacker contract requires 1 ether to execute attack
        deal(address(attackContract), 1 ether); 
        // initializes challenge, requires 1 ether sent to vuln contract
        vulnContract.GuessRandomNumberChallenge{value: 1 ether}();
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
