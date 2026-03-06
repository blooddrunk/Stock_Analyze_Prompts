# Cigbutt Static Value Skill 使用与开发文档

## 1. 目标与范围
本 Skill 用于在本仓库内执行「静态价值型烟蒂股量化分析」，并严格遵循最新 `cigbutt/烟蒂股分析Prompt_vX.Y.md` 的规则。

默认行为：
- 自动同步到最新版本 Prompt（当前为 v1.8）
- 严格执行 MCP-first、9-step workflow、Fact Check 22 项
- 报告自动落盘到 `reports/cigbutt_reports/local/`，避免与 upstream 报告冲突

## 2. 目录结构

```text
local_skills/cigbutt-static-value/
├── SKILL.md
├── agents/openai.yaml
├── scripts/
│   ├── sync_from_repo.sh
│   ├── validate_sections.sh
│   └── new_report_path.sh
└── references/
    ├── system_instructions.md
    ├── strategy_knowledge_base.md
    ├── execution_workflow.md
    ├── report_template.md
    └── source_prompt_snapshot.md
```

## 3. 一次性安装（软链接）

```bash
mkdir -p "${CODEX_HOME}/skills"
ln -sfn \
  "/home/jelinenaro/code/finance/Stock_Analyze_Prompts/local_skills/cigbutt-static-value" \
  "${CODEX_HOME}/skills/cigbutt-static-value"
```

验证：

```bash
ls -ld "${CODEX_HOME}/skills/cigbutt-static-value"
readlink -f "${CODEX_HOME}/skills/cigbutt-static-value"
```

## 4. 日常使用流程

每次分析前，先执行：

```bash
bash local_skills/cigbutt-static-value/scripts/sync_from_repo.sh
bash local_skills/cigbutt-static-value/scripts/validate_sections.sh
```

然后在对话中使用 Skill，例如：

```text
Use $cigbutt-static-value to analyze 0700.HK with the uploaded two periods of reports and save output to local report directory.
```

## 5. 报告落盘与命名规则
Skill 默认落盘目录：

- `reports/cigbutt_reports/local/`

生成不冲突路径：

```bash
bash local_skills/cigbutt-static-value/scripts/new_report_path.sh \
  --ticker "0700.HK" \
  --company "Tencent"
```

命名格式：
- `{YYYYMMDD}_{Company}_{Ticker}_cigbutt_report.md`
- 若重名自动追加 `_01`, `_02`...

## 6. 与 upstream 同步的维护流程
每次 `git merge upstream/main` 后执行：

1. `bash local_skills/cigbutt-static-value/scripts/sync_from_repo.sh`
2. `bash local_skills/cigbutt-static-value/scripts/validate_sections.sh`
3. 提交 `references/` 的同步结果（若有变更）

设计原则：
- 不手工改 `references/*.md`
- 只改 `scripts/*.sh` 与 `SKILL.md`
- 通过脚本重建 references，避免版本漂移

## 7. 开发说明

### 7.1 `sync_from_repo.sh`
职责：
- 从 `cigbutt/` 自动找最新 `烟蒂股分析Prompt_v*.md`
- 按分隔标记切分成 5 份 references
- 写入 source/version/synced_at 元数据

关键标记：
- `<strategy_knowledge_base>`
- `<execution_workflow>`
- `<report_template>`

若 upstream 修改了标记名，需要同步更新该脚本的提取逻辑。

### 7.2 `validate_sections.sh`
职责：
- 校验 references 文件存在且非空
- 校验关键规则语句仍在（MCP-first、22项检查、Step1~Step9、模板尾章）
- 确保 `reports/cigbutt_reports/local/` 存在

推荐在 CI 或本地 pre-commit 执行。

### 7.3 `new_report_path.sh`
职责：
- 生成安全文件名
- 避免覆盖历史分析报告

## 8. 常见问题

### 8.1 同步失败：找不到 Prompt 文件
检查目录：
- `cigbutt/` 下是否存在 `烟蒂股分析Prompt_v*.md`

### 8.2 校验失败：缺少关键章节
通常是 upstream 结构变化导致。
处理：
- 查看最新 Prompt 的章节标记
- 更新 `sync_from_repo.sh` 的切分规则
- 重新 `sync + validate`

### 8.3 报告未落盘
检查：
- 是否使用 `new_report_path.sh` 生成路径
- 写入目录是否为 `reports/cigbutt_reports/local/`

## 9. 当前基线
- Skill 名称：`cigbutt-static-value`
- 当前同步源：`cigbutt/烟蒂股分析Prompt_v1.8.md`
- 文档更新时间：2026-03-06
