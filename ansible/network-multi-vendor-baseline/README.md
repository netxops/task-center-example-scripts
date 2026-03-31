# Multi-Vendor Network Baseline

适合先做第一轮网络设备摸底，覆盖这些主线信息：

- 版本与设备型号
- 接口概要
- 邻居概要
- F5 的设备、VLAN、LTM 对象概要

## 支持范围

- Cisco IOS / IOS-XE
- Cisco NX-OS
- Huawei CloudEngine
- H3C / Comware
- F5 BIG-IP

## 推荐 inventory

直接参考：

- `ansible/network-vendor-inventory.example.ini`

## 本地语法检查

```bash
cd task-center-example-scripts
ansible-playbook --syntax-check ansible/network-multi-vendor-baseline/site.yml
```

## OneOps 建议

- `playbook_path`: `ansible/network-multi-vendor-baseline/site.yml`
- `app_type`: `ansible`
- `inventory_content`: 按你的设备清单填入，并补 `vendor_family`
