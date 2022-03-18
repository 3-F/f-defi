---
bookHidden: true
---
# 2022-02-07-EarnHub

{{< hint info >}}
# Information

**BlockNumber**:  **#15052956**

**Attacker**:

[0x3d98AEE279c82D8178b87D9D4dC442d65224dacc](https://bscscan.com/address/0x3d98aee279c82d8178b87d9d4dc442d65224dacc)

**Txs**:

[0x40e69064c70d7db8b2dcbad441da9a06a507f8f90959da3c2583242f89e01d3c](https://bscscan.com/tx/0x40e69064c70d7db8b2dcbad441da9a06a507f8f90959da3c2583242f89e01d3c) e.g.

**Victims**:

[ReflectionBackedStaking 0x63bDBea2Fec57896091019Bbe887a35E6Dc229bd](https://bscscan.com/address/0x63bdbea2fec57896091019bbe887a35e6dc229bd#code)


{{< /hint >}}

- **vulnerable code**

(ReflectionBackedStaking.sol:L255-267)
```solidity
    // * Enables hopping between staking pools
    // ! Authorize all pools to enable hops.
    function makeHop(IStaking _newPool) external override {
        require(shares[msg.sender].amount > 0, 'Not enough in stake to hop');
        uint256 amt = shares[msg.sender].amount;
        // Pay native token rewards.
        if (getUnpaidEarnings(msg.sender) > 0) {
            giveStakingReward(msg.sender);
        }
        _removeShares(amt, msg.sender);
        tokenPool.stakingToken.approve(address(_newPool), tokenPool.stakingToken.totalSupply());
        _newPool.receiveHop(amt, msg.sender, payable(address(this)));
    }
```

### **漏洞原因**

- 用户传参导致的不可信外部调用

这是一个比较简单的漏洞, 我们一眼就可以看到在函数 `makeHop` 的最后两行, 先是 `approve` 了用户传入的地址 `_newPool`， 接着又调用了这个不可信地址上的函数 `receiveHop`， 这简直是慈善家行为， 无条件的信任用户 (public approve)

项目合约 `approve` 给了 `_newPool` 后, `_newPool` 便可以任意使用合约中的资产, 最后的 `_newPool.receiveHop` 只要 `_newPool` 是个合约 (有 `fallback` 函数, 或是实现一个 `receiveHop` 函数) 就可以绕过

Q: 为什么攻击者要反复小额transferFrom?

### **攻击流程**


### **漏洞复现**
见: https://github.com/3-F/defi-rekt/tree/master/pocs/2022-02-07-earnhub