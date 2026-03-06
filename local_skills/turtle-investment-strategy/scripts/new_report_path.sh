#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
skill_root="$(cd -- "${script_dir}/.." && pwd)"
repo_root="$(cd -- "${skill_root}/../.." && pwd)"
out_base="${repo_root}/reports/turtle_reports/local"

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

mkdir -p "${out_base}"

date_tag="$(date +%Y%m%d)"
ticker_tag="$(sanitize "${ticker}")"
company_tag=""
if [[ -n "${company}" ]]; then
  company_tag="$(sanitize "${company}")_"
fi

run_base="${date_tag}_${company_tag}${ticker_tag}_turtle"
run_dir="${out_base}/${run_base}"
index=1
while [[ -e "${run_dir}" ]]; do
  run_dir="${out_base}/${run_base}_$(printf '%02d' "${index}")"
  index=$((index + 1))
done

mkdir -p "${run_dir}"
report_path="${run_dir}/${date_tag}_${company_tag}${ticker_tag}_turtle_report.md"
printf '%s\n' "${report_path}"
