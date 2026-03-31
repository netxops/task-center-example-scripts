# Network Configuration Backup

适合做日常备份、变更前快照和故障后留档。

## 说明

- Cisco IOS / NX-OS / Huawei CE：使用厂商模块直接生成配置备份文件
- H3C：通过通用 CLI 抓取 `display current-configuration`
- F5：抓取逻辑对象快照，默认不是 UCS 二进制归档

## 推荐 inventory

- `ansible/network-vendor-inventory.example.ini`

## 常用变量

- `network_backup_dir`
- `network_backup_tag`
- `f5_backup_commands`

## 本地语法检查

```bash
cd task-center-example-scripts
ansible-playbook --syntax-check ansible/network-config-backup/site.yml
```
