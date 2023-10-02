//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testApproveAllowance() public {
        // from Phind / alchemy.com
        uint256 allowanceAmount = 100;

        vm.prank(bob);
        ourToken.approve(alice, allowanceAmount);
        assertEq(
            ourToken.allowance(bob, alice),
            allowanceAmount,
            "Allowance not correctly set"
        );
    }

    function testUseAllowance() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend 1000 tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 300;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testInsufficientAllowance() public {
        // based on a suggestion from Bard

        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend 1000 tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Alice tries to transfer more than the allowance
        uint256 transferAmount = initialAllowance + 1;
        vm.prank(alice);
        vm.expectRevert();

        // This should revert
        ourToken.transferFrom(bob, alice, transferAmount);
    }

    function testTransfer() public {
        uint256 amount = 100;
        uint256 deployerBalance = ourToken.balanceOf(msg.sender);

        // Check sender balance after giving some to bob
        assertEq(deployerBalance, deployer.INITIAL_SUPPLY() - STARTING_BALANCE);

        // Transfer tokens from the sender to the recipient.
        vm.prank(msg.sender);
        ourToken.transfer(alice, amount);

        // Check that the balances are correct.
        assertEq(ourToken.balanceOf(msg.sender), deployerBalance - amount);
        assertEq(ourToken.balanceOf(alice), amount);
    }

    function testTransferInsufficientBalance() public {
        uint256 amount = deployer.INITIAL_SUPPLY() + 1;

        vm.expectRevert();
        ourToken.transfer(alice, amount);
    }

    function testTransferToZeroAddress() public {
        vm.expectRevert();
        ourToken.transfer(address(0), 100);
    }

    function testApproveAndChangeAllowance() public {
        uint256 allowanceAmount = 50;

        // Approve alice to spend tokens on behalf of bob
        vm.prank(bob);
        ourToken.approve(alice, allowanceAmount);

        assertEq(ourToken.allowance(bob, alice), allowanceAmount);

        // Increase allowance
        uint256 newAllowanceAmount = 100;
        vm.prank(bob);
        ourToken.increaseAllowance(alice, newAllowanceAmount);
        assertEq(
            ourToken.allowance(bob, alice),
            allowanceAmount + newAllowanceAmount
        );

        // Decrease allowance
        uint256 decreaseAmount = 30;
        vm.prank(bob);
        ourToken.decreaseAllowance(alice, decreaseAmount);
        assertEq(
            ourToken.allowance(bob, alice),
            allowanceAmount + newAllowanceAmount - decreaseAmount
        );
    }
}
