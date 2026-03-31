# Network Interface And Neighbor Audit

适合做网络接口和链路状态巡检，重点关注：

- 接口 up/down 状态
- 三层接口概要
- LLDP 邻居
- F5 的接口、VLAN、Self IP、Trunk、Virtual Server

## 推荐 inventory

- `ansible/network-vendor-inventory.example.ini`

## 本地语法检查

```bash
cd task-center-example-scripts
ansible-playbook --syntax-check ansible/network-interface-neighbor-audit/site.yml
```
