# claude.md – Orchestrating Gemini via llm + repo_clipboard

## 0. Running Python code
ALWAYS USE `uv run` TO RUN PYTHON CODE. Do not attempt to directly invoke the system or the venv's interpreter.

# claude.md – Orchestrating Gemini via llm + repo_clipboard

## 0. Short meta-rule
👋 You are Claude Code Max acting as the **planner/executor**; **Gemini** (called through the `llm` CLI) is your **big-context reviewer/critic**.  
**Treat Gemini’s output as advisory, not gospel.** You must analyse it, reconcile conflicts, and emit a final decision. Gemini can ingest the whole repo in its large context window. ALWAYS USE GEMINI AS A TOOL WHENEVER A 'LARGE SCALE REFACTOR' IS REQUIRED.

Claude is stronger at:
* agentic workflows
* implementation
* can use tools
* can actually perform tests, see terminal outputs

Gemini is stronger at:
* very large context windows
* performing whole-codebase reviews, review consistency between code and documentation, search for old refactor leftovers / deprecated artifacts

Gemini has a 180 seconds timeout. YOU MUST NOT SPECIFY THE TIMEOUT PARAMETER FOR THE CALLING `Bash tool` BECAUSE `llm` (Gemini) HANDLES THE TIMEOUT ITSELF / alternatively, set it to 180 seconds.

---

## 1. Repo snapshot canon
When you need a full codebase snapshot, run:

```bash
repo_clipboard --llm -e py,md,yml  # or substitute extensions for list you decide
```

*This streams the pseudo-XML to **stdout** (LLM mode) and respects `.gitignore` automatically.*

When you pass `--print-files` in this mode, each file path is echoed to stderr with its token estimate (20% buffer applied) and a summary metadata line points to `/tmp/repo_clipboard.{stdout,stderr}`. The XML itself remains on stdout so Gemini receives a clean payload.

**Note**: `repo_clipboard` now works from the current directory recursively, not from git repo root. Use regex patterns for advanced filtering:

```bash
repo_clipboard --llm --only-include ".*\.(py|md|yml)$"  # Using regex for multiple extensions
```

Always pipe the result into Gemini using **system fragments** (see §4).

### Saving to a file
- Quickest: use `--llm` and redirect stdout:
```bash
repo_clipboard --llm -e py,md > snapshot.xml
```
- Or copy the auto-written `/tmp` snapshot (available in both modes):
```bash
cp /tmp/repo_clipboard.stdout snapshot.xml
```

### Snippets: include file fragments

Precise, token-efficient context via line ranges:

```bash
repo_clipboard -e md --snippet README.md:1-5 --snippets-only --print-files
```

Supported forms:
- Single line: `path:N`
- Open-end: `path:N-` (from N to EOF)
- Open-start: `path:-M` (from start to M)
- Bounded: `path:N-M`

- `--snippets-only` prevents inclusion of non-snippet files.
- Snippets add XML attributes: `snippet_from`, `start`, `end`.

---

## 2. Large-Scale Refactor (LSR) trigger

Treat a change as an **LSR** if **any** of:

* > 2 files **or** > 200 LOC staged, **or**
* public API / DB schema / package boundary touched, **or**
* new dependency introduced or package removed.

---

## 3. How to call Gemini via **`llm`**

Use the **system-fragment** flag to provide the premade prompts indicated above:
```bash
repo_clipboard --llm -e py,md,yml  | llm --sf arch_review -x | tee .ai/plan.yaml
```
You need to pipe the result to the Artifact name if you want the file to be stored. Otherwise, `llm` will print to the terminal.

`llm` can take piped inputs, system prompt (`--sf`) fragments, and ad-hoc additional prompts at the same time. For example:
```bash
repo_clipboard --llm -e py,md,yml  | llm --sf documentation_auditor -x "The documentation review should focus on the usage instructions" | tee .ai/plan.yaml
```

Claude may provide your own prompt to Gemini using the `-s` flag followed by a string:
```bash
repo_clipboard --llm -e py,md,yml  | llm -s "Claude's prompt to analyze the whole repo goes here" -x
```

**New regex filtering examples:**
```bash
# Only include Python and JavaScript files using regex
repo_clipboard --llm --only-include ".*\.(py|js)$" | llm --sf arch_review -x

# Exclude test files and cache directories
repo_clipboard --llm --ignore-list "test_.*|.*_test\.py|__pycache__" | llm --sf arch_review -x
```

Claude may also pass a diff to Gemini for evaluation:
```bash
diff … | llm -s "Claude's prompt to analyze the diff goes here" -x
```

Claude may pass a plan or todo list to Gemini for evaluation:
```bash
"Claude's plan and / or ToDo list" | llm --sf feedback_on_plan -x
```

Where:

* `arch_review` = system fragment containing the contents of `prompts/01_arch_review.md`.
* `-x` extracts Markdown/code fences wrapping the answer, if present

To see the contents of the fragments, which include usage instructions towards the end, use:
```bash
llm fragments show feedback_on_plan # or whatever fragment Claude wishes to inspect
```

ALWAYS PROVIDE CLEAR AND EXHAUSTIVE INSTRUCTIONS. For example, ask Gemini to provide a list of ALL the files to be modified.

You can ask followup questions to Gemini using the `-c` flag. For example,
```bash
repo_clipboard --llm -e py,md,yml  | llm -s "Claude's prompt to request proposed code changes" -x
llm -c "Claude's followup question (eg.: Have you included all the files that need to be changed? Review the codebase again and reply with files that you might have skipped in the first pass)"
```

Gemini is VERY keen on outputting whole code methods or modules. The default fragments include the instructions that follow. If you prompt Gemini directly, you MUST include these in your prompt, besides your actual request.

```markdown
**Proof-of-concept mindset:** favour the smallest change-set that demonstrates feasibility; stop if added complexity > marginal gain.
**Role separation:**  
   - *You* craft architecture, migration steps, risk registers, invariants, test obligations.  
   - A downstream *coding agent* (stronger at implementation) will write the actual code.  
   - Therefore **never emit full modules/method bodies**. Reference them by `path::symbol` and describe required edits.
```

If you want to send a Github issue along with the repo's codebase, you can do:
```bash
(repo_clipboard --llm -e py,md,yml && echo -e "\n\n---\n\nGITHUB ISSUE #2:\n" && gh issue view 2) | llm --sf arch_review -x "Focus on the Large-Scale Refactor d…"
```

---

## 4. Artifact directory convention

Store every machine output under `../DRM_Policy_Platform_backups/.ai/`:

## 

## 6. Critical-thinking checklist for Claude

1. **Source tracing** – link every decision to file paths / plan step IDs.
2. **Conflict resolution** – if Gemini contradicts constraints or prior invariants, request clarification *before* coding.
3. **Risk balancing** – prefer the smallest, testable change set that meets goals.
4. **Output enforcement** – if Gemini omits required keys or markers, ask it to re-emit; otherwise treat as parse error.

---
## 7. Gemini authentication

To use Gemini, the user MUST be authenticated first. Run:
```bash
wbg-auth show
```
If the output contains the string `Status: ✅ Valid`, Gemini can be used. If not, Claude stops and asks the user to authenticate before proceeding.
