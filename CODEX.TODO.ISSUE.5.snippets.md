# PRD: Snippet inclusion flags for repo_clipboard

- GitHub Issue: #5
- Topic: `--snippet`, `--snippets-file`, `--snippets-only`

## Context
We often need to share just the relevant fragments of files (e.g., log excerpts or code ranges) with GPT-5 Pro. Capturing whole files can waste tokens and obscure the signal. `repo_clipboard` should accept line-range references, combine them with the rest of the context when needed, and write a clean XML with attributes describing snippet provenance.

## Objectives
- Add `--snippet path:start[-end]` (repeatable) and `--snippets-file` (one spec per line) to include file fragments.
- Support 1-based line indexing forms: single line (`path:N`), open-end (`path:N-`), open-start (`path:-M`), and bounded (`path:N-M`).
- Provide `--snippets-only` which prevents inclusion of non-snippet files; call this out clearly in `--help`.
- Represent snippet metadata via pseudo-XML attributes on `<file>` nodes: `snippet_from`, `start`, `end`. Do not inject content headers.

## Scope
- Argparse additions + help epilog examples.
- Snippet parsing and extraction with bounds clamping and warnings when needed.
- Integration into selection pipeline: snippets are additive unless `--snippets-only` is set. `--max_size` applies to snippet bytes.
- Ensure multiple snippets from the same file are supported without overwriting.
- Update README and example_usage with examples and best practices.

## Acceptance Criteria
- `./repo_clipboard --help` documents snippets, shows examples, and explicitly states that `--snippets-only` prevents inclusion of non-snippet files.
- `repo_clipboard -e md --snippet README.md:1-5 --snippets-only --print-files`:
  - Emits a `<file name="README.md#snippet-1" snippet_from="README.md" start="1" end="5">…</file>` entry.
  - `/tmp/repo_clipboard.stdout` contains the snippet entry; stderr mirrored.
  - `--print-files` lists the snippet with token estimate.
- `--max_size` applied to snippet content bytes; oversize snippets are skipped with a warning.

## Implementation Plan
1) Add flags: `--snippet` (append), `--snippets-file`, `--snippets-only`.
2) Implement parser for `path:spec` where `spec` ∈ {`N`, `N-`, `-M`, `N-M`}.
3) Extract content, clamp to file length, and build virtual paths with unique names (e.g., `filename#snippet-<n>`).
4) Capture per-snippet metadata (`snippet_from`, `start`, `end`) for XML attributes.
5) Integrate into `--print-files` with per-snippet token estimates.
6) Update help epilog and README/example_usage.
7) Ruff check and smoke tests for basic flows.

## ToDo
- [x] 1) Add argparse flags and help text
- [x] 2) Implement snippet parser and extraction
- [x] 3) Integrate snippets into selection and XML generation
- [x] 4) Apply `--max_size` to snippets; skip oversize with warning
- [x] 5) Update README and example_usage
- [x] 6) Ruff check + smoke tests

## Closure
Status: Closed.

Summary
- Implemented snippet inclusion via `--snippet`, `--snippets-file`, `--snippets-only`.
- Help updated with SNIPPETS section and explicit `--snippets-only` semantics.
- Snippets render as `<file ... snippet_from="…" start="N" end="M">` (no content headers).
- README and example_usage updated with examples.

Notes
- `/tmp` snapshot behavior unchanged; works with snippets.
