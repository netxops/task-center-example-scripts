# System Deep Inspection

更全面的 Linux 巡检脚本，适合做：

- 新纳管主机的首轮摸底
- 日常巡检任务
- 故障前后的快速对比采样

## 用法

```bash
bash shell/system-deep-inspection/run.sh
```

常用环境变量：

```bash
INSPECT_TOP_N=10
INSPECT_JOURNAL_LINES=120
SHOW_JOURNAL_ERRORS=true
SHOW_NETWORK_DETAILS=true
```
