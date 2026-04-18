#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/split-obsidian-batch.sh <batch-file> [vault-root]

Examples:
  ./scripts/split-obsidian-batch.sh inbox/chatgpt-grafana-sre-interview-prep-batch.md
  ./scripts/split-obsidian-batch.sh inbox/chatgpt-grafana-sre-interview-prep-batch.md .

Environment:
  OPEN_INDEX=1   Open first index note in Obsidian after splitting (default: 1)
  OVERWRITE=1    Overwrite existing notes (default: 1)
  DEBUG=0        Print parser debug info (default: 0)
EOF
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

BATCH_FILE="$1"
VAULT_ROOT="${2:-.}"
OPEN_INDEX="${OPEN_INDEX:-1}"
OVERWRITE="${OVERWRITE:-1}"
DEBUG="${DEBUG:-0}"

if [[ ! -f "$BATCH_FILE" ]]; then
  echo "Error: batch file not found: $BATCH_FILE" >&2
  exit 1
fi

if [[ ! -d "$VAULT_ROOT" ]]; then
  echo "Error: vault root not found: $VAULT_ROOT" >&2
  exit 1
fi

BATCH_FILE="$(cd "$(dirname "$BATCH_FILE")" && pwd)/$(basename "$BATCH_FILE")"
VAULT_ROOT="$(cd "$VAULT_ROOT" && pwd)"

have_obsidian_cli=0
if command -v obsidian >/dev/null 2>&1; then
  have_obsidian_cli=1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

NOTES_INDEX="$TMP_DIR/notes-index.tsv"

TMP_DIR="$TMP_DIR" awk -v debug="$DEBUG" '
function trim(s) {
  sub(/^[[:space:]]+/, "", s)
  sub(/[[:space:]]+$/, "", s)
  return s
}

function is_start(s) {
  s = trim(s)
  return (s ~ /NOTE START/)
}

function is_end(s) {
  s = trim(s)
  return (s ~ /NOTE END/)
}

function flush_note(    out) {
  if (!in_note) {
    return
  }

  if (filename == "") {
    if (debug) {
      print "DEBUG skipping block with no filename" > "/dev/stderr"
    }
    in_note = 0
    capture_content = 0
    filename = ""
    template = ""
    content = ""
    return
  }

  note_count++
  out = sprintf("%s/note_%04d.md", ENVIRON["TMP_DIR"], note_count)
  printf "%s", content > out
  close(out)

  print filename "\t" template "\t" out
  if (debug) {
    print "DEBUG flushed " filename " bytes=" length(content) > "/dev/stderr"
  }

  in_note = 0
  capture_content = 0
  filename = ""
  template = ""
  content = ""
}

BEGIN {
  in_note = 0
  capture_content = 0
  note_count = 0
  filename = ""
  template = ""
  content = ""
}

{
  line = $0
  sub(/\r$/, "", line)
  stripped = trim(line)

  if (stripped == "```" || stripped == "```markdown" || stripped == "```md") {
    next
  }

  if (is_start(stripped)) {
    flush_note()
    in_note = 1
    capture_content = 0
    filename = ""
    template = ""
    content = ""
    if (debug) {
      print "DEBUG start @" NR ": " stripped > "/dev/stderr"
    }
    next
  }

  if (!in_note) {
    next
  }

  if (stripped ~ /^filename:[[:space:]]*/) {
    filename = stripped
    sub(/^filename:[[:space:]]*/, "", filename)
    filename = trim(filename)
    if (debug) {
      print "DEBUG filename @" NR ": " filename > "/dev/stderr"
    }
    next
  }

  if (stripped ~ /^template:[[:space:]]*/) {
    template = stripped
    sub(/^template:[[:space:]]*/, "", template)
    template = trim(template)
    capture_content = 1
    if (debug) {
      print "DEBUG template @" NR ": " template > "/dev/stderr"
    }
    next
  }

  if (is_end(stripped)) {
    if (debug) {
      print "DEBUG end @" NR ": " stripped > "/dev/stderr"
    }
    flush_note()
    next
  }

  if (capture_content) {
    # Skip the dashed separator if present, but do not require it.
    if (stripped == "-------------------------") {
      next
    }
    content = content line "\n"
  }
}

END {
  flush_note()
}
' "$BATCH_FILE" > "$NOTES_INDEX"

if [[ ! -s "$NOTES_INDEX" ]]; then
  echo
  echo "Done. Parsed 0 note block(s)."
  exit 0
fi

write_note() {
  local rel_path="$1"
  local content_file="$2"
  local out_path="$VAULT_ROOT/$rel_path"

  mkdir -p "$(dirname "$out_path")"

  if [[ -e "$out_path" && "$OVERWRITE" != "1" ]]; then
    echo "SKIP  $rel_path (already exists)"
    return 0
  fi

  cp "$content_file" "$out_path"
  echo "WRITE $rel_path"
}

open_note_in_obsidian() {
  local rel_path="$1"

  if [[ "$have_obsidian_cli" -ne 1 ]]; then
    return 0
  fi

  if [[ -n "${OBSIDIAN_VAULT_NAME:-}" ]]; then
    obsidian vault="$OBSIDIAN_VAULT_NAME" open path="$rel_path" >/dev/null 2>&1 || true
  else
    (
      cd "$VAULT_ROOT"
      obsidian open path="$rel_path" >/dev/null 2>&1 || true
    )
  fi
}

note_count=0
first_index_note=""

while IFS=$'\t' read -r filename template content_file; do
  [[ -z "$filename" ]] && continue

  write_note "$filename" "$content_file"
  note_count=$((note_count + 1))

  if [[ -z "$first_index_note" && "$filename" == sre/indexes/* ]]; then
    first_index_note="$filename"
  fi
done < "$NOTES_INDEX"

echo
echo "Done. Parsed $note_count note block(s)."

if [[ "$OPEN_INDEX" == "1" && -n "$first_index_note" ]]; then
  open_note_in_obsidian "$first_index_note"
  echo "Opened index note: $first_index_note"
fi