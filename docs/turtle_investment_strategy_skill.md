# Turtle Investment Strategy Skill 使用与开发文档

## 1. 目标与范围
本 Skill 用于在本仓库内执行「龟龟投资策略」多阶段分析流程，并严格遵循最新 `turtle_framework/龟龟投资策略_vX.Y/` 的阶段化规则。

默认行为：
- 自动同步到最新版本策略目录（当前为 v0.15）
- 严格执行 Coordinator 调度 + Phase 1/2/3 约束
- 输出自动落盘到 `reports/turtle_reports/local/`，避免与 upstream 报告冲突

## 2. 目录结构

```text
local_skills/turtle-investment-strategy/
├── SKILL.md
├── agents/openai.yaml
├── scripts/
│   ├── sync_from_repo.sh
│   ├── validate_sections.sh
│   └── new_report_path.sh
└── references/
    ├── coordinator.md
    ├── phase1_data_collection.md
    ├── phase2_pdf_parsing.md
    ├── phase3_analysis_and_report.md
    └── source_bundle_snapshot.md
```

## 3. 一次性安装（软链接）

```bash
mkdir -p "${CODEX_HOME}/skills"
ln -sfn \
  "/home/jelinenaro/code/finance/Stock_Analyze_Prompts/local_skills/turtle-investment-strategy" \
  "${CODEX_HOME}/skills/turtle-investment-strategy"
```

验证：

```bash
ls -ld "${CODEX_HOME}/skills/turtle-investment-strategy"
readlink -f "${CODEX_HOME}/skills/turtle-investment-strategy"
```

## 4. 日常使用流程

每次分析前，先执行：

```bash
bash local_skills/turtle-investment-strategy/scripts/sync_from_repo.sh
bash local_skills/turtle-investment-strategy/scripts/validate_sections.sh
```

然后在对话中使用 Skill，例如：

```text
Use $turtle-investment-strategy to analyze 0001.HK with holding channel 港股通 and save outputs to local turtle reports.
```

## 5. 输出落盘与命名规则

Skill 默认根目录：
- `reports/turtle_reports/local/`

生成不冲突的最终报告路径（并自动创建 run 目录）：

```bash
bash local_skills/turtle-investment-strategy/scripts/new_report_path.sh \
  --ticker "0001.HK" \
  --company "长和"
```

脚本会生成：
- 独立 run 目录：`{YYYYMMDD}_{Company}_{Ticker}_turtle[_NN]/`
- 最终报告：`{YYYYMMDD}_{Company}_{Ticker}_turtle_report.md`

同一 run 目录下建议固定输出：
- `data_pack_market.md`
- `data_pack_report.md`（若 Phase 2 成功）
- 最终报告 markdown

## 6. 与 upstream 同步的维护流程
每次 `git merge upstream/main` 后执行：

1. `bash local_skills/turtle-investment-strategy/scripts/sync_from_repo.sh`
2. `bash local_skills/turtle-investment-strategy/scripts/validate_sections.sh`
3. 提交 `references/` 的同步结果（若有变更）

设计原则：
- 不手工改 `references/*.md`
- 只改 `scripts/*.sh` 与 `SKILL.md`
- 通过脚本重建 references，避免版本漂移

## 7. 开发说明

### 7.1 `sync_from_repo.sh`
职责：
- 自动识别顶层最新 `龟龟投资策略_vX.Y` 目录
- 同步 4 个阶段文件到 references
- 生成全集快照 `source_bundle_snapshot.md`

### 7.2 `validate_sections.sh`
职责：
- 校验 references 文件存在且非空
- 校验关键章节仍在（调度、Step 0、MCP 段、P1/P19、Step 7、报告模板尾章）
- 确保 `reports/turtle_reports/local/` 存在

### 7.3 `new_report_path.sh`
职责：
- 生成不冲突 run 目录与最终报告路径
- 避免覆盖历史数据包与历史报告

## 8. 常见问题

### 8.1 同步失败：找不到版本目录
检查目录：
- `turtle_framework/` 顶层是否存在 `龟龟投资策略_v*.*/`

### 8.2 校验失败：缺少关键章节
通常是 upstream 改了章节标题或结构。
处理：
- 查看最新版本文件标题
- 更新 `validate_sections.sh` 中的检查关键字
- 重新 `sync + validate`

### 8.3 没有 PDF 年报时怎么处理
按 Coordinator 降级流程执行：
- 仅 Phase 1
- 跳过 Phase 2
- Phase 3 基于可得数据输出并标注不确定性

## 9. 当前基线
- Skill 名称：`turtle-investment-strategy`
- 当前同步源：`turtle_framework/龟龟投资策略_v0.15/`
- 文档更新时间：2026-03-06
