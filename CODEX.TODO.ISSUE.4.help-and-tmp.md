# PRD: Improve `--help` clarity and write /tmp snapshots in all modes

- GitHub Issue: #4
- Topic: Help text and /tmp snapshot behavior

## Context
The `repo_clipboard` tool is used by coding agents (e.g., Codex CLI) to snapshot repositories into a pseudo‑XML format. Currently, `./repo_clipboard --help` does not explicitly communicate:
- Where the output goes in each mode (clipboard vs stdout/stderr)
- How to save output to a file (pipe/redirect)
- When to use `--llm`
- That snapshots are also written to `/tmp` for reuse

This ambiguity slows agent workflows and leads to repeated runs. The tool already writes `/tmp/repo_clipboard.stdout` and `/tmp/repo_clipboard.stderr` in `--llm` mode; we will make this consistent in all modes and document it clearly in `--help`.

## Objectives
- Make `--help` actionable for agents: clarify output channels, `/tmp` snapshot files, and recommended piping/redirect patterns.
- Ensure the XML snapshot and logs are always written to `/tmp` in both modes.
- Provide concrete examples within `--help` for common workflows (pipe to `llm`, save to file, print file list with token estimates).

## Scope
- Enhance argparse help (formatter + epilog) with explicit behavior and examples.
- Write XML to `/tmp/repo_clipboard.stdout` in both modes; copy stderr to `/tmp/repo_clipboard.stderr` in both modes.
- Update README/example_usage to match the clarified behavior.
- Keep existing XML format and filtering semantics unchanged.

## Non‑Goals
- No change to the XML structure or default filtering logic.
- No new flags to customize output paths (can be revisited later).

## Acceptance Criteria
- `./repo_clipboard --help` clearly states:
  - Clipboard mode: XML goes to Windows clipboard; a copy is written to `/tmp/repo_clipboard.stdout`; logs/warnings mirrored to `/tmp/repo_clipboard.stderr`.
  - `--llm` mode: XML on stdout, metadata on stderr; both mirrored to `/tmp/...`.
  - How to save to a file (`--llm` + pipe/redirect) and when to use each mode.
  - Examples: pipe to `llm`, tee to file, `--print-files` behavior.
- Running in both modes writes `/tmp` snapshots without errors.
- README reflects the same points succinctly.

## Risks / Notes
- `/tmp` may be cleaned by the OS; the tool will still function and re‑create as needed.
- Stderr mirroring uses a tee wrapper; it should not interfere with normal stderr usage.

## Implementation Plan
1. Parser: switch to `RawDescriptionHelpFormatter`, add detailed epilog with examples.
2. Behavior: always write XML to `/tmp/repo_clipboard.stdout` and stderr mirror to `/tmp/repo_clipboard.stderr`.
3. Docs: update README and example_usage.
4. Lint: run `ruff check` on the repo to catch style issues.
5. Smoke test: run `./repo_clipboard --help`, run in clipboard mode and `--llm` mode; confirm `/tmp` files appear; confirm examples behave.

## ToDo
- [x] 1) Update argparse help text and epilog with explicit output behavior and examples
- [x] 2) Write `/tmp` snapshots in both modes (XML + stderr mirror)
- [x] 3) Update README and example_usage to match
- [x] 4) Run `uvx ruff check` and fix any errors
- [x] 5) Smoke test both modes and verify `/tmp` outputs
- [x] 6) Bump version and show version in `--help`

## Closure
Issue #4 closed. Summary:
- Clarified `--help` with explicit output channels, /tmp paths, and examples
- Always write `/tmp/repo_clipboard.{stdout,stderr}` in both modes
- Bumped version to 0.1.1 and surfaced in help
- Updated README and example_usage; ruff clean; smoke tested

Commit: (see git log for the latest on `main`)
