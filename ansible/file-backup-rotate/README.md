# File Backup Rotate

Ansible 版批量文件备份模板，适合对一批主机上的关键目录和配置文件打包归档。

## 用法

```bash
ansible-playbook -i ansible/file-backup-rotate/inventory.ini ansible/file-backup-rotate/site.yml \
  -e backup_paths_csv="/etc/hosts,/etc/resolv.conf" \
  -e backup_root=/tmp/oneops-file-backups \
  -e backup_retention_count=10
```

如果需要把备份包回收到当前执行节点：

```bash
ansible-playbook -i ansible/file-backup-rotate/inventory.ini ansible/file-backup-rotate/site.yml \
  -e backup_paths_csv="/etc/hosts,/etc/resolv.conf" \
  -e backup_fetch_to_local=true \
  -e backup_local_staging=./artifacts
```
