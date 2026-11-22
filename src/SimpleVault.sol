// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleVault (master / 实现合约)
/// @notice 这是被所有克隆体共享的"逻辑模板"。
/// 注意：克隆体不会执行本合约的 constructor，
/// 所以初始化必须通过下面的 init() 完成。
contract SimpleVault {
    // —— 存储布局：克隆体与 master 共享同一套槽位声明，
    //    但 delegatecall 时读写的是【代理壳自己的存储】 ——
    address public owner;
    string public name;
    uint256 public balance;

    /// @notice 克隆体部署后由工厂立即调用，完成一次性初始化
    function init(address _owner, string calldata _name) external {
        require(owner == address(0), "already initialized");
        owner = _owner;
        name = _name;
    }

    function deposit() external payable {
        balance += msg.value;
    }

    function withdraw(address to, uint256 amount) external {
        require(msg.sender == owner, "not owner");
        require(amount <= balance, "insufficient balance");
        balance -= amount;
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "send failed");
    }
}
