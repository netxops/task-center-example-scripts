# Batch File Transfer

适合做一对多文件分发，或从多台主机回收文件到当前执行节点。

## 推送到多台主机

```bash
TRANSFER_TARGETS=10.0.0.11,10.0.0.12 \
TRANSFER_SSH_USER=ops \
TRANSFER_DIRECTION=push \
bash shell/batch-file-transfer/run.sh ./package.tar.gz /tmp/releases
```

## 从多台主机回收文件

```bash
TRANSFER_TARGETS_FILE=targets.txt \
TRANSFER_SSH_USER=ops \
TRANSFER_DIRECTION=pull \
bash shell/batch-file-transfer/run.sh /var/log/nginx/access.log ./artifacts
```

说明：

- 默认优先使用 `rsync`，没有时退回 `scp`
- `pull` 模式会按主机名把文件放到目标目录下的子目录中
- 依赖当前执行节点已经具备到目标主机的 SSH 连通与认证
