# EIP-1167 最小代理 Foundry 演示

一个可运行的最小示例：部署一次 master 逻辑合约，用工厂为每个用户创建独立的 EIP-1167 克隆体。
## 目录
```bash
minimal-proxy-demo/
├── src/
│   ├── SimpleVault.sol    # master：逻辑 + init()，被所有克隆体共享
│   ├── CloneFactory.sol   # EIP-1167 字节码拼接 + create() 内联汇编
│   └── VaultFactory.sol   # 业务工厂：部署 master、创建克隆、调用 init
└── test/
    └── CloneTest.t.sol    # 独立存储测试 + 45 字节标准字节码测试
```
运行
```bash
# 1. 若目录还没有 forge-std 依赖，先在项目内安装
forge install foundry-rs/forge-std

# 2. 跑测试
forge test -vvv
```
预期：两个测试全部通过。

- `testCloneHasIndependentStorage`：v1 存入 1 ETH，v2 余额仍为 0，证明存储独立。
- `testBytecodeIsStandardEIP1167`：克隆体 code 长度为 45，且逐字节等于「前缀 + master 地址 + 后缀」

## 关键点对照
| 概念                               | 代码位置                                                     |
| ---------------------------------- | ------------------------------------------------------------ |
| master 只部署一次                  | `setUp()` 里 `new SimpleVault()`                             |
| 克隆体不走 constructor，手动初始化 | `VaultFactory.createVault` 里的 `SimpleVault(vault).init(...)` |
| 逻辑共享、存储独立                 | `delegatecall` 语义：代码在壳的存储上下文执行                |
| master 地址写死、不可升级          | 字节码中 20 字节地址是部署时拼接的常量                       |
| init code ≠ runtime                | `create` 需要的是构造码：前缀 `3d602d80600a3d3981f3`（拷贝并 return 45B runtime）+ runtime 本体；直接把 runtime 当 init 传会部署失败 |
## 生产替代（惯例）

真实项目一般不手写字节码，直接用 OpenZeppelin：
```bash
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

address clone = Clones.clone(master);                 // 普通
address clone = Clones.cloneDeterministic(master, salt); // 预计算地址
```
## 参考

- EIP-1167: https://eips-wg.github.io/EIPs/1167/
- OpenZeppelin Clones: https://docs.openzeppelin.com/contracts/5.x/api/proxy
- 参考实现: https://github.com/optionality/clone-factory
