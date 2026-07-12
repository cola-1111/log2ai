#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/log2ai"

if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: log2ai script not found at $SOURCE_FILE" >&2
    exit 1
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Creating $INSTALL_DIR ..."
    mkdir -p "$INSTALL_DIR"
fi

if [[ -f "$INSTALL_DIR/log2ai" ]]; then
    echo "Note: Overwriting existing $INSTALL_DIR/log2ai"
fi

cp "$SOURCE_FILE" "$INSTALL_DIR/log2ai"
chmod +x "$INSTALL_DIR/log2ai"

echo "Installed log2ai to $INSTALL_DIR/log2ai"

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    echo "WARNING: $INSTALL_DIR is not in your PATH."
    echo "Add the following to your ~/.bashrc:"
    echo ""
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then run: source ~/.bashrc"
fi
