# Usage: `repo_clipboard`

This skill bundles a single CLI tool: `repo-clipboard/scripts/repo_clipboard`.

It snapshots the **current directory** (recursively) into a pseudo‑XML format designed to be fed to LLMs.

## Common patterns

- **Pipe to an LLM tool** (XML on stdout; metadata on stderr):
  - `scripts/repo_clipboard --llm -e py,md,yml --print-files | llm -x -s "Review this repo snapshot"`
- **Write a snapshot file** (without clipboard):
  - `scripts/repo_clipboard --llm -e py,md > snapshot.xml`
- **Reuse the `/tmp` copy** (available in both modes):
  - `cp /tmp/repo_clipboard.stdout snapshot.xml`

## Filtering

- **Extensions**:
  - `-e py,md,yml` (no dots)
- **Max size**:
  - `--max_size 100` (KB)
- **Regex include / ignore** (applied to relative paths):
  - `--only-include ".*\\.(py|md)$"`
  - `--ignore-list "node_modules|__pycache__|.*\\.min\\.js$"`

## Snippets (line ranges)

Use snippets to include only relevant lines from large files:

- Single line: `path:N`
- Open-end: `path:N-` (N..EOF)
- Open-start: `path:-M` (1..M)
- Bounded: `path:N-M`

Examples:

- `scripts/repo_clipboard --llm -e md --snippet README.md:1-30 --snippets-only`
- `scripts/repo_clipboard --llm --snippets-file snippets.txt --snippets-only`

## Output behavior

- Default mode (no `--llm`):
  - Tries to copy XML to Windows clipboard via `clip.exe` (WSL).
  - Writes `/tmp/repo_clipboard.stdout` (XML).
  - Mirrors stderr to `/tmp/repo_clipboard.stderr`.
- `--llm` mode:
  - Prints XML on stdout.
  - Prints metadata (token estimate, `/tmp` paths) on stderr.
  - Mirrors stderr to `/tmp/repo_clipboard.stderr`.

## Notes / gotchas

- If you run from inside a git repo, `.gitignore` is respected by default.
- Common dev artifacts are ignored by default unless you pass `--no-ignore-common`.
- Snippets are treated as “virtual files” in the XML (with `snippet_from`, `start`, `end` attributes).
- Token estimates are best-effort; if `tiktoken` is unavailable, token counts print as `unknown` (or metadata reports `tokens=unknown`). If you need accurate counts, run with `uv run --with tiktoken scripts/repo_clipboard ...` (requires package availability).
