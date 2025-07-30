# repo_clipboard

A command-line tool that copies repository contents to the clipboard in XML format, designed for sharing codebases with Large Language Models (LLMs).

## Overview

`repo_clipboard` scans your repository, respects `.gitignore` patterns, and formats the file contents into a pseudo-XML structure that's easy for LLMs to parse. It includes token counting, file filtering, and both clipboard and stdout output modes.

## Features

- 📋 **Clipboard Integration**: Automatically copies formatted content to Windows clipboard (WSL compatible)
- 🚫 **Gitignore Support**: Respects `.gitignore` patterns by default
- 📊 **Token Counting**: Estimates token usage with OpenAI's tiktoken
- 🎯 **Flexible Filtering**: Filter by file extensions, size limits, and custom patterns
- 🤖 **LLM Mode**: Direct stdout output for piping to other tools
- 🔧 **Easy Installation**: Multiple installation methods including auto-installer

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
  - `pathspec>=0.12`
  - `tiktoken>=0.7.0`

## Usage

### Basic Usage

Copy all files in current repository to clipboard:
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
```

Example with piping to another tool like `llm` (https://llm.datasette.io/):
```bash
repo_clipboard --llm -e py,md,yml | llm --sf arch_review -x
```

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

Use custom ignore patterns:
```bash
repo_clipboard --ignore-list .myignore
```

Use inclusion patterns:
```bash
repo_clipboard --only-include-list .myinclude
```

## Command-Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `-e, --extensions` | Comma-separated list of file extensions to include | All files |
| `--max_size` | Maximum file size in KB | 50 |
| `--git-ignore` | Respect .gitignore patterns | True |
| `--no-ignore-common` | Include common development files/directories | False |
| `--ignore-list` | Path to file with additional ignore patterns | None |
| `--only-include-list` | Path to file with inclusion patterns | None |
| `--llm` | Output to stdout instead of clipboard | False |
| `--install` | Install script to ~/.local/bin | False |

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

The tool uses OpenAI's `cl100k_base` encoding to estimate token usage. The count is displayed after copying to clipboard (adds ~20% buffer for XML formatting).

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
