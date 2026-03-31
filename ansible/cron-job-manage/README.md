# Cron Job Manage

Ansible 版 cron 管理模板，适合在一批 Linux 主机上统一开通、下线或查看计划任务。

## 新增或更新任务

```bash
ansible-playbook -i ansible/cron-job-manage/inventory.ini ansible/cron-job-manage/site.yml \
  -e cron_action=ensure \
  -e cron_name=ops-healthcheck \
  -e cron_user=root \
  -e cron_job="/usr/local/bin/healthcheck.sh >> /var/log/healthcheck.log 2>&1" \
  -e cron_minute="*/10"
```

## 删除任务

```bash
ansible-playbook -i ansible/cron-job-manage/inventory.ini ansible/cron-job-manage/site.yml \
  -e cron_action=absent \
  -e cron_name=ops-healthcheck
```

## 查看当前用户 cron

```bash
ansible-playbook -i ansible/cron-job-manage/inventory.ini ansible/cron-job-manage/site.yml \
  -e cron_action=list \
  -e cron_user=root
```
