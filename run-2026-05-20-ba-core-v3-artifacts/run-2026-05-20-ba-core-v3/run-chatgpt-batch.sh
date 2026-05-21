#!/usr/bin/env bash
set -euo pipefail

RUN_ID="${1:?Usage: $0 <run-id> <batch-file> <master-skill> <input-prompt>}"
BATCH_FILE="${2:?Missing batch file}"
MASTER_SKILL="${3:?Missing master-skill file}"
INPUT_PROMPT="${4:?Missing input prompt file}"

RUN_DIR="ops/runs/$RUN_ID"
INPUTS_DIR="$RUN_DIR/inputs"

mkdir -p "$INPUTS_DIR"

cp "$MASTER_SKILL" "$INPUTS_DIR/"
cp "$INPUT_PROMPT" "$INPUTS_DIR/"
cp "$BATCH_FILE" "$RUN_DIR/batch.md"

NOTE_COUNT=$(grep -c "^--- NOTE START ---" "$RUN_DIR/batch.md" || true)

echo "NOTE BLOCKS: $NOTE_COUNT"

./scripts/split-obsidian-batch.sh "$RUN_DIR/batch.md"
