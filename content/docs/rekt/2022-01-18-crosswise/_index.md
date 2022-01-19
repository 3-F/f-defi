---
bookHidden: true
---
# 2022-01-18-Crosswise

{{< hint info >}}
# Information

**BlockNumber**:  **#14465249**

**Attacker**:  [0x748346113B6d61870Aa0961C6D3FB38742fc5089](https://bscscan.com/address/0x748346113b6d61870aa0961c6d3fb38742fc5089)

**Victims**:  
 
[CRSS-MasterChef 0x70873211CB64c1D4EC027Ea63A399A7d07c4085B](https://bscscan.com/address/0x70873211cb64c1d4ec027ea63a399a7d07c4085b#code)
{{< /hint >}}

- **vulnerable code**

(CRSS-MasterChef:L3199-3203)
```solidity
    function setTrustedForwarder(address _trustedForwarder) external {
        require(_trustedForwarder != address(0));
        trustedForwarder = _trustedForwarder;
        emit SetTrustedForwarder(_trustedForwarder);
    }
```

(CRSS-MasterChef:L2622-2625)
```solidity
    modifier onlyOwner() {
        require(owner() == _msgSender(), "caller is not the owner");
        _;
    }
```

(CRSS-MasterChef:L343-360)
```solidity
/**
     * return the sender of this call.
     * if the call came through our trusted forwarder, return the original sender.
     * otherwise, return `msg.sender`.
     * should be used in the contract anywhere instead of msg.sender
     */
    function _msgSender() internal override virtual view returns (address payable ret) {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
            // At this point we know that the sender is a trusted forwarder,
            // so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            assembly {
                ret := shr(96,calldataload(sub(calldatasize(),20)))
            }
        } else {
            return msg.sender;
        }
    }
```

(CRSS-MasterChef:L2637-2641)
```solidity
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
```

### **漏洞原因**
1. **Access Control**

漏洞很低级，对特殊变量没有做好权限控制，但是利用过程还是有些技巧的

---
**[Bug 0] 函数 `setTrustedForwarder` 没有做权限控制，任何人都可以调用该函数，传入一个非 0x0 的 `_trustedForwarder` 修改合约的 `trustedForwarder`**

---

`onlyOwner`会比较 _msgSender() 是不是 owner()，然而 _msgSender() 一定是真正的"msg sender"吗？

我们看到`_msgSender()`的实现上，并不总是返回msg.sender。**在某一条件下，会返回一个奇怪的汇编代码** (通过注释也能看出，**这段代码返回的是calldata中最后一个地址变量**)
`ret := shr(96,calldataload(sub(calldatasize(),20)))`

> **Note**: calldatasize 返回的是 msg.data 的字节长度，比如 call(addr1, addr2) 的 calldatasize = 4 + 20 + 20 = 44 bytes

calldataload(i) 返回从i开始的一个 uint256，即 msg.data[i:i+32] (这里的32是bytes=256bit), 所以 calldataload(sub(calldatasize(),20)) 返回的是 msg.data 的后 20bytes (一个address的长度)

以call(0x70873211cb64c1d4ec027ea63a399a7d07c4085b, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)为例: 返回的就是: res = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc200000000000...

接着 shr(96, res)，将 res 右移96位(12bytes)，变成 0x00000....C02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2


> **Note**: 关于Forwarder以及本合约中的_MsgSender实现，是为了兼容GSN(https://opengsn.org/) Token
> 
> GSN Token可以帮助用户，在没有原生代币 (native token) 的情况下发送交易。我们知道发送交易是需要Gas费的，一般Gas费都是用某个链的原生代币来支付 (比如: ETH)
> 
> 那为什么存在没有原生代币，还需要发交易的情况呢？这个如果有过经历的很容易理解。比如我刚入行区块链的时候，参加过一次Web3活动，刚好某个项目现场发放aridrop。于是，我第一次下载钱包 (入坑开始..)，生成地址，项目方把他们的代币转到我这个新开的地址
>
> 但是，由于新的账户，里面一个ETH都没有，这些代币完全没法交易或提走。这时，GSN作为一个第三方的服务，可以代替我支付Gas费，相应的，我用我空投得到代币支付给他。
> 
> 简单来说，我对我要做的事情进行签名，通过网络发送给GSN，GSN生成一笔交易，这笔交易内部完成了我的交易。问题来了，由于GSN代我发送的交易，msg.sender是GSN，如何将内部我的地址暴露出来作为这笔交易的"msg.sender"呢
> 
> 这时，支持GSN的合约，就会使用_msgSender这样的方法，对数据进行一次剥离，暴露出真实的msg.sender

这无疑为攻击者带来了希望，因为**calldata的后20字节是可以人为控制的**，那什么条件下才可以进入这一分支呢？
`msg.data.length >= 24 && isTrustedForwarder(msg.sender)` 第一个条件形同虚设，而第二个最重要的条件，由于 **[bug 0]** 的存在也变得无足轻重了

### **攻击流程**
**Step 1.** 调用 `setTrustedForwarder` 将合约的 `trustedForwarder` 设为自己

**Step 2.** 对于所有 `onlyOwner` 修饰符保护的函数，都可以通过在calldata中额外添加owner的地址来绕过 (_msgSender认为最后这个owner地址才是真正的msg.sender)

**Step 3.** 最简单的就是直接调用 `transferOwnership(hacker, owner)`, 将合约的owner修改为自己，就可以为所欲为了

### **漏洞复现**
见: https://github.com/3-F/defi-rekt/tree/master/pocs/2022-01-18-crosswise