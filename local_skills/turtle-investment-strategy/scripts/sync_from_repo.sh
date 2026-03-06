#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
skill_root="$(cd -- "${script_dir}/.." && pwd)"
repo_root="$(cd -- "${skill_root}/../.." && pwd)"
framework_root="${repo_root}/turtle_framework"
references_dir="${skill_root}/references"

if [[ ! -d "${framework_root}" ]]; then
  echo "Framework directory not found: ${framework_root}" >&2
  exit 1
fi

latest_dir_name="$({
  find "${framework_root}" -mindepth 1 -maxdepth 1 -type d -name '龟龟投资策略_v*' -printf '%f\n' \
    | sed -nE 's/^(龟龟投资策略_v([0-9]+(\.[0-9]+)*))$/\2\t\1/p'
} | sort -t $'\t' -k1,1V | tail -n1 | cut -f2-)"

if [[ -z "${latest_dir_name}" ]]; then
  echo "No turtle strategy version directory found in ${framework_root}" >&2
  exit 1
fi

latest_dir="${framework_root}/${latest_dir_name}"
version="$(printf '%s\n' "${latest_dir_name}" | sed -nE 's/^龟龟投资策略_v([0-9]+(\.[0-9]+)*)$/\1/p')"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

coordinator_src="${latest_dir}/coordinator.md"
phase1_src="${latest_dir}/phase1_数据采集.md"
phase2_src="${latest_dir}/phase2_PDF解析.md"
phase3_src="${latest_dir}/phase3_分析与报告.md"

for required in "${coordinator_src}" "${phase1_src}" "${phase2_src}" "${phase3_src}"; do
  if [[ ! -f "${required}" ]]; then
    echo "Missing required source file: ${required}" >&2
    exit 1
  fi
done

mkdir -p "${references_dir}"

write_header() {
  local target="$1"
  local title="$2"
  local source_file_rel="$3"
  {
    printf '# %s\n\n' "${title}"
    printf -- '- source_dir: `%s`\n' "turtle_framework/${latest_dir_name}"
    printf -- '- source_file: `%s`\n' "${source_file_rel}"
    printf -- '- source_version: `v%s`\n' "${version}"
    printf -- '- synced_at_utc: `%s`\n\n' "${timestamp}"
  } > "${target}"
}

coordinator_ref="${references_dir}/coordinator.md"
phase1_ref="${references_dir}/phase1_data_collection.md"
phase2_ref="${references_dir}/phase2_pdf_parsing.md"
phase3_ref="${references_dir}/phase3_analysis_and_report.md"
snapshot_ref="${references_dir}/source_bundle_snapshot.md"

write_header "${coordinator_ref}" "Coordinator (Synced)" "turtle_framework/${latest_dir_name}/coordinator.md"
cat "${coordinator_src}" >> "${coordinator_ref}"

write_header "${phase1_ref}" "Phase 1 Data Collection (Synced)" "turtle_framework/${latest_dir_name}/phase1_数据采集.md"
cat "${phase1_src}" >> "${phase1_ref}"

write_header "${phase2_ref}" "Phase 2 PDF Parsing (Synced)" "turtle_framework/${latest_dir_name}/phase2_PDF解析.md"
cat "${phase2_src}" >> "${phase2_ref}"

write_header "${phase3_ref}" "Phase 3 Analysis And Report (Synced)" "turtle_framework/${latest_dir_name}/phase3_分析与报告.md"
cat "${phase3_src}" >> "${phase3_ref}"

{
  printf '# Full Source Bundle Snapshot (Synced)\n\n'
  printf -- '- source_dir: `%s`\n' "turtle_framework/${latest_dir_name}"
  printf -- '- source_version: `v%s`\n' "${version}"
  printf -- '- synced_at_utc: `%s`\n\n' "${timestamp}"

  printf '## coordinator.md\n\n'
  cat "${coordinator_src}"
  printf '\n\n## phase1_数据采集.md\n\n'
  cat "${phase1_src}"
  printf '\n\n## phase2_PDF解析.md\n\n'
  cat "${phase2_src}"
  printf '\n\n## phase3_分析与报告.md\n\n'
  cat "${phase3_src}"
} > "${snapshot_ref}"

printf 'Synced from %s (v%s)\n' "${latest_dir_name}" "${version}"
printf 'Generated files:\n'
printf '  - %s\n' "${coordinator_ref}"
printf '  - %s\n' "${phase1_ref}"
printf '  - %s\n' "${phase2_ref}"
printf '  - %s\n' "${phase3_ref}"
printf '  - %s\n' "${snapshot_ref}"
