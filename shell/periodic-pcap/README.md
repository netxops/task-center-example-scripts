# Periodic Pcap

适合做周期性抓包、滚动保留最近若干个包文件。

## 用法

```bash
PCAP_INTERFACE=eth0 \
PCAP_OUTPUT_DIR=/data/pcap \
PCAP_FILE_PREFIX=wan \
PCAP_ROTATE_SECONDS=300 \
PCAP_ROTATE_COUNT=24 \
PCAP_FILTER="port 53 or port 443" \
bash shell/periodic-pcap/run.sh
```

说明：

- 依赖 `tcpdump`
- 通常需要 root 或具备抓包能力的权限
- 适合配合 OneOps 定时任务或长期运行任务使用
