---
name: cigbutt-static-value
description: Use for static-value cigar-butt stock analysis in this repository. It syncs to the latest cigbutt prompt version, enforces v1.8 discipline (MCP-first data, 9-step workflow, full 22-point fact check), and saves reports to reports/cigbutt_reports/local/.
---

# Cigbutt Static Value

## When To Use
Use this skill when the task is to analyze a stock with the static-value cigar-butt framework from this repository, generate the full Markdown report, and persist it under `reports/cigbutt_reports/local/`.

## Required Inputs
- Stock identifier: code and/or company name.
- At least two financial reporting periods (PDFs or structured text).

If fewer than two periods are available, continue with strict missing-data labels and explicitly lower confidence.

## Preflight (Always)
1. Sync references from the newest upstream prompt file:
```bash
bash local_skills/cigbutt-static-value/scripts/sync_from_repo.sh
```
2. Validate section integrity and output directory:
```bash
bash local_skills/cigbutt-static-value/scripts/validate_sections.sh
```
3. Load references in this order:
- `references/system_instructions.md`
- `references/execution_workflow.md`
- `references/report_template.md`
- `references/strategy_knowledge_base.md` (load fully before quantitative and subtype decisions)

Do not manually edit synced reference files. Re-run sync instead.

## Hard Rules (Non-Negotiable)
- Use the latest synced prompt content only (auto-selected by version in `sync_from_repo.sh`).
- Enforce MCP-first live data collection; use web search only when MCP is unavailable, missing a field, or clearly wrong.
- Do not bypass MCP when MCP can provide the required field.
- Follow all 9 execution steps in order.
- Output the full report template without dropping sections.
- Show formulas, substituted values, and final numeric results for all quantitative calculations.
- Mark missing fields explicitly; never estimate unknown data.
- Run and report all 22 fact-check items, and label every warning as `Data` or `Risk`.
- Keep report language Chinese-first with finance terms in English where appropriate.

## Report Persistence
Always save the generated report to `reports/cigbutt_reports/local/`.

Generate a non-conflicting path:
```bash
bash local_skills/cigbutt-static-value/scripts/new_report_path.sh --ticker "0700.HK" --company "Tencent"
```

Then write the report to that path. In the final user response, include the saved file path.

## Upstream Update Workflow
After merging upstream changes:
1. Run `sync_from_repo.sh` to refresh references from latest `cigbutt/烟蒂股分析Prompt_vX.Y.md`.
2. Run `validate_sections.sh`.
3. If validation fails, fix source marker compatibility in the sync script (do not hand-edit synced reference files).

## Resource Map
- `scripts/sync_from_repo.sh`: detect latest prompt version and split synced references.
- `scripts/validate_sections.sh`: verify mandatory sections and v1.8 critical constraints.
- `scripts/new_report_path.sh`: produce collision-safe local report paths.
- `references/source_prompt_snapshot.md`: full synced source for traceability.
- `references/system_instructions.md`: synced system rules, including MCP-first constraints.
- `references/strategy_knowledge_base.md`: synced strategy definitions and scoring.
- `references/execution_workflow.md`: synced 9-step workflow.
- `references/report_template.md`: synced full report template.
