#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
skill_root="$(cd -- "${script_dir}/.." && pwd)"
repo_root="$(cd -- "${skill_root}/../.." && pwd)"
references_dir="${skill_root}/references"
prompt_dir="${repo_root}/cigbutt"

latest_file="$(find "${prompt_dir}" -maxdepth 1 -type f -name '烟蒂股分析Prompt_v*.md' -printf '%f\n' \
  | sed -nE 's/^(.*_v([0-9]+(\.[0-9]+)*)\.md)$/\2\t\1/p' \
  | sort -t $'\t' -k1,1V \
  | tail -n1 \
  | cut -f2-)"

if [[ -z "${latest_file}" ]]; then
  echo "ERROR: no source prompt found in ${prompt_dir}" >&2
  exit 1
fi

required_files=(
  "${references_dir}/system_instructions.md"
  "${references_dir}/strategy_knowledge_base.md"
  "${references_dir}/execution_workflow.md"
  "${references_dir}/report_template.md"
  "${references_dir}/source_prompt_snapshot.md"
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

check_pattern "${references_dir}/system_instructions.md" "第一优先：MCP工具" "MCP-first rule"
check_pattern "${references_dir}/system_instructions.md" "Fact Check 22项必须逐项列出结果" "22-point fact-check requirement"

check_pattern "${references_dir}/strategy_knowledge_base.md" "## 一、核心思想" "core idea section"
check_pattern "${references_dir}/strategy_knowledge_base.md" "## 六、Fact Check 验证清单" "fact-check section"

check_pattern "${references_dir}/execution_workflow.md" "### Step 1: 数据提取" "workflow step 1"
check_pattern "${references_dir}/execution_workflow.md" "### Step 9: 生成报告" "workflow step 9"

check_pattern "${references_dir}/report_template.md" "## 报告输出模板" "report template heading"
check_pattern "${references_dir}/report_template.md" "## 十三、数据来源与免责声明" "report ending section"

check_pattern "${references_dir}/source_prompt_snapshot.md" "source_file: \`cigbutt/${latest_file}\`" "snapshot source pointer"

report_dir="${repo_root}/reports/cigbutt_reports/local"
if [[ ! -d "${report_dir}" ]]; then
  mkdir -p "${report_dir}"
fi

echo "Validation passed"
echo "Latest source: ${latest_file}"
echo "Report output directory: ${report_dir}"
