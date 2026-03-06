#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
skill_root="$(cd -- "${script_dir}/.." && pwd)"
repo_root="$(cd -- "${skill_root}/../.." && pwd)"
prompt_dir="${repo_root}/cigbutt"
references_dir="${skill_root}/references"

if [[ ! -d "${prompt_dir}" ]]; then
  echo "Prompt directory not found: ${prompt_dir}" >&2
  exit 1
fi

mapfile -t prompt_files < <(find "${prompt_dir}" -maxdepth 1 -type f -name '烟蒂股分析Prompt_v*.md' -printf '%f\n' | sort)
if [[ ${#prompt_files[@]} -eq 0 ]]; then
  echo "No prompt files found in ${prompt_dir}" >&2
  exit 1
fi

latest_file="$({
  for file in "${prompt_files[@]}"; do
    printf '%s\n' "${file}" | sed -nE 's/^(.*_v([0-9]+(\.[0-9]+)*)\.md)$/\2\t\1/p'
  done
} | sort -t $'\t' -k1,1V | tail -n1 | cut -f2-)"

if [[ -z "${latest_file}" ]]; then
  echo "Unable to determine latest prompt version" >&2
  exit 1
fi

latest_path="${prompt_dir}/${latest_file}"
version="$(printf '%s\n' "${latest_file}" | sed -nE 's/^.*_v([0-9]+(\.[0-9]+)*)\.md$/\1/p')"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

if ! rg -q '^<strategy_knowledge_base>$' "${latest_path}"; then
  echo "Missing <strategy_knowledge_base> marker in ${latest_file}" >&2
  exit 1
fi
if ! rg -q '^<execution_workflow>$' "${latest_path}"; then
  echo "Missing <execution_workflow> marker in ${latest_file}" >&2
  exit 1
fi
if ! rg -q '^<report_template>$' "${latest_path}"; then
  echo "Missing <report_template> marker in ${latest_file}" >&2
  exit 1
fi

mkdir -p "${references_dir}"

write_header() {
  local target="$1"
  local title="$2"
  {
    printf '# %s\n\n' "${title}"
    printf -- '- source_file: `%s`\n' "cigbutt/${latest_file}"
    printf -- '- source_version: `v%s`\n' "${version}"
    printf -- '- synced_at_utc: `%s`\n\n' "${timestamp}"
  } > "${target}"
}

system_file="${references_dir}/system_instructions.md"
strategy_file="${references_dir}/strategy_knowledge_base.md"
workflow_file="${references_dir}/execution_workflow.md"
report_file="${references_dir}/report_template.md"
snapshot_file="${references_dir}/source_prompt_snapshot.md"

write_header "${system_file}" "System Instructions (Synced)"
awk '/^<strategy_knowledge_base>$/ {exit} {print}' "${latest_path}" >> "${system_file}"

write_header "${strategy_file}" "Strategy Knowledge Base (Synced)"
awk '
  /^<strategy_knowledge_base>$/ {capture=1; next}
  /^<execution_workflow>$/ {capture=0}
  capture {print}
' "${latest_path}" >> "${strategy_file}"

write_header "${workflow_file}" "Execution Workflow (Synced)"
awk '
  /^<execution_workflow>$/ {capture=1; next}
  /^<report_template>$/ {capture=0}
  capture {print}
' "${latest_path}" >> "${workflow_file}"

write_header "${report_file}" "Report Template (Synced)"
awk '
  /^<report_template>$/ {capture=1; next}
  capture {print}
' "${latest_path}" >> "${report_file}"

write_header "${snapshot_file}" "Full Source Prompt Snapshot (Synced)"
cat "${latest_path}" >> "${snapshot_file}"

printf 'Synced from %s (v%s)\n' "${latest_file}" "${version}"
printf 'Generated files:\n'
printf '  - %s\n' "${system_file}"
printf '  - %s\n' "${strategy_file}"
printf '  - %s\n' "${workflow_file}"
printf '  - %s\n' "${report_file}"
printf '  - %s\n' "${snapshot_file}"
