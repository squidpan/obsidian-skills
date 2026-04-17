chatgtp-ready obsidian-skills can be copied and pasted into chatgpt as prompts to to output info in Obsidian notes



## Option 1 — Multi-Note File

Tell ChatGPT:

```
Output all notes in ONE markdown file, separated by clear delimiters
```

## The workflow I recommend
Keep the AI step manual, but make the file creation step scriptable:


In ChatGPT Plus, paste your adapted master-skill.md.


Ask ChatGPT to output one big markdown file containing many notes, each wrapped with clear delimiters and a filename.


Save that big file somewhere like inbox/generated-batch.md.


Run a Bash script that splits the batch into separate .md files.


Optionally, have the script use Obsidian CLI to create the notes from your Obsidian templates, or at minimum to create/open files in the right vault. The CLI supports creating notes from templates and targeting a vault or exact path. 


Update your ChatGPT output format
Have ChatGPT return notes in this exact structure:
--- NOTE START ---filename: sre/tools/grafana.mdtemplate: Tool Note---type: toolcategory: sretags: [grafana, monitoring, observability]created: 2026-04-16source: chatgpt---# Grafana- Visualization platform for metrics and observability.- Commonly used with [[Prometheus]].--- NOTE END ------ NOTE START ---filename: sre/concepts/alerting.mdtemplate: Concept Note---type: conceptcategory: sretags: [alerting, monitoring, reliability]created: 2026-04-16source: chatgpt---# Alerting- Mechanism to notify engineers when thresholds are breached.--- NOTE END ---
That gives your script three things it can trust:


filename


template


the note body, including YAML frontmatter


The Bash script
This version works in two modes:


filesystem mode: writes .md files directly


Obsidian CLI mode: can create notes through obsidian create, using templates if you want


Save this as split-obsidian-batch.sh:
#!/usr/bin/env bashset -euo pipefail# Usage:#   ./split-obsidian-batch.sh /path/to/generated-batch.md /path/to/vault## Optional environment variables:#   USE_OBSIDIAN_CLI=1         # use Obsidian CLI for note creation when possible#   VAULT_NAME="My Vault"      # vault name for Obsidian CLI#   DEFAULT_TEMPLATE=""        # fallback template if template: is missing#   OVERWRITE=0                # 1 to overwrite existing files, 0 to skip## Example:#   USE_OBSIDIAN_CLI=1 VAULT_NAME="Notes" ./split-obsidian-batch.sh batch.md ~/vaults/NotesINPUT_FILE="${1:-}"VAULT_DIR="${2:-}"if [[ -z "$INPUT_FILE" || -z "$VAULT_DIR" ]]; then  echo "Usage: $0 /path/to/generated-batch.md /path/to/vault"  exit 1fiif [[ ! -f "$INPUT_FILE" ]]; then  echo "Input file not found: $INPUT_FILE"  exit 1fiif [[ ! -d "$VAULT_DIR" ]]; then  echo "Vault directory not found: $VAULT_DIR"  exit 1fiUSE_OBSIDIAN_CLI="${USE_OBSIDIAN_CLI:-0}"VAULT_NAME="${VAULT_NAME:-}"DEFAULT_TEMPLATE="${DEFAULT_TEMPLATE:-}"OVERWRITE="${OVERWRITE:-0}"if [[ "$USE_OBSIDIAN_CLI" == "1" ]]; then  if ! command -v obsidian >/dev/null 2>&1; then    echo "USE_OBSIDIAN_CLI=1 but 'obsidian' command not found in PATH."    exit 1  fifitmpdir="$(mktemp -d)"trap 'rm -rf "$tmpdir"' EXIT# Split the batch into note chunks.awk -v outdir="$tmpdir" '  BEGIN {    note = 0    in_note = 0    content = ""  }  /^--- NOTE START ---[[:space:]]*$/ {    in_note = 1    note++    content = $0 ORS    next  }  /^--- NOTE END ---[[:space:]]*$/ {    if (in_note) {      content = content $0 ORS      file = sprintf("%s/note_%03d.txt", outdir, note)      print content > file      close(file)      in_note = 0      content = ""    }    next  }  {    if (in_note) {      content = content $0 ORS    }  }' "$INPUT_FILE"shopt -s nullglobcount=0for chunk in "$tmpdir"/note_*.txt; do  count=$((count + 1))  # Extract filename  filename="$(awk -F': ' '    /^filename:[[:space:]]*/ {      sub(/^filename:[[:space:]]*/, "", $0)      print      exit    }  ' "$chunk")"  if [[ -z "$filename" ]]; then    echo "Skipping chunk $chunk: missing filename"    continue  fi  # Extract template (optional)  template="$(awk -F': ' '    /^template:[[:space:]]*/ {      sub(/^template:[[:space:]]*/, "", $0)      print      exit    }  ' "$chunk")"  if [[ -z "$template" ]]; then    template="$DEFAULT_TEMPLATE"  fi  # Extract note body:  # everything after the line containing only '---' that follows filename/template header lines  body="$(awk '    BEGIN {      header_done = 0    }    /^---[[:space:]]*$/ && header_done == 0 {      header_done = 1      next    }    header_done == 1 {      if ($0 ~ /^--- NOTE END ---[[:space:]]*$/) exit      print    }  ' "$chunk")"  if [[ -z "$body" ]]; then    echo "Skipping $filename: empty body"    continue  fi  # Normalize path  relpath="$filename"  relpath="${relpath#./}"  relpath="${relpath#/}"  target_path="$VAULT_DIR/$relpath"  target_dir="$(dirname "$target_path")"  note_name="$(basename "$relpath" .md)"  mkdir -p "$target_dir"  if [[ -f "$target_path" && "$OVERWRITE" != "1" ]]; then    echo "Skipping existing file: $relpath"    continue  fi  if [[ "$USE_OBSIDIAN_CLI" == "1" && -n "$VAULT_NAME" ]]; then    # Create with template if requested, then overwrite content with body.    # We target exact path so folder placement stays deterministic.    if [[ -n "$template" ]]; then      if [[ "$OVERWRITE" == "1" ]]; then        obsidian vault="$VAULT_NAME" create path="$relpath" template="$template" silent overwrite      else        obsidian vault="$VAULT_NAME" create path="$relpath" template="$template" silent      fi    else      if [[ "$OVERWRITE" == "1" ]]; then        obsidian vault="$VAULT_NAME" create path="$relpath" silent overwrite      else        obsidian vault="$VAULT_NAME" create path="$relpath" silent      fi    fi    # Replace the content with the exact body generated by ChatGPT.    printf "%s\n" "$body" > "$target_path"    echo "Created via Obsidian CLI + wrote content: $relpath"  else    printf "%s\n" "$body" > "$target_path"    echo "Wrote file: $relpath"  fidoneecho "Processed $count note blocks."
What this script assumes
It assumes your batch file uses:


--- NOTE START ---


filename: ...


optional template: ...


a separator line containing only ---


the full note body


--- NOTE END ---


That is deliberate, because it keeps the parsing simple and makes later automation much easier.
How to run it
Make it executable:
chmod +x split-obsidian-batch.sh
Filesystem-only mode:
./split-obsidian-batch.sh ~/inbox/generated-batch.md ~/Obsidian/MyVault
With Obsidian CLI enabled:
USE_OBSIDIAN_CLI=1 VAULT_NAME="MyVault" ./split-obsidian-batch.sh ~/inbox/generated-batch.md ~/Obsidian/MyVault
Obsidian’s docs say the CLI uses the current working directory vault by default, or you can target a specific vault with vault=<name> as the first parameter. They also document create, template=..., silent, overwrite, and path=..., which is why the script is written that way. 
Should you use Obsidian CLI here?
Yes, but in a limited way for now.
For your current zero-extra-cost manual workflow, the Bash script is the main value. Obsidian CLI adds value because it is now an official, supported way to script note creation and templates, so using it now helps keep your manual workflow aligned with how you may automate later. But you do not need it for the first version; plain file writes are enough if you want the simplest path. 
My practical recommendation:


Start with filesystem mode first.


Once that works, turn on Obsidian CLI mode.


Keep the same batch format either way.


Revised end-to-end workflow
1) Fork and adapt the skills
Fork kepano/obsidian-skills, clone it locally, and create your own ChatGPT-ready versions of the skills under a separate folder such as chatgpt/. Kepano’s repo includes an obsidian-cli skill and broader skill files intended for structured Obsidian workflows, so your plan to become familiar with them now and automate later is sensible. 
2) Build master-skill.md
Your master-skill.md should:


enforce your YAML properties


enforce note atomicity


require filename: and optional template:


require the delimiter format above


require all notes to be returned in one batch file


3) Use ChatGPT Plus manually
In each research session:


paste master-skill.md


paste your research topic or raw notes


ask for output in your batch format


This keeps you at zero extra cost because you are using ChatGPT Plus manually and not the API.
4) Save the batch file
Paste the ChatGPT output into a temporary markdown file such as:
~/inbox/generated-batch.md
5) Run the splitter
Run:
./split-obsidian-batch.sh ~/inbox/generated-batch.md ~/Obsidian/MyVault
or, if ready:
USE_OBSIDIAN_CLI=1 VAULT_NAME="MyVault" ./split-obsidian-batch.sh ~/inbox/generated-batch.md ~/Obsidian/MyVault
6) Review in Obsidian
Open your vault and inspect:


file placement


YAML frontmatter


tags


links


template consistency


7) Refine the script, not the process
When something is off, update:


master-skill.md if the AI output needs to change


split-obsidian-batch.sh if file placement or parsing needs to change


That separation is what makes this future-proof.
The one change I’d make to your master prompt
Add an explicit output contract like this:
Return all notes in one markdown batch file.For each note, use this exact structure:--- NOTE START ---filename: <folder/path/note-name.md>template: <optional template name>---<full note content, including YAML frontmatter>--- NOTE END ---Do not add commentary before, between, or after notes.
That one addition is what makes the Bash step reliable.
Bottom line
Your new system becomes:


ChatGPT Plus for thinking and note generation


one batch markdown file as the handoff format


a Bash splitter for turning the batch into real note files


optional Obsidian CLI so your manual workflow already matches the shape of future automation 


I can also help you rewrite your master-skill.md so it emits exactly the format that this script expects.