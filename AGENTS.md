# Agent Notes (repo_clipboard)

## Agent Memory
- 2025-12-19: symlinking skill into `~/.codex/skills/` does not merge repos, but the symlink path lives in `~/dotfiles` git (since `~/.codex` is symlinked); ignore it or it shows up in `git status` for dotfiles.
- 2025-12-19: if you `cd ~/.codex/skills/repo-clipboard`, `git` will resolve to the source repo’s `.git` (walks upward), so `git status` will refer to the `repo_clipboard` repo, not `~/dotfiles`.
- 2025-12-19: `~/dotfiles/.gitignore` unignores `.codex/skills/**`; to keep a local dev symlink out of dotfiles `git status`, add an explicit ignore for `.codex/skills/repo-clipboard` (not just `.git/info/exclude`).
