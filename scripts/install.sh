#!/usr/bin/env bash
# Copy the security baseline files into another repository.
#
# Usage:
#   scripts/install.sh [--force] [--dry-run] <path-to-target-repo>
#
# Existing files are left alone unless --force is given; with --force the old
# file is kept next to the new one as <file>.bak.
set -euo pipefail

FILES=(
  ".github/workflows/security.yml"
  ".github/dependabot.yml"
  ".github/dependency-review-config.yml"
  ".github/codeql/codeql-config.yml"
  ".gitleaks.toml"
  "SECURITY.md"
)

usage() {
  sed -n '2,8s/^# \{0,1\}//p' "$0"
}

force=false
dry_run=false
target=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force)   force=true ;;
    -n|--dry-run) dry_run=true ;;
    -h|--help)    usage; exit 0 ;;
    -*)           echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [[ -n "${target}" ]]; then
        echo "Only one target directory may be given." >&2; exit 2
      fi
      target="$1"
      ;;
  esac
  shift
done

if [[ -z "${target}" ]]; then
  usage >&2
  exit 2
fi

kit_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ ! -d "${target}" ]]; then
  echo "Target directory does not exist: ${target}" >&2
  exit 1
fi
target="$(cd "${target}" && pwd)"

if [[ "${target}" == "${kit_root}" ]]; then
  echo "Target is the starter kit itself; choose another repository." >&2
  exit 1
fi
if ! git -C "${target}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Warning: ${target} is not a git repository." >&2
fi

installed=0
skipped=0
for f in "${FILES[@]}"; do
  src="${kit_root}/${f}"
  dst="${target}/${f}"
  if [[ ! -f "${src}" ]]; then
    echo "Missing from kit: ${f}" >&2
    exit 1
  fi
  if [[ -e "${dst}" ]]; then
    if cmp -s "${src}" "${dst}"; then
      echo "unchanged  ${f}"
      continue
    fi
    if [[ "${force}" != true ]]; then
      echo "skipped    ${f} (exists; use --force to replace)"
      skipped=$((skipped + 1))
      continue
    fi
    if [[ "${dry_run}" != true ]]; then
      cp -p "${dst}" "${dst}.bak"
    fi
    action="replaced  "
  else
    action="installed "
  fi
  if [[ "${dry_run}" != true ]]; then
    mkdir -p "$(dirname "${dst}")"
    cp "${src}" "${dst}"
  fi
  if [[ "${dry_run}" == true ]]; then
    echo "would be ${action% } ${f}"
  else
    echo "${action} ${f}"
  fi
  installed=$((installed + 1))
done

echo
if [[ "${dry_run}" == true ]]; then
  echo "Dry run: nothing was written."
fi
echo "${installed} file(s) installed, ${skipped} skipped."
cat <<'EOF'

Next steps:
  1. Edit SECURITY.md and replace the [BRACKETED] placeholders.
  2. Uncomment your package ecosystems in .github/dependabot.yml.
  3. Turn on the GitHub features listed in docs/setup-checklist.md of the
     starter kit (dependency graph, code scanning, private vulnerability
     reporting, Dependabot alerts and security updates).
  4. Commit, push, and make "Security gate" a required status check.
EOF
