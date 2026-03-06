#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
skill_root="$(cd -- "${script_dir}/.." && pwd)"
repo_root="$(cd -- "${skill_root}/../.." && pwd)"
framework_root="${repo_root}/turtle_framework"
references_dir="${skill_root}/references"

latest_dir_name="$({
  find "${framework_root}" -mindepth 1 -maxdepth 1 -type d -name '龟龟投资策略_v*' -printf '%f\n' \
    | sed -nE 's/^(龟龟投资策略_v([0-9]+(\.[0-9]+)*))$/\2\t\1/p'
} | sort -t $'\t' -k1,1V | tail -n1 | cut -f2-)"

if [[ -z "${latest_dir_name}" ]]; then
  echo "ERROR: no strategy version directory found in ${framework_root}" >&2
  exit 1
fi

required_files=(
  "${references_dir}/coordinator.md"
  "${references_dir}/phase1_data_collection.md"
  "${references_dir}/phase2_pdf_parsing.md"
  "${references_dir}/phase3_analysis_and_report.md"
  "${references_dir}/source_bundle_snapshot.md"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "${file}" ]]; then
    echo "ERROR: missing reference file ${file}" >&2
    exit 1
  fi
  if [[ ! -s "${file}" ]]; then
    echo "ERROR: empty reference file ${file}" >&2
    exit 1
  fi
done

check_pattern() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if ! rg -q --fixed-strings "${pattern}" "${file}"; then
    echo "ERROR: ${label} not found in ${file}" >&2
    exit 1
  fi
}

check_pattern "${references_dir}/coordinator.md" "## 阶段调度" "coordinator scheduling"
check_pattern "${references_dir}/coordinator.md" "### Step 0：PDF 年报确保" "coordinator step 0"
check_pattern "${references_dir}/coordinator.md" "## 策略目录只读规则" "read-only strategy rule"

check_pattern "${references_dir}/phase1_data_collection.md" "### 第一部分：基础市场数据（MCP 工具）" "phase1 MCP section"
check_pattern "${references_dir}/phase1_data_collection.md" "### 第十部分：MD&A 摘要（WebSearch）" "phase1 web section"
check_pattern "${references_dir}/phase1_data_collection.md" "## 输出格式" "phase1 output format"

check_pattern "${references_dir}/phase2_pdf_parsing.md" "## 提取清单" "phase2 checklist"
check_pattern "${references_dir}/phase2_pdf_parsing.md" "#### P1：母公司单体资产负债表" "phase2 P1"
check_pattern "${references_dir}/phase2_pdf_parsing.md" "#### P19：合同负债/预收款明细" "phase2 P19"

check_pattern "${references_dir}/phase3_analysis_and_report.md" "## 执行工作流" "phase3 workflow"
check_pattern "${references_dir}/phase3_analysis_and_report.md" "### Step 7: 生成报告" "phase3 step 7"
check_pattern "${references_dir}/phase3_analysis_and_report.md" "## 报告输出模板" "phase3 report template"
check_pattern "${references_dir}/phase3_analysis_and_report.md" "## 九、数据来源与免责声明" "phase3 ending section"

check_pattern "${references_dir}/source_bundle_snapshot.md" "source_dir: \`turtle_framework/${latest_dir_name}\`" "snapshot source pointer"

report_dir="${repo_root}/reports/turtle_reports/local"
if [[ ! -d "${report_dir}" ]]; then
  mkdir -p "${report_dir}"
fi

echo "Validation passed"
echo "Latest source: ${latest_dir_name}"
echo "Report output directory: ${report_dir}"
