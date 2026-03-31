# Cron Job Manage

适合用任务中心去开通、更新、下线一条定时任务，而不是手工上机器改 crontab。

## 管理当前用户 crontab

```bash
CRON_ACTION=ensure \
CRON_NAME=daily-healthcheck \
CRON_SCHEDULE="*/10 * * * *" \
CRON_COMMAND="/usr/local/bin/healthcheck.sh >> /tmp/healthcheck.log 2>&1" \
bash shell/cron-job-manage/run.sh
```

## 管理 `/etc/cron.d`

```bash
CRON_TARGET=cron.d \
CRON_ACTION=ensure \
CRON_NAME=nightly-backup \
CRON_RUN_AS=root \
CRON_SCHEDULE="0 2 * * *" \
CRON_COMMAND="/usr/local/bin/backup.sh >> /var/log/backup.log 2>&1" \
bash shell/cron-job-manage/run.sh
```
