---
bookHidden: true
---
# 2022-01-28-Qubit

{{< hint info >}}
# Information

**BlockNumber**:  **ETH #13905789** | **BSC #13923753** | **HECO #11320054**

**Attacker**:

0xa8189407a37001260975b9da61a81c3bd9f55908 ([In ETH](https://etherscan.io/address/0xa8189407a37001260975b9da61a81c3bd9f55908) | [In BSC](https://bscscan.com/address/0xa8189407a37001260975b9da61a81c3bd9f55908))

**Txs**:

ETH: [0x713c2ce2cb424eb746083c25b7e48c368bb64f587c2d77b5c474a307a79bf069](https://etherscan.io/tx/0x713c2ce2cb424eb746083c25b7e48c368bb64f587c2d77b5c474a307a79bf069)

BSC: [0xdf719d2535be32e302c1670a7453bdf648101a43b412e44d9e7e3e3754cc3387](https://bscscan.com/tx/0xdf719d2535be32e302c1670a7453bdf648101a43b412e44d9e7e3e3754cc3387)

HECO: [0xecde0b3821a8d250810db91d7ef82acced1eaf28324807bdbdfd755537366438](https://hecoinfo.com/tx/0xecde0b3821a8d250810db91d7ef82acced1eaf28324807bdbdfd755537366438)

**Victims**:

[ETH-UniswapV2Router02 0xe4FE6a45f354E845F954CdDeE6084603CEDB9410](https://etherscan.io/address/0xe4fe6a45f354e845f954cddee6084603cedb9410#code)

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

### **漏洞原因**


### **攻击流程**


### **漏洞复现**