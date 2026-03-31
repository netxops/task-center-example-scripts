# Network Batch Command

适合在多厂商设备上批量执行只读命令、临时排障命令和盘点命令。

## 常用变量

- `network_commands`
  - 直接传 JSON 数组，例如 `["show version","show ip interface brief"]`
- 如果没传 `network_commands`
  - 会自动回退到变量集里的各厂商默认命令

## 推荐 inventory

- `ansible/network-vendor-inventory.example.ini`

## 本地语法检查

```bash
cd task-center-example-scripts
ansible-playbook --syntax-check ansible/network-batch-command/site.yml
```
