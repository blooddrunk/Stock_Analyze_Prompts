#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
skill_root="$(cd -- "${script_dir}/.." && pwd)"
repo_root="$(cd -- "${skill_root}/../.." && pwd)"
out_dir="${repo_root}/reports/cigbutt_reports/local"

sanitize() {
  printf '%s' "$1" | tr '[:space:]' '_' | sed 's#[/\\]#_#g; s#[^[:alnum:]_.-]#_#g'
}

ticker="UNKNOWN"
company=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ticker)
      ticker="${2:-}"
      shift 2
      ;;
    --company)
      company="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

mkdir -p "${out_dir}"

date_tag="$(date +%Y%m%d)"
ticker_tag="$(sanitize "${ticker}")"
company_tag=""
if [[ -n "${company}" ]]; then
  company_tag="$(sanitize "${company}")_"
fi

base_name="${date_tag}_${company_tag}${ticker_tag}_cigbutt_report"
path="${out_dir}/${base_name}.md"
index=1
while [[ -e "${path}" ]]; do
  path="${out_dir}/${base_name}_$(printf '%02d' "${index}").md"
  index=$((index + 1))
done

printf '%s\n' "${path}"
