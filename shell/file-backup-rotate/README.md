# File Backup Rotate

适合把关键目录或配置文件打包备份，并自动清理旧归档。

## 用法

```bash
bash shell/file-backup-rotate/run.sh /etc /opt/app/config.yaml
```

常用环境变量：

```bash
BACKUP_ROOT=/data/backups
BACKUP_PREFIX=app-config
BACKUP_RETENTION_COUNT=14
BACKUP_EXCLUDE_FILE=/tmp/backup.exclude
```
