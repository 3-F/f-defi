---
bookHidden: true
---
# 2022-01-18-anyswap

{{< hint info >}}

## Information
**Attacker**:  [0x4986e9017eA60e7AfCd10D844F85c80912C3863c](https://etherscan.io/address/0x4986e9017eA60e7AfCd10D844F85c80912C3863c)

**BlockNumber**:  #14028474

**Victims**:  
 
[AnySwapRouterV4 0x6b7a87899490EcE95443e979cA9485CBE7E71522](https://etherscan.io/address/0x6b7a87899490ece95443e979ca9485cbe7e71522#code)
{{< /hint >}}

- vulnerable code (AnySwapRouterV4:L265-281)
```solidity
    function anySwapOutUnderlyingWithPermit(
        address from,
        address token,
        address to,
        uint amount,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint toChainID
    ) external {
        address _underlying = AnyswapV1ERC20(token).underlying();
        IERC20(_underlying).permit(from, address(this), amount, deadline, v, r, s);
        TransferHelper.safeTransferFrom(_underlying, from, token, amount);
        AnyswapV1ERC20(token).depositVault(amount, from);
        _anySwapOut(from, token, to, amount, toChainID);
    }
```

```solidity
    function _anySwapOut(address from, address token, address to, uint amount, uint toChainID) internal {
        AnyswapV1ERC20(token).burn(from, amount);
        emit LogAnySwapOut(token, from, to, amount, cID(), toChainID);
    }
```

### **漏洞原因**
1. 不可信参数的外部调用

`anySwapOutUnderlyingWithPermit`允许用户传入参数token，并在函数内外部调用该地址 (underlying(), depositVault(), burn())，这意味着所有token的外部调用都是用户可控的

2. 利用fallback函数绕过检查 (如permit)

调用合约不存在的方法时，会落入fallback函数

permit函数的功能是检查签名的有效性(比如: approve等), 由于underlying是token.underlying()的返回值，是可以控制的 (token可以是攻击者创建的恶意合约)
所以，当underlying的permit可以被绕过，并且用户approve过一定额度给Anyswap，攻击者便可以将这些用户授权Anyswap的underlying全部转入token这个恶意合约

以WETH为例，其fallback函数实现如下：
```solidity
    function() public payable {
        deposit();
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }
```
由于WETH不存在permit方法，当对WETH调用permit时，会执行fallback函数，相当于什么也没有做，并不会revert

### **攻击流程**

Step 1. 寻找那些可以绕过permit的token (如: WETH) 以及Anyswap对这些token实际控制的数量 (=min(用户授权给Anyswap的数量, 用户拥有的token数量))

Step 2. 创建恶意合约fake_token，需要实现 underlying(), depositVault(), burn() 方法，其中underlying为可以绕过permit的token，其他两个方法可以为空

Step 3. 不断调用AnyswapRouterV4的`anySwapOutUnderlyingWithPermit`，传入参数为：from=victim，token=fake_token, amount=min(allowance(victim, anyswap), underlying.balanceOf(victim))

Step 4. 将fake_token中捞到的钱取走，跑路

### **漏洞利用**
见: https://github.com/3-F/defi-rekt/tree/master/pocs/2022-01-18-anyswap