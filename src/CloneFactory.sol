// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title CloneFactory
/// @notice 用原始 EIP-1167 字节码部署最小代理（minimal proxy）。
/// 传给 create 的是【init code】= init 前缀(9B) + runtime(45B)：
///   init 前缀 9B:  3d602d80600a3d3981f3 —— 拷贝 45B runtime 并 return 出去
///   runtime 前缀:  363d3d373d3d3d363d73
///   runtime 中间:  master 地址（20B，部署时拼接）
///   runtime 后缀:  5af43d82803e903d91602b57fd5bf3
contract CloneFactory {
    event CloneCreated(address indexed clone, address indexed master);

    /// @dev 在链上部署一个指向 master 的 EIP-1167 克隆体，返回新地址
    function createClone(address master) internal returns (address clone) {
        bytes memory bytecode = abi.encodePacked(
            hex"3d602d80600a3d3981f3",
            hex"363d3d373d3d3d363d73",
            master,
            hex"5af43d82803e903d91602b57fd5bf3"
        );
        assembly {
            // create(value=0, memOffset, length) —— 标准内联汇编用法
            clone := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(clone != address(0), "clone deploy failed");
        emit CloneCreated(clone, master);
    }
}
