# Linux Deep Inspection

Ansible 版全面巡检模板，适合对一批 Linux 主机统一采集：

- 主机事实
- 文件系统与 inode
- 失败服务
- 监听端口
- 热点进程
- 最近错误日志

## 用法

```bash
ansible-playbook -i ansible/linux-deep-inspection/inventory.ini ansible/linux-deep-inspection/site.yml
```

可选参数：

```bash
ansible-playbook -i ansible/linux-deep-inspection/inventory.ini \
  ansible/linux-deep-inspection/site.yml \
  -e inspect_top_n=10 \
  -e inspect_journal_lines=120
```
