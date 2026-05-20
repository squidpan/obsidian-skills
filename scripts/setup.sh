#!/bin/bash
folder="$1"

echo "Creating folder structure [$folder]..."
mkdir -p $folder/skills
mkdir -p $folder/concepts
mkdir -p $folder/tools
mkdir -p $folder/processes
mkdir -p $folder/runbooks
mkdir -p $folder/usecases
mkdir -p $folder/indexes


# Phase 12: Copy inputs into run

mkdir -p ops/runs/run-2026-05-20-ba-core-v1/inputs

cp master-skill-v2.md ops/runs/run-2026-05-20-ba-core-v1/inputs/
cp input-prompts-ba/01_ba-aegis-application-support-skill-v1.md ops/runs/run-2026-05-20-ba-core-v1/inputs/

## Phase 13: Split notes - run from obsidian-skills root folder
~/pjs/repos/obsidian/obsidian-skills/scripts/split-obsidian-batch.sh ~/pjs/repos/obsidian/obsidian-skills/chatgpt/ops/runs/run-2026-05-20-ba-core-v1/batch.md
