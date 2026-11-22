// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SimpleVault.sol";
import "./CloneFactory.sol";

/// @title VaultFactory
/// @notice 业务工厂：部署一次 master，然后为每个用户创建独立的克隆金库。
contract VaultFactory is CloneFactory {
    address public immutable master;

    event VaultCreated(address indexed vault, address indexed owner, string name);

    constructor(address _master) {
        master = _master;
    }

    /// @notice 创建一个新的克隆金库并立即初始化
    function createVault(address owner_, string calldata name_)
        external
        returns (address vault)
    {
        vault = createClone(master);
        // 克隆体不走 constructor，必须手动调 init()
        SimpleVault(vault).init(owner_, name_);
        emit VaultCreated(vault, owner_, name_);
    }
}
