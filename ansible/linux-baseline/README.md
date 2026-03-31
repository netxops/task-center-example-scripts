# Linux Baseline

Ansible 版 Linux 巡检模板，输出主机事实、磁盘、CPU/内存热点进程，适合对一批服务器做统一摸底。

## 用法

```bash
ansible-playbook -i ansible/linux-baseline/inventory.ini ansible/linux-baseline/site.yml
```

自定义热点进程数量：

```bash
ansible-playbook -i ansible/linux-baseline/inventory.ini \
  ansible/linux-baseline/site.yml \
  -e baseline_top_n=10
```

