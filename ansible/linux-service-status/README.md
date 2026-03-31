# Linux Service Status

检查 systemd 服务状态，适合做：

- 关键服务上线后核对
- 故障排查时快速确认运行态
- 作为定时巡检模板检查 sshd / docker / nginx / kubelet 等

## 用法

```bash
ansible-playbook -i ansible/linux-service-status/inventory.ini \
  ansible/linux-service-status/site.yml \
  -e service_name=sshd
```

一次检查多个服务：

```bash
ansible-playbook -i ansible/linux-service-status/inventory.ini \
  ansible/linux-service-status/site.yml \
  -e service_name=sshd \
  -e service_names_csv=docker,chronyd
```

