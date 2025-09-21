#!/usr/bin/env bash

echo "=== KnotLang Installer ==="

SCRIPT_NAME="knotlang.sh"
SCRIPT_PATH="$(realpath "$SCRIPT_NAME")"

if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Error: $SCRIPT_NAME not found in the current directory."
    exit 1
fi

read -p "Enter installation directory (default: /usr/local/bin): " INSTALL_DIR
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

sudo mkdir -p "$INSTALL_DIR"
sudo cp "$SCRIPT_PATH" "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

ALIAS_NAME="knotlang"
ALIAS_CMD="alias $ALIAS_NAME=\"$INSTALL_DIR/$SCRIPT_NAME\""

if [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == *"fish"* ]]; then
    SHELL_RC="$HOME/.config/fish/config.fish"
else
    SHELL_RC="$HOME/.bashrc"
fi

if ! grep -q "^alias $ALIAS_NAME=" "$SHELL_RC" 2>/dev/null; then
    echo "$ALIAS_CMD" >> "$SHELL_RC"
    echo "Alias '$ALIAS_NAME' added to $SHELL_RC"
else
    echo "Alias '$ALIAS_NAME' already exists in $SHELL_RC"
fi

echo "Installation complete! Close and reopen the terminal or run 'source $SHELL_RC' to use KnotLang."
