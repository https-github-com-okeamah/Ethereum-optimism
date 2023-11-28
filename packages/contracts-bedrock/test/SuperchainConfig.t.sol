// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { CommonTest } from "test/setup/CommonTest.sol";

// Libraries
import { Types } from "src/libraries/Types.sol";
import { Hashing } from "src/libraries/Hashing.sol";

// Target contract dependencies
import { Proxy } from "src/universal/Proxy.sol";

// Target contract
import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";

contract SuperchainConfig_Init_Test is CommonTest {
    /// @dev Tests that initialization sets the correct values. These are defined in CommonTest.sol.
    function test_initialize_values_succeeds() external {
        assertFalse(superchainConfig.paused());
        assertEq(superchainConfig.guardian(), deploy.cfg().portalGuardian());
    }
}

contract SuperchainConfig_Pause_TestFail is CommonTest {
    /// @dev Tests that `pause` reverts when called by a non-guardian.
    function test_pause_notGuardian_reverts() external {
        assertFalse(superchainConfig.paused());

        assertTrue(superchainConfig.guardian() != alice);
        vm.expectRevert("SuperchainConfig: only guardian can pause");
        vm.prank(alice);
        superchainConfig.pause("identifier");

        assertFalse(superchainConfig.paused());
    }
}

contract SuperchainConfig_Pause_Test is CommonTest {
    /// @dev Tests that `pause` successfully pauses
    ///      when called by the guardian.
    function test_pause_succeeds() external {
        assertFalse(superchainConfig.paused());

        vm.expectEmit(address(superchainConfig));
        emit Paused("identifier");

        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("identifier");

        assertTrue(superchainConfig.paused());
    }
}

contract SuperchainConfig_Unpause_TestFail is CommonTest {
    /// @dev Tests that `unpause` reverts when called by a non-guardian.
    function test_unpause_notGuardian_reverts() external {
        vm.prank(deploy.cfg().portalGuardian());
        superchainConfig.pause("identifier");
        assertEq(superchainConfig.paused(), true);

        assertTrue(superchainConfig.guardian() != alice);
        vm.expectRevert("SuperchainConfig: only guardian can unpause");
        vm.prank(alice);
        superchainConfig.unpause();

        assertTrue(superchainConfig.paused());
    }
}

contract SuperchainConfig_Unpause_Test is CommonTest {
    /// @dev Tests that `unpause` successfully unpauses
    ///      when called by the guardian.
    function test_unpause_succeeds() external {
        vm.prank(deploy.cfg().portalGuardian());
        superchainConfig.pause("identifier");
        assertEq(superchainConfig.paused(), true);

        vm.expectEmit(address(superchainConfig));
        emit Unpaused();
        vm.prank(deploy.cfg().portalGuardian());
        superchainConfig.unpause();

        assertFalse(superchainConfig.paused());
    }
}
