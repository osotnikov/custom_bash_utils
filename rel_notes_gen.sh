#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./mr-commits-md.sh [base_ref] [target_ref]
# Example:
#   ./mr-commits-md.sh origin/master origin/develop > out.md

BASE_REF="${1:-origin/master}"
TARGET_REF="${2:-origin/develop}"
RANGE="${BASE_REF}..${TARGET_REF}"

# Keep refs fresh (safe to ignore failure if offline)
git --no-pager fetch --all --prune >/dev/null 2>&1 || true

# Newest first (default git log order)
git --no-pager log --format='%s%n%b%x00' "${RANGE}" |
awk -v RS='\0' '
  function trim(s) {
    gsub(/\r/, "", s)
    sub(/^\n+/, "", s)
    sub(/\n+$/, "", s)
    return s
  }

  {
    rec = trim($0)
    if (rec == "") next

    split(rec, lines, /\n/)
    subject = lines[1]

    body = ""
    for (i = 2; i <= length(lines); i++) {
      body = body (body == "" ? "" : "\n") lines[i]
    }
    body = trim(body)

    if (count++) printf "\n\n"
    printf "**%s**\n\n", subject
    if (body != "") printf "%s", body
  }
'