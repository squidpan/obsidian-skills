## 🧭 PHASE 10 — Run generation

Upload to chatgpt:

master-skill-v2.md
01_ba-aegis-application-support-skill-v1.md

Then:

Generate notes #type into chatgpt

🧭 PHASE 11 — Save batch

Save as:

ops/runs/run-2026-05-20-ba-core-v1/batch.md
## 🧭 PHASE 12 — Copy inputs into run
mkdir -p ops/runs/run-2026-05-20-ba-core-v1/inputs

cp master-skill-v2.md ops/runs/run-2026-05-20-ba-core-v1/inputs/
cp 01_ba-aegis-application-support-skill-v1.md ops/runs/run-2026-05-20-ba-core-v1/inputs/

🧭 PHASE 13 — Split notes
./scripts/split-obsidian-batch.sh ops/runs/run-2026-05-20-ba-core-v1/batch.md
🧭 PHASE 14 — Validate output

Check:

YAML
categories
type
run_id
input_prompt
Graph
Skill links to all notes
tools/concepts interlinked
Duplicates
none
## 🧭 PHASE 15 — Create run-manifest.md

Path:

ops/runs/run-2026-05-20-ba-core-v1/run-manifest.md