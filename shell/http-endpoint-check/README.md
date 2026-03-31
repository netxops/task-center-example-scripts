# HTTP Endpoint Check

对 HTTP/HTTPS 地址做可直接复用的巡检，适合做：

- 业务接口可达性检查
- 发布后的健康探测
- 证书与反向代理链路验证

## 用法

```bash
bash shell/http-endpoint-check/run.sh https://example.com/healthz
```

带条件检查：

```bash
EXPECTED_STATUS=200,204 BODY_CONTAINS=ok TIMEOUT_SECONDS=5 \
bash shell/http-endpoint-check/run.sh https://example.com/healthz
```

