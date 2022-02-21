---
bookHidden: true
---
# 2021-12-30-Sashimiswap

{{< hint info >}}
# Information

**BlockNumber**:  **ETH #13905602** | **BSC #13923753** | **HECO #11320054**

**Attacker**:

0xa8189407a37001260975b9da61a81c3bd9f55908 ([In ETH](https://etherscan.io/address/0xa8189407a37001260975b9da61a81c3bd9f55908) | [In BSC](https://bscscan.com/address/0xa8189407a37001260975b9da61a81c3bd9f55908))

**Txs**:

ETH: [0x713c2ce2cb424eb746083c25b7e48c368bb64f587c2d77b5c474a307a79bf069](https://etherscan.io/tx/0x713c2ce2cb424eb746083c25b7e48c368bb64f587c2d77b5c474a307a79bf069)

BSC: [0xdf719d2535be32e302c1670a7453bdf648101a43b412e44d9e7e3e3754cc3387](https://bscscan.com/tx/0xdf719d2535be32e302c1670a7453bdf648101a43b412e44d9e7e3e3754cc3387)

HECO: [0xecde0b3821a8d250810db91d7ef82acced1eaf28324807bdbdfd755537366438](https://hecoinfo.com/tx/0xecde0b3821a8d250810db91d7ef82acced1eaf28324807bdbdfd755537366438)

**Victims**:

[ETH-UniswapV2Router02 0xe4FE6a45f354E845F954CdDeE6084603CEDB9410](https://etherscan.io/address/0xe4fe6a45f354e845f954cddee6084603cedb9410#code)

[ETH-SashimiInvestment 0x3F966FA1c0606e19047ed72068D2857677E07EF4](https://etherscan.io/address/0x3f966fa1c0606e19047ed72068d2857677e07ef4#code)

[ETH-Unitroller 0xB5d53eC97Bed54fe4c2b77f275025c3fc132D770](https://etherscan.io/address/0xb5d53ec97bed54fe4c2b77f275025c3fc132d770#code)

[BSC-UniswapV2Router02 0x24cEFA86fC1826FD31b4cb911034907735F8085A](https://bscscan.com/address/0x24cefa86fc1826fd31b4cb911034907735f8085a#code)

[HECO-UniswapV2Router02 0x1DaeD74ed1dD7C9Dabbe51361ac90A69d851234D](https://hecoinfo.com/address/0x1daed74ed1dd7c9dabbe51361ac90a69d851234d#code)

{{< /hint >}}

- **vulnerable code**

(ETH-UniswapV2Router02:L834-855)
```solidity
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        ensure(deadline)
    {
        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        address pair = UniswapV2Library.pairFor(factory, path[0], path[1]);
        _transferIn(msg.sender,pair,path[0],amountIn);
        uint balanceBefore = getTokenInPair(pair,WETH);
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint balanceAfter = getTokenInPair(pair,WETH);
        uint amountOut = balanceBefore.sub(balanceAfter);
        require(amountOut >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        _transferETH(to, amountOut);
    }
```

(ETH-UniswapV2Router02:L772-795)
```solidity
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = getTokenInPair(address(pair),input).sub(reserveInput);
            amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? address(this) : _to;
            _transferOut(address(pair), output, amountOutput, to);
            if(i < path.length - 2){
                address nextPair = UniswapV2Library.pairFor(factory, output, path[i + 2]);
                _pools[nextPair][output]=_pools[nextPair][output].add(amountOutput);
            }
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
```

(:L886-894)
```solidity
    function getTokenInPair(address pair,address token) 
        public
        view
        virtual
        override
        returns (uint balance)
    {
        return _pools[pair][token];
    }
```

(ETH-UniswapV2Router02:L475-479)
```solidity
    function _transferIn(address from,address pair, address token, uint amount) internal {
        uint beforeBalance = IERC20(token).balanceOf(address(this));
        TransferHelper.safeTransferFrom(token, from, address(this), amount);
        _pools[pair][token] = _pools[pair][token].add(IERC20(token).balanceOf(address(this))).sub(beforeBalance);
    }
```

(ETH-UniswapV2Router02:L447-458)
```solidity
    function _transferOut(address pair, address token, uint amount, address to) internal returns (bool success){
        require(_pools[pair][token] >= amount, 'TransferHelper: TRANSFER_OUT_FAILED');
        _pools[pair][token] = _pools[pair][token].sub(amount);
        if(to != address(this)){
            uint balance = IERC20(token).balanceOf(address(this));
            if(balance < amount){
                ISashimiInvestment(vault).withdrawWithReBalance(token, amount.sub(balance));
            }
            TransferHelper.safeTransfer(token, to, amount);
        }
        return true;
    }
```

--- 
2022-2-21: 复盘这次攻击时发现, Sashimiswap的资产不仅仅存放在Router中, 其PCV还包含一个类似Compound的Lending, 当Router中流动性不足时做Trade会去Lending中先withdraw

陆续发现的几次小的攻击：

0x86cba63cf824c2fce6a332fd217a1ef6b2627d8609a47570efd54b6b1c77118d

0x90f8189c342b9f376d044da518f3c352cfb4376660df88fe06b5ab4fd8d4690e

0xf084eba9c6a5c5811442342e9cec95c17a14095393bb009efabd9878394ce1ec

0x20b21fe589dfea4ce4289e6af0509259af1e32173aec679fb4bfd1bc3ae142e1

---

### **漏洞原因**

- 逻辑漏洞

`swapExactTokensForETHSupportingFeeOnTransferTokens` 本应从一条交易路径 (Trade Path) 的最后一个 Pair 将 ETH 转出, **由于实现逻辑的错误, 不仅最后一个 Pair 转出 ETH, 第一个 Pair 重复转出了 ETH**

Sashimiswap 采用一种与 Uniswap 背道而驰的方法储备流动性: 将**所有的流动性都放在 Router 里** (Uniswap 不同 Pair 的流动性就存储在相应的 Pair 合约中), **Router 不仅承担了记账的工作, 还存储了全部的流动性**

`swapExactTokensForETHSupportingFeeOnTransferTokens` 先将用户的 输入Token 转入第一个 Pair (pair0), 接下来调用 `_swapSupportingFeeOnTransferTokens` 按照 path 不断在路径上的 Pair 中做 trade (只有最后一个 Pair 发生实际转账, 其他的只改变 Router 中的记账 `_pools[pair][token]`), 最后根据 pair0 前后 WETH 的差值判断应转给用户

问题就出在最后根据 pair0 中 WETH 差值转账给用户这里, 我们根据几种简单的情况来看:

❌ Case 1: [A, WETH]: `_swapSupportingFeeOnTransferTokens` 未执行, 外层的 `swapExactTokensForETHSupportingFeeOnTransferTokens` 没有转账 (第一个 Pair 前后 WETH 不变) 

✔️ Case 2: [A, B, ..., WETH]: `_swapSupportingFeeOnTransferTokens` 前面的 Pair 虚拟转账, 最后一个 Pair 实际转账, 外层的 `swapExactTokensForETHSupportingFeeOnTransferTokens` 没有转账

❌ Case 3: [A, WETH, B, C, WETH]: `_swapSupportingFeeOnTransferTokens` 前面的 Pair 虚拟转账, 最后一个 Pair 实际转账, 外层的 `swapExactTokensForETHSupportingFeeOnTransferTokens` 由于第一个 Pair 中 WETH 余额变化, 转账差值

只有 Case 2 可以正确执行, Case 1 会导致用户亏损, 而 Case 3 会导致项目方亏损

> Note: 鸡蛋放在一个笼子里的做法是不可取的

### **攻击流程**
 
> 1. 根据 Case 3, 我们只需要找到或者构建出 [A, WETH, B, C, WETH] 这样一条 path 即可实现零元购, 而 A-WETH 这个 Pair 能换出的 WETH 越多需要攻击的次数变越小
>
> **Note**: 理论上, 如果是这个 path 是 Sashimiswap 中原本就存在的, 一次 trade 即可获利 (A换出2倍的WETH), 但是如果 path 是自己构建的, 因为 path 中所有的 WETH 都是攻击者投入的, 所以只做一次 trade 只是把投入的 WETH 取出, 并不会照成 Sashimiswap 的亏损, 但是这次 trade 结束后, A/WETH 中的 WETH 转移到了 WETH/B 中, 这部分是多出来的, 只需要做一次反向的 trade (B->WETH), 或是移除流动性, 即可使 Sashimiswap 亏损
>
> 2. 对于 Router 中的其他 token, 只需要在 token/WETH 中做一次swap, 向 Router 中注入自己的 WETH (反正可以取出来)


**Step 1**: 用WETH换空Sashimiswap中的各种token

**Step 2**: 向 A/WETH, B/WETH, B/C, C/WETH 中添加流动性 (创建 Pair)
> Note: 最好保证 A/WETH 中 A 的价格非常高 (即A占比非常小)

**Step 3**: 调用 `swapExactTokensForETHSupportingFeeOnTransferTokens` 传入 path [A, WETH, B, WETH], 取走出大量额外的WETH

**Step 4**: 在B/WETH中做一次反向的 trade (B->WETH) 或是移除所有 Pair 的流动性, 取回投入的 WETH

### **漏洞复现**
见: https://github.com/3-F/defi-rekt/tree/master/pocs/2021-12-30-sashimiswap