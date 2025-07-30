#!/bin/bash

# Installer for repo_clipboard script
# Makes the script executable and installs it to ~/.local/bin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CLIPBOARD="$SCRIPT_DIR/repo_clipboard"
TARGET_DIR="$HOME/.local/bin"
TARGET_FILE="$TARGET_DIR/repo_clipboard"

echo "Installing repo_clipboard..."

# Check if source file exists
if [[ ! -f "$REPO_CLIPBOARD" ]]; then
    echo "Error: repo_clipboard script not found at $REPO_CLIPBOARD" >&2
    exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy the script and make it executable
echo "Copying $REPO_CLIPBOARD to $TARGET_FILE"
cp "$REPO_CLIPBOARD" "$TARGET_FILE"
chmod +x "$TARGET_FILE"

# Add ~/.local/bin to PATH in .bashrc if not already present
BASHRC="$HOME/.bashrc"
PATH_LINE='export PATH="$PATH:$HOME/.local/bin"'

if [[ -f "$BASHRC" ]]; then
    if ! grep -q "$PATH_LINE" "$BASHRC"; then
        echo "Adding ~/.local/bin to PATH in .bashrc"
        echo "" >> "$BASHRC"
        echo "# Added by repo_clipboard installer" >> "$BASHRC"
        echo "$PATH_LINE" >> "$BASHRC"
    else
        echo "PATH already includes ~/.local/bin in .bashrc"
    fi
else
    echo "Creating .bashrc and adding PATH"
    echo "# Added by repo_clipboard installer" > "$BASHRC"
    echo "$PATH_LINE" >> "$BASHRC"
fi

echo "Installation complete!"
echo "Restart your shell or run 'source ~/.bashrc' to use the 'repo_clipboard' command"
echo "You can now run 'repo_clipboard' from anywhere"