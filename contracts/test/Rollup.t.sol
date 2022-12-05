// SPDX-License-Identifier: Apache-2.0

/*
 * Modifications Copyright 2022, Specular contributors
 *
 * This file was changed in accordance to Apache License, Version 2.0.
 *
 * Copyright 2021, Offchain Labs, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/SequencerInbox.sol";
import "../src/Rollup.sol";
import "../src/challenge/Challenge.sol";
import "../src/challenge/ChallengeLib.sol";
import {Utils} from "./utils/Utils.sol";

contract BaseSetup is Test {
    Utils internal utils;
    address payable[] internal users;

    address internal rollup;
    address internal owner;
    address internal sequencer;
    address internal verifier;
    address internal stakeToken;
    uint256 internal confirmationPeriod;
    uint256 internal challengePeriod;
    uint256 internal minimumAssertionPeriod;
    uint256 internal maxGasPerAssertion;
    uint256 internal baseStakeAmount = 10;
    bytes32 internal initialVMhash;
    address internal staker;
    address internal challenger;

    function setUp() public virtual {
        utils = new Utils();
        users = utils.createUsers(7);

        rollup = users[0];
        vm.label(rollup, "Rollup");

        owner = users[1];
        vm.label(sequencer, "Owner");

        sequencer = users[2];
        vm.label(sequencer, "Sequencer");

        verifier = users[3];
        vm.label(sequencer, "Verifier");

        stakeToken = users[4];
        vm.label(sequencer, "Stake Token");

        staker = users[5];
        vm.label(staker, "Staker");

        challenger = users[6];
        vm.label(challenger, "Challenger");
    }
}

contract RollupTest is BaseSetup {
    Rollup private roll;

    function setUp() public virtual override {
        BaseSetup.setUp();

        Rollup _impl = new Rollup();
        bytes memory data = abi.encodeWithSelector(
            Rollup.initialize.selector,
            owner,
            sequencer,
            verifier,
            stakeToken,
            confirmationPeriod,
            challengePeriod,
            minimumAssertionPeriod,
            maxGasPerAssertion,
            baseStakeAmount,
            initialVMhash
        );
        address admin = address(47); // Random admin
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(_impl), admin, data);

        roll = Rollup(address(proxy));
    }

    function testSufficientStake() external {
        vm.prank(staker);
        roll.stake{value: 100}();
        assertEq(roll.isStaked(staker), true);
    }

    function testCurrentRequiredStake() external {
        assertEq(roll.currentRequiredStake(), baseStakeAmount);
    }

    function testInsufficientStakeReverts() external {
        vm.prank(staker);
        vm.expectRevert(bytes("INSUFFICIENT_STAKE"));
        roll.stake{value: 1}();
    }

    function testRequireStaked() external {
        vm.prank(staker);
        vm.expectRevert(bytes("NOT_STAKED"));
        roll.unstake(100);
    }

    function testInsufficientFundsUnstake() external {
        vm.prank(staker);
        roll.stake{value: 10}();
        vm.prank(staker);
        vm.expectRevert(bytes("INSUFFICIENT_FUNDS"));
        roll.unstake(15);
    }

    function testNumStakers() external {
        vm.prank(staker);
        roll.stake{value: 10}();
        assertEq(roll.numStakers(), 1);
    }
}
