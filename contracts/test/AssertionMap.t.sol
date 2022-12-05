// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/AssertionMap.sol";

contract AssertionMapTest is Test {
    //AssertionMap Params
    AssertionMap public map;
    address _rollupAddress = address(this);

    //Assertion Params
    bytes32 stateHash = keccak256(abi.encodePacked(uint256(2), uint256(0)));
    uint256 assertionID = 0;
    uint256 inboxSize = 1;
    uint256 parentID = 2468;
    uint256 deadline = 1234;

    uint256 proposalTime = block.number;
    address stakerAddress = address(3333);

    function setUp() public {
        map = new AssertionMap(_rollupAddress);

        map.createAssertion(
            assertionID,
            stateHash,
            inboxSize,
            parentID,
            deadline
        );
    }

    function testCreateAssertion() public {
        // depends on getStateHash

        uint256 assertionID = 1;
        bytes32 stateHash = keccak256(abi.encodePacked(uint256(3), uint256(3)));
        uint256 inboxSize = 1;
        uint256 parentID = 2469;
        uint256 deadline = 1235;

        map.createAssertion(
            assertionID,
            stateHash,
            inboxSize,
            parentID,
            deadline
        );

        assertEq(map.getStateHash(assertionID), stateHash);
    }

    function testGetStateHash() public {
        assertEq(map.getStateHash(assertionID), stateHash);
    }

    function testGetInboxSize() public {
        assertEq(map.getInboxSize(assertionID), inboxSize);
    }

    function testGetParentID() public {
        assertEq(map.getParentID(assertionID), parentID);
    }

    function testGetDeadline() public {
        assertEq(map.getDeadline(assertionID), deadline);
    }

    function testGetProposalTime() public {
        assertEq(map.getProposalTime(assertionID), proposalTime);
    }

    function testGetNumStakers() public {
        assertEq(map.getNumStakers(assertionID), 0);
    }

    function testStakeOnAssertion() public {
        map.stakeOnAssertion(assertionID, stakerAddress);
        assertEq(map.getNumStakers(assertionID), 1);
    }

    function testIsStaker() public {
        map.stakeOnAssertion(assertionID, stakerAddress);
        assertEq(map.isStaker(assertionID, stakerAddress), true);
    }

    function testIsStaker2() public {
        assertEq(map.isStaker(assertionID, stakerAddress), false);
    }

    function testDeleteAssertion() public {
        // Depends on getStateHash
        map.deleteAssertion(assertionID);
        assertEq(map.getStateHash(assertionID) != stateHash, true);
    }
}
