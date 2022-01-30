---
bookHidden: true
---
# 2022-01-28-Qubit

{{< hint info >}}
# Information

**BlockNumber**:  **ETH #14090197** | **BSC #14742533**

**Attacker**:

0xD01Ae1A708614948B2B5e0B7AB5be6AFA01325c7 ([In ETH](https://etherscan.io/address/0xd01ae1a708614948b2b5e0b7ab5be6afa01325c7) | [In BSC](https://bscscan.com/address/0xd01ae1a708614948b2b5e0b7ab5be6afa01325c7))

**Txs**:

deposit (ETH): [0x478d83f2ad909c64a9a3d807b3d8399bb67a997f9721fc5580ae2c51fab92acf](https://etherscan.io/tx/0x478d83f2ad909c64a9a3d807b3d8399bb67a997f9721fc5580ae2c51fab92acf)

profit (BSC): [0x33628dcc2ca6cd89a96d241bdf17cdc8785cf4322dcaf2c79766c990579aea02](https://bscscan.com/tx/0x33628dcc2ca6cd89a96d241bdf17cdc8785cf4322dcaf2c79766c990579aea02)

**Victims**:

[ETH-QBridge-Proxy 0x20E5E35ba29dC3B540a1aee781D0814D5c77Bce6](https://etherscan.io/address/0x20e5e35ba29dc3b540a1aee781d0814d5c77bce6#code)

[ETH-QBridge 0x99309d2e7265528dC7C3067004cC4A90d37b7CC3](https://etherscan.io/address/0x99309d2e7265528dc7c3067004cc4a90d37b7cc3#code)

[ETH-QBridgeHandler-Proxy 0x17B7163cf1Dbd286E262ddc68b553D899B93f526](https://etherscan.io/address/0x17b7163cf1dbd286e262ddc68b553d899b93f526#code)

[ETH-QBridgeHandler 0x80D1486eF600cc56d4df9ed33bAF53C60D5A629b](https://etherscan.io/address/0x80d1486ef600cc56d4df9ed33baf53c60d5a629b#code)

[BSC-QBridge-Proxy 0x4d8aE68fCAe98Bf93299548545933c0D273BA23a](https://bscscan.com/address/0x4d8ae68fcae98bf93299548545933c0d273ba23a#code)

[BSC-QBridge 0xD88E328c305f541e2De6D3c85ed081653cd8A726](https://bscscan.com/address/0xd88e328c305f541e2de6d3c85ed081653cd8a726#code)

[BSC-QBridgeHandler-Proxy 0xC6A080E22F87CB343f6944052F5Acd327770f51B](https://bscscan.com/address/0xc6a080e22f87cb343f6944052f5acd327770f51b#code)

[BSC-QBridgeHandler 0x04590277257DD6E89Ce07Aa4673833e8d52d1f85](https://bscscan.com/address/0x04590277257dd6e89ce07aa4673833e8d52d1f85#code)

[BSC-xETH 0x2F422fe9EA622049d6f73f81A906b9b8cff03b7f](https://bscscan.com/address/0x2F422fe9EA622049d6f73f81A906b9b8cff03b7f#readProxyContract)
{{< /hint >}}

- **vulnerable code**

(Qbridge:L192-226)
```solidity
    /**
        @notice Initiates a transfer using a specified handler contract.
        @notice Only callable when Bridge is not paused.
        @param destinationDomainID ID of chain deposit will be bridged to.
        @param resourceID ResourceID used to find address of handler to be used for deposit.
        @param data Additional data to be passed to specified handler.
        @notice Emits {Deposit} event with all necessary parameters
     */
    function deposit(uint8 destinationDomainID, bytes32 resourceID, bytes calldata data) external payable notPaused {
        require(msg.value == fee, "QBridge: invalid fee");

        address handler = resourceIDToHandlerAddress[resourceID];
        require(handler != address(0), "QBridge: invalid resourceID");

        uint64 depositNonce = ++_depositCounts[destinationDomainID];

        IQBridgeHandler(handler).deposit(resourceID, msg.sender, data);
        emit Deposit(destinationDomainID, resourceID, depositNonce, msg.sender, data);
    }

    function depositETH(uint8 destinationDomainID, bytes32 resourceID, bytes calldata data) external payable notPaused {
        uint option;
        uint amount;
        (option, amount) = abi.decode(data, (uint, uint));

        require(msg.value == amount.add(fee), "QBridge: invalid fee");

        address handler = resourceIDToHandlerAddress[resourceID];
        require(handler != address(0), "QBridge: invalid resourceID");

        uint64 depositNonce = ++_depositCounts[destinationDomainID];

        IQBridgeHandler(handler).depositETH{value:amount}(resourceID, msg.sender, data);
        emit Deposit(destinationDomainID, resourceID, depositNonce, msg.sender, data);
    }
```

(QBridgeHandler:L114-149)
```solidity
    /**
        @notice A deposit is initiated by making a deposit in the Bridge contract.
        @param resourceID ResourceID used to find address of token to be used for deposit.
        @param depositer Address of account making the deposit in the Bridge contract.
        @param data passed into the function should be constructed as follows:
        option                                 uint256     bytes  0 - 32
        amount                                 uint256     bytes  32 - 64
     */
    function deposit(bytes32 resourceID, address depositer, bytes calldata data) external override onlyBridge {
        uint option;
        uint amount;
        (option, amount) = abi.decode(data, (uint, uint));

        address tokenAddress = resourceIDToTokenContractAddress[resourceID];
        require(contractWhitelist[tokenAddress], "provided tokenAddress is not whitelisted");

        if (burnList[tokenAddress]) {
            require(amount >= withdrawalFees[resourceID], "less than withdrawal fee");
            QBridgeToken(tokenAddress).burnFrom(depositer, amount);
        } else {
            require(amount >= minAmounts[resourceID][option], "less than minimum amount");
            tokenAddress.safeTransferFrom(depositer, address(this), amount);
        }
    }

    function depositETH(bytes32 resourceID, address depositer, bytes calldata data) external payable override onlyBridge {
        uint option;
        uint amount;
        (option, amount) = abi.decode(data, (uint, uint));
        require(amount == msg.value);

        address tokenAddress = resourceIDToTokenContractAddress[resourceID];
        require(contractWhitelist[tokenAddress], "provided tokenAddress is not whitelisted");

        require(amount >= minAmounts[resourceID][option], "less than minimum amount");
    }
```

(QBridgeHandler-SafeERC20:L28-47)
```solidity
    function safeTransfer(
        address token,
        address to,
        uint value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }
```

### **漏洞原因**
1. **safeTransfer / safeTransferFrom 的错误实现**

SafeERC20 的出现是为了处理非标准 ERC20, 有些 ERC20 的现实有返回值, 而有些没有. 所以 safeTransfer 使用底层的 Call 方法, 实现对两种情况的处理

从语义上来看, SafeTransfer 隐含着 `token 是一个 ERC20 合约地址` 这一前置条件, 但这一条件在上面这种简单实现中并不是一个显示的约束 (Openzeppelin 会通过 `Address.functionCall` 中的 `isContract` 来对此校验)

同时, EVM在底层实现上对CALL这一指令并没有区分合约账户还是EOA账户 (比如: send value也是通过call来实现的), 当call指令的toAddr是一个EOA时, 并不会抛出异常, 而是产生一种短路的效果, 直接执行结束, 返回 true + empty data

因此当这种简化版 `safeTransfer / safeTransferFrom` 传入的 token 并不是一个ERC20合约时, 行为是不符合预期的 (实际上并没有成功transfer, 却通过了后置检查)

> Note: 使用这种简化版的 SafeERC20 库的项目并不少, 单纯的信任 SafeXXX 的结果一定是 **成功执行了 transfer/transferFrom/approve** 是有风险的

- **EVM.Call:**
{{< mermaid class="text-center" >}}
stateDiagram-v2
    State0: opCall -> evm.Call
    State1: ➡️ insufficient balance ?
    State2: ➡️ account exist ?
    State3: ➡️ isPreCompile ?
    State4: ➡️ codeLength == 0 ?
    Res1:  nil, ErrInsufficientBalance
    Res2:  nil, nil
    Res3:  RunPrecompiledContract -> ret, err
    Res4: ➡️ nil, nil
    Res5:  evm.interpreter.Run -> ret, err
    State0 --> State1
    State1 --> Res1: T
    State1 --> State2: F
    State2 --> State3: T
    State2 --> Res2: F
    State3 --> Res3: T
    State3 --> State4: F 
    State4 --> Res4: T
    State4 --> Res5: F
{{< /mermaid >}}

[core/vm/instructions.go]
```go
func opCall(pc *uint64, interpreter *EVMInterpreter, scope *ScopeContext) ([]byte, error)  {
    ...
    ret, returnGas, err := interpreter.evm.Call(scope.Contract, toAddr, args, gas, bigVal)

	if err != nil {
		temp.Clear()
	} else {
		temp.SetOne()
	}
	stack.push(&temp)
	if err == nil || err == ErrExecutionReverted {
		ret = common.CopyBytes(ret)
		scope.Memory.Set(retOffset.Uint64(), retSize.Uint64(), ret)
	}
    ...
}
```
代码中, 也可以看出, 当 `evm.Call` 由于 `toAddr` 为 EOA 而返回 `nil, nil` 后, 先是 `push 0x1` (CALL的返回值: 即 success), 接着返回一个空的 ret

2. **多资产项目没有合理区分native token和ERC20 token**

本次被攻击项目方是一个跨链桥的项目, 跨链桥项目最关键的便是合约emit的事件, relayer会监听并处理这些事件

QBridge存在的问题有:
a) 无法通过Event来区分Native token和ERC20 token (没有独立的namespace), 全部通过resourceId来区分
b) 将 0x000000... 作为 ETH 逻辑上的合约地址

这使得本来只可以通过depositETH来执行的操作(跨链转ETH), 可以通过deposit来执行(因为仅依赖resourceId, 两个函数都接受resourceId作为参数). 但是目前还存在一个阻碍, 就是ETH对应的合约地址是 0x00000.. 按道理是会被 safeTransfer 拦截下来而失败. 但是由于 问题1 的存在, 障碍一扫而净, 直通终点

{{< mermaid class="text-center" >}}
stateDiagram-v2
    State1: deposit
    State2: depositETH
    State3: handler.deposit (check whitelist, burn/transfer...)
    State4: handler.depositETH (check whitelist, msg.value...)
    State5: ❌ safeTransferFrom
    Res1: emit Deposit(destinationDomainID, resourceID, depositNonce, msg.sender, data)
    State1 --> State3
    State3 --> Res1
    State2 --> State4
    State4 --> State5
    State5 --> Res1
{{< /mermaid >}}

> Note 1: 使用 0x00000... 应该格外小心, 因为这个地址是很容易得到的 (任何空的地址变量都会返回 0x00000... )
> 
> Note 2: 多资产项目应注意隔离资产, 比如: 记账时, 或释放事件时(针对跨链项目)...

### **攻击流程**
**Step 1** 调用ETH上的跨链桥合约QBridge, 通过将ETH的resourceId传入给deposit函数, 绕过safeTransferFrom

**Step 2** QBridge执行deposit成功, emit Deposit事件, relayer监听到事件, 证明攻击者已将ETH锁入 QBridge 合约中

**Step 3** 利用虚假的锁定ETH值, 去其他链 (如:BSC) 的 QBridge 跨链桥合约 claim 出相应ETH‘

### **漏洞复现**
见: https://github.com/3-F/defi-rekt/tree/master/pocs/2022-01-28-qbridge