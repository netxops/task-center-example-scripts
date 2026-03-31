# Network Snippet Deploy

适合做小步快跑的标准片段下发，例如：

- SNMP 联系人 / 位置
- NTP / Syslog 片段
- Banner / AAA 小改动
- F5 的 TMSH 命令或 SCF merge

## 常用变量

- `network_config_lines`
  - 适用于 Cisco / Huawei / H3C
- `f5_tmsh_commands`
  - 适用于 F5 BIG-IP
- `f5_merge_content`
  - 适用于 F5 SCF merge
- `network_backup_before_change`
- `network_save_when_done`

## 推荐 inventory

- `ansible/network-vendor-inventory.example.ini`

## 本地语法检查

```bash
cd task-center-example-scripts
ansible-playbook --syntax-check ansible/network-snippet-deploy/site.yml
```
