#!/usr/bin/env bash

# Compare CSVs ignoring the order of rows
# NOTE: THIS IS NOT COMPLIANT WITH RFC-4180 https://datatracker.ietf.org/doc/html/rfc4180
# Meant only for use with "simple" csvs where the delimiter is never used within a column.
# Requires `gsort`

# Safties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Invalid parameters!"
  echo "Usage: $(basename "$0") <sort parameters> <file 1> <file 2>"
  exit 1
fi

tmpfile_left=$(mktemp /tmp/csv_diff.left.XXXXXX)
gsort $1 "$2" > "$tmpfile_left"

tmpfile_right=$(mktemp /tmp/csv_diff.right.XXXXXX)
gsort $1 "$3" > "$tmpfile_right"

function cleanup {
  rm "$tmpfile_left"
  rm "$tmpfile_right"
}
trap cleanup EXIT

diff -u "$tmpfile_left" "$tmpfile_right"
