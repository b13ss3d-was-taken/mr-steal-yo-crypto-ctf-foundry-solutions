// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// utilities
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
// core contracts
import {FlatLaunchpeg} from "src/jpeg-sniper/FlatLaunchpeg.sol";
import {Solver} from "src/jpeg-sniper/Solver.sol";

contract Testing is Test {
    address attacker = makeAddr("attacker");
    address o1 = makeAddr("o1");
    address o2 = makeAddr("o2");
    address admin = makeAddr("admin"); // should not be used
    address adminUser = makeAddr("adminUser"); // should not be used

    FlatLaunchpeg flatLaunchpeg;

    /// preliminary state
    function setUp() public {
        // funding accounts
        vm.deal(admin, 10_000 ether);
        vm.deal(attacker, 10_000 ether);
        vm.deal(adminUser, 10_000 ether);

        // deploying core contracts
        vm.prank(admin);
        flatLaunchpeg = new FlatLaunchpeg(69, 5, 5);
    }

    /// solves the challenge
    function testChallengeExploit() public {
        vm.startPrank(attacker, attacker);

        // implement solution here
        new Solver(address(flatLaunchpeg), attacker); //Deploying the contract with its arguments
        vm.stopPrank();
        validation();
    }

    /// expected final state
    function validation() public {
        // attacker mints out collection in one tx
        assertEq(vm.getNonce(attacker), 1); //added a validation to check if its solved in 1 transaction
        assertEq(flatLaunchpeg.totalSupply(), 69);
        assertEq(flatLaunchpeg.balanceOf(attacker), 69);
    }
}
