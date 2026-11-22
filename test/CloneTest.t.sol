// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SimpleVault} from "../src/SimpleVault.sol";
import {VaultFactory} from "../src/VaultFactory.sol";

contract CloneTest is Test {
    VaultFactory factory;
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");

    function setUp() public {
        // 只部署一次 master（逻辑模板）
        SimpleVault master = new SimpleVault();
        factory = new VaultFactory(address(master));
    }

    /// @dev 两个克隆体各自独立存储：余额、owner 互不影响
    function testCloneHasIndependentStorage() public {
        address v1 = factory.createVault(alice, "alice-vault");
        address v2 = factory.createVault(bob, "bob-vault");

        assertEq(SimpleVault(v1).owner(), alice);
        assertEq(SimpleVault(v2).owner(), bob);
        assertEq(SimpleVault(v1).name(), "alice-vault");

        vm.deal(alice, 1 ether);
        vm.prank(alice);
        SimpleVault(v1).deposit{value: 1 ether}();

        assertEq(SimpleVault(v1).balance(), 1 ether);
        assertEq(SimpleVault(v2).balance(), 0, "v2 storage must stay untouched");
    }

    /// @dev 克隆体字节码就是标准 EIP-1167：45 字节，前缀 + master 地址 + 后缀
    function testBytecodeIsStandardEIP1167() public {
        address v1 = factory.createVault(alice, "alice-vault");

        bytes memory code = v1.code;
        assertEq(code.length, 45, "minimal proxy must be 45 bytes");

        assertEq(
            code,
            abi.encodePacked(
                hex"363d3d373d3d3d363d73",
                factory.master(),
                hex"5af43d82803e903d91602b57fd5bf3"
            )
        );
    }
}
