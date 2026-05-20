#!/usr/bin/env bash

set -euo pipefail

INPUT_FILE="${1:-}"

if [[ -z "$INPUT_FILE" ]]; then
  echo "Usage: $0 <batch-file>"
  exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "File not found: $INPUT_FILE"
  exit 1
fi

current_file=""
buffer=""
inside_block=0
count=0

flush_note() {
  if [[ -n "$current_file" ]]; then
    mkdir -p "$(dirname "$current_file")"
    printf "%s\n" "$buffer" > "$current_file"
    echo "WRITE $current_file"
    count=$((count + 1))
  fi
}

while IFS= read -r line || [[ -n "$line" ]]; do

  if [[ "$line" =~ ^---\ NOTE\ START\ --- ]]; then
    inside_block=1
    current_file=""
    buffer=""
    continue
  fi

  if [[ "$inside_block" -eq 1 && "$line" =~ ^filename:\ (.*)$ ]]; then
    current_file="${BASH_REMATCH[1]}"
    continue
  fi

  if [[ "$inside_block" -eq 1 && "$line" =~ ^template:\  ]]; then
    continue
  fi

  if [[ "$inside_block" -eq 1 && "$line" =~ ^-------------------------$ ]]; then
    continue
  fi

  if [[ "$line" =~ ^---\ NOTE\ END\ --- ]]; then
    flush_note
    inside_block=0
    continue
  fi

  if [[ "$inside_block" -eq 1 ]]; then
    buffer+="$line"$'\n'
  fi

done < "$INPUT_FILE"

echo
echo "Done. Parsed $count note block(s)."