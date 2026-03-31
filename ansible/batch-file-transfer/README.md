# Batch File Transfer

Ansible 版批量文件交换模板。

- `push`: 从当前执行节点把文件或目录下发到所有目标主机
- `pull`: 把目标主机上的文件或目录打包后回收到当前执行节点

## 推送示例

```bash
ansible-playbook -i ansible/batch-file-transfer/inventory.ini ansible/batch-file-transfer/site.yml \
  -e transfer_direction=push \
  -e transfer_items_csv="shell/system-quick-snapshot/run.sh,README.md" \
  -e transfer_dest_dir=/tmp/oneops-transfer
```

## 回收示例

```bash
ansible-playbook -i ansible/batch-file-transfer/inventory.ini ansible/batch-file-transfer/site.yml \
  -e transfer_direction=pull \
  -e transfer_items_csv="/var/log/messages,/etc/hosts" \
  -e transfer_local_staging=./artifacts
```
