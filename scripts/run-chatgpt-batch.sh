#!/usr/bin/env bash
set -euo pipefail

RUN_ID="${1:?Usage: $0 <run-id> <batch-file> <master-skill> <input-prompt>}"
BATCH_FILE="${2:?Missing batch file}"
MASTER_SKILL="${3:?Missing master-skill file}"
INPUT_PROMPT="${4:?Missing input prompt file}"

RUN_DIR="ops/runs/$RUN_ID"
INPUTS_DIR="$RUN_DIR/inputs"
OUTPUTS_FILE="$RUN_DIR/notes-created.md"
MANIFEST="$RUN_DIR/run-manifest.md"
LOG="$RUN_DIR/run.log"

mkdir -p "$INPUTS_DIR"

echo "$(date -Is) RUN_CREATED $RUN_ID" > "$LOG"

cp "$MASTER_SKILL" "$INPUTS_DIR/"
cp "$INPUT_PROMPT" "$INPUTS_DIR/"
cp "$BATCH_FILE" "$RUN_DIR/batch.md"

echo "$(date -Is) INPUTS_COPIED" >> "$LOG"
echo "$(date -Is) BATCH_COPIED $RUN_DIR/batch.md" >> "$LOG"

NOTE_COUNT=$(grep -c "^--- NOTE START ---" "$RUN_DIR/batch.md" || true)

echo "$(date -Is) NOTE_BLOCK_COUNT $NOTE_COUNT" >> "$LOG"

if [[ "$NOTE_COUNT" -lt 2 ]]; then
  echo "ERROR: Batch appears incomplete. Found only $NOTE_COUNT NOTE block(s)."
  echo "$(date -Is) RUN_FAILED incomplete_batch" >> "$LOG"
  exit 1
fi

echo "# Notes Created" > "$OUTPUTS_FILE"

./split-obsidian-batch.sh "$RUN_DIR/batch.md" | tee -a "$LOG" | while read -r line; do
  if [[ "$line" == WRITE* ]]; then
    path="${line#WRITE }"
    echo "- $path" >> "$OUTPUTS_FILE"
  fi
done

cat > "$MANIFEST" <<EOF
# Run Manifest

## Run ID
$RUN_ID

## Status
completed

## Inputs
- $(basename "$MASTER_SKILL")
- $(basename "$INPUT_PROMPT")

## Input Copies
- $INPUTS_DIR/$(basename "$MASTER_SKILL")
- $INPUTS_DIR/$(basename "$INPUT_PROMPT")

## Batch
- $RUN_DIR/batch.md

## Note Block Count
$NOTE_COUNT

## Split Script
- scripts/split-obsidian-batch.sh

## Generated Notes
$(cat "$OUTPUTS_FILE")

## Log
- $LOG
EOF

echo "$(date -Is) RUN_COMPLETED $RUN_ID" >> "$LOG"

echo
echo "Done."
echo "Run folder: $RUN_DIR"
echo "Manifest: $MANIFEST"
echo "Notes created: $OUTPUTS_FILE"
