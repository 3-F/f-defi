---
bookHidden: true
---
# 2022-02-20-Mox

{{< hint info >}}
# Information

**BlockNumber**:  **#14872887**

**Attacker**:

[0x9529da3B298ddcd5Fb69200Bd9Fd845b4b850096](https://bscscan.com/address/0x9529da3b298ddcd5fb69200bd9fd845b4b850096)

**Txs**:

[0x70c4d4a67b8b6ed0a4c79f81c14bcf939d5600fa9c6c7e339ffb2a1751cb6500](https://bscscan.com/tx/0x70c4d4a67b8b6ed0a4c79f81c14bcf939d5600fa9c6c7e339ffb2a1751cb6500) e.g.

**Victims**:

[MOX 0x1027Df21e422698d1b32de387dE9423930fAe5db](https://bscscan.com/address/0x1027df21e422698d1b32de387de9423930fae5db#code)


{{< /hint >}}

- **vulnerable code**

(BEP20MOX.sol:L1057-1063)
```solidity
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        return _transferByPaymentFee(sender, recipient, amount);
    }
```


(BEP20MOX.sol:L1065-1087)
```solidity
    function _transferByPaymentFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        address bridgePortAddress = address(
            0xe7463A410F94127B7f4D3e7B882b4BF5d2011eEd
        );

        if (sender == bridgePortAddress) {
            _mint(recipient, amount);
        } else if (recipient == bridgePortAddress) {
            _burn(sender, amount);
        } else if (sender.isContract() && fee > 0) {
            uint256 feeValue = (amount * fee) / 1e12;
            _transfer(sender, feeRecipient, feeValue);
            _transfer(sender, recipient, amount - feeValue);
        } else {
            _transfer(sender, recipient, amount);
        }

        return true;
    }
```


### **漏洞原因**


### **攻击流程**
