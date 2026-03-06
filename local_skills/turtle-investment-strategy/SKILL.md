---
name: turtle-investment-strategy
description: Use for turtle multi-phase stock analysis in this repository. It syncs to the latest turtle strategy version, enforces coordinator and phase rules, and writes outputs to reports/turtle_reports/local/.
---

# Turtle Investment Strategy

## When To Use
Use this skill when the task is to run the turtle strategy workflow end-to-end for a stock, including Phase 1 market data collection, Phase 2 annual report PDF parsing (when available), and Phase 3 analysis report generation.

## Required Inputs
- Stock identifier: ticker and/or company name.
- Optional holding channel (for tax and cash leakage handling).
- Optional annual-report PDF uploads.

If no valid latest annual-report PDF is available, run degraded mode exactly as the coordinator defines.

## Preflight (Always)
1. Sync references from the newest strategy folder:
```bash
bash local_skills/turtle-investment-strategy/scripts/sync_from_repo.sh
```
2. Validate integrity and output directory:
```bash
bash local_skills/turtle-investment-strategy/scripts/validate_sections.sh
```
3. Load references in this order:
- `references/coordinator.md`
- `references/phase1_data_collection.md`
- `references/phase2_pdf_parsing.md`
- `references/phase3_analysis_and_report.md`

Do not manually edit synced reference files. Re-run sync instead.

## Hard Rules (Non-Negotiable)
- Use only the latest synced strategy version from `turtle_framework/龟龟投资策略_vX.Y`.
- Follow coordinator scheduling exactly, including Step 0 PDF annual-report assurance before Phase 2.
- Keep strategy directory read-only. Never write into `turtle_framework/`.
- Write all outputs only under `reports/turtle_reports/local/`.
- Phase 1 and Phase 2 run in parallel only when `pdf_path` is valid; otherwise skip Phase 2 and use degraded mode.
- Phase 1 uses MCP first for structured market and financial data; web search is for required non-structured fields.
- Phase 2 must extract by checklist priority and mark missing fields explicitly.
- Phase 3 must not call external data sources; it must analyze only from phase outputs and strategy rules.
- Keep formulas and substituted values explicit in quantitative sections.
- Output the full Phase 3 report template without removing sections.

## Report Persistence
Always save outputs to `reports/turtle_reports/local/`.

Generate a collision-safe final report path:
```bash
bash local_skills/turtle-investment-strategy/scripts/new_report_path.sh --ticker "0700.HK" --company "Tencent"
```

Then use the parent directory as the run workspace:
- `data_pack_market.md`
- `data_pack_report.md` (if Phase 2 succeeds)
- final report markdown file

In the final user response, include the saved report file path.

## Upstream Update Workflow
After merging upstream changes:
1. Run `sync_from_repo.sh`.
2. Run `validate_sections.sh`.
3. If validation fails, update extraction checks in scripts (do not hand-edit synced references).

## Resource Map
- `scripts/sync_from_repo.sh`: detect latest `龟龟投资策略_vX.Y` and sync phase references.
- `scripts/validate_sections.sh`: validate mandatory sections and local output directory.
- `scripts/new_report_path.sh`: produce collision-safe run directory and final report path.
- `references/coordinator.md`: synced coordinator rules.
- `references/phase1_data_collection.md`: synced Phase 1 instructions.
- `references/phase2_pdf_parsing.md`: synced Phase 2 instructions.
- `references/phase3_analysis_and_report.md`: synced Phase 3 instructions.
- `references/source_bundle_snapshot.md`: full synced source bundle for traceability.
