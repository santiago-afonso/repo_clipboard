# repo_clipboard

A command-line tool that copies directory contents to the clipboard in XML format, designed for sharing codebases with Large Language Models (LLMs).

## Overview

`repo_clipboard` scans your current directory recursively, respects `.gitignore` patterns, and formats the file contents into a pseudo-XML structure that's easy for LLMs to parse. It includes token counting, file filtering with regex patterns, and both clipboard and stdout output modes.

## Features

- 📋 **Clipboard Integration**: Automatically copies formatted content to Windows clipboard (WSL compatible)
- 🚫 **Gitignore Support**: Respects `.gitignore` patterns by default
- 📊 **Token Counting**: Estimates token usage with OpenAI's tiktoken
- 🎯 **Flexible Filtering**: Filter by file extensions, size limits, and regex patterns
- 🤖 **LLM Mode**: Direct stdout output for piping to other tools
- 📝 **File List Output**: Optional `--print-files` shows included files with per-file token estimates
- 🔧 **Easy Installation**: Multiple installation methods including auto-installer
- 📁 **Current Directory Focus**: Always works from current directory recursively (not git root)

## Installation

### Method 1: Using the install script
```bash
chmod +x install_repo_clipboard.sh
./install_repo_clipboard.sh
```

### Method 2: Using the --install flag
```bash
chmod +x repo_clipboard
./repo_clipboard --install
```

### Method 3: Manual installation
```bash
# Make executable
chmod +x repo_clipboard

# Copy to local bin
mkdir -p ~/.local/bin
cp repo_clipboard ~/.local/bin/

# Add to PATH (if not already added)
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

## Requirements

- Python 3.8 or higher
- `uv` (for automatic dependency management)
- Dependencies (auto-installed by uv):
  - `tiktoken>=0.7.0`

## Usage

### Basic Usage

Copy all files in current directory to clipboard:
```bash
repo_clipboard
```

### Filter by Extensions

Include only specific file types:
```bash
repo_clipboard -e py,js,md
```

### LLM Mode

Output to stdout instead of clipboard (useful for piping):
```bash
repo_clipboard --llm -e py,md,yml

# Optionally, print the included files (with token counts) to stderr while keeping XML on stdout
repo_clipboard --llm -e py,md,yml --print-files
```

Example with piping to another tool like `llm` (https://llm.datasette.io/):
```bash
repo_clipboard --llm -e py,md,yml | llm --sf arch_review -x
```

### Save to a File

- Quickest: use `--llm` and redirect stdout:
```bash
repo_clipboard --llm -e py,md > snapshot.xml
```
- Or copy the automatically written `/tmp` snapshot (available in both modes):
```bash
cp /tmp/repo_clipboard.stdout snapshot.xml
```

### Snippets (file fragments)

Include only the relevant lines from a file using snippets:

```bash
# Forms: single line, open-end, open-start, bounded
repo_clipboard -e md --snippet README.md:1       --snippets-only  # single line 1
repo_clipboard -e md --snippet README.md:10-     --snippets-only  # from 10 to EOF
repo_clipboard -e md --snippet README.md:-20     --snippets-only  # from start to 20
repo_clipboard -e md --snippet README.md:5-15    --snippets-only  # lines 5..15

# Or via a file (one spec per line)
repo_clipboard -e md --snippets-file snippets.txt --snippets-only
```

- Use `--snippets-only` to include only snippets and prevent inclusion of non-snippet files.
- Snippets are rendered with attributes on the `<file>` element, e.g. `snippet_from`, `start`, `end`.

### Advanced Filtering

Set maximum file size (in KB):
```bash
repo_clipboard --max_size 100  # Only include files under 100KB
```

Ignore gitignore patterns (include all files):
```bash
repo_clipboard --git-ignore False
```

Include commonly ignored development files:
```bash
repo_clipboard --no-ignore-common
```

Use regex patterns to ignore files:
```bash
repo_clipboard --ignore-list ".*\.log$|__pycache__"
```

Use regex patterns to include only specific files:
```bash
repo_clipboard --only-include ".*\.py$"  # Only Python files
```

## Command-Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `-e, --extensions` | Comma-separated list of file extensions to include | All files |
| `--max_size` | Maximum file size in KB | 50 |
| `--git-ignore` | Respect .gitignore patterns | True |
| `--no-ignore-common` | Include common development files/directories | False |
| `--ignore-list` | Regex pattern to ignore files (applied to relative file paths) | None |
| `--only-include` | Regex pattern to include only matching files (applied to relative file paths) | None |
| `--llm` | Output to stdout instead of clipboard | False |
| `--install` | Install script to ~/.local/bin | False |
| `--print-files` | Print the list of included files (stderr in `--llm` mode) | False |

## Output Format

The tool generates a pseudo-XML format:
```xml
<directory name="src">
  <file name="main.py">#!/usr/bin/env python
print("Hello, World!")
</file>
  <directory name="utils">
    <file name="helper.py">def helper():
    pass
</file>
  </directory>
</directory>
```

## Common Ignored Patterns

By default (unless `--no-ignore-common` is used), the tool ignores:
- Python: `.venv/`, `__pycache__/`, `*.pyc`, `.pytest_cache/`
- Node.js: `node_modules/`, `.npm/`
- IDEs: `.idea/`, `.vscode/`
- OS: `.DS_Store`, `Thumbs.db`
- Build artifacts: `dist/`, `build/`, `*.egg-info/`

## Token Counting

The tool uses OpenAI's `cl100k_base` encoding to estimate token usage. Each file listed via `--print-files` includes an estimated token count (with a 20% buffer applied to account for XML markup). After generating the XML, an overall token estimate is emitted:

- In clipboard mode, the total is printed to stdout after the copy operation.
- In `--llm` mode, metadata such as `LLM_METADATA tokens=4057 (stdout=/tmp/repo_clipboard.stdout, stderr=/tmp/repo_clipboard.stderr)` is printed to **stderr**, while the XML payload stays on **stdout**. This keeps pipelines clean—capture stderr separately if you want to pass the token hint to another tool.

In both modes, snapshots are written under `/tmp` so other processes (including other Codex CLI agents) can pick them up without re-running the command:
- XML copy: `/tmp/repo_clipboard.stdout`
- Log copy: `/tmp/repo_clipboard.stderr`

## Troubleshooting

### SSL Certificate Issues
If you encounter SSL errors with tiktoken in corporate environments, the tool automatically handles certificate verification and caching.

### Clipboard Access
- On WSL, the tool uses `clip.exe` for Windows clipboard integration
- Falls back to `pyperclip` if available
- In LLM mode (`--llm`), output goes to stdout instead

### Large Repositories
For very large repositories:
- Use extension filtering (`-e`) to limit file types
- Adjust `--max_size` to exclude large files
- Use `--ignore-list` for custom exclusions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
