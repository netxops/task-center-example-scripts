# OneOps Assets

这个目录不只是任务模板，而是一整套适合导入到 OneOps 的作业资产：

- 变量集
- 任务模板
- 定时任务

## 推荐导入顺序

1. 导入变量集
2. 导入任务模板
3. 导入定时任务

## 文件说明

- `variable-set-catalog.json`
  - 变量集清单
- `task-template-catalog.json`
  - 任务模板清单
- `scheduled-task-catalog.json`
  - 定时任务清单
- `import-variable-sets.sh`
  - 导入变量集
- `import-to-oneops.sh`
  - 导入任务模板
- `import-scheduled-tasks.sh`
  - 导入定时任务
- `bootstrap-oneops-assets.sh`
  - 按顺序导入变量集、模板、定时任务

## 当前定位

- 变量集
  - 适合沉淀 shell 环境变量与 ansible extra vars 的基础值
- 任务模板
  - 适合沉淀脚本入口、仓库、默认 arguments、变量集绑定
- 定时任务
  - 适合把高频快照、深度巡检、备份、健康检查等固定化

## 直接导入

```bash
cd task-center-example-scripts
bash templates/import-variable-sets.sh
bash templates/import-to-oneops.sh
DEFAULT_PROJECT_ID=ops-demo bash templates/import-scheduled-tasks.sh
```

## 一键导入

```bash
cd task-center-example-scripts
DEFAULT_PROJECT_ID=ops-demo bash templates/bootstrap-oneops-assets.sh
```

## 常用环境变量

```bash
API_BASE=http://127.0.0.1:8080/api/v1
AUTH_TOKEN=abc123
DRY_RUN=true

DEFAULT_PROJECT_ID=ops-demo
DEFAULT_FUNCTION_AREA=DefaultArea
DEFAULT_ENABLED=false
DEFAULT_RUN_ON_AGENT=true
DEFAULT_AGENT_CODE=agent-001
DEFAULT_CREDENTIAL_CODE=github-token
```

说明：

- `DEFAULT_PROJECT_ID` 是导入定时任务时的必填项。
- 如果设置了 `DEFAULT_RUN_ON_AGENT=true`，同时建议补 `DEFAULT_AGENT_CODE`。
- 任务模板导入脚本会自动按名字解析 `variable_set_name`，不需要手工查变量集 ID。
- 定时任务导入脚本会自动按名字解析 `template_name` 和 `variable_set_name`。
