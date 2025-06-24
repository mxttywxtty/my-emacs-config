#!/bin/bash

# Dotfiles installation script

DOTFILES_DIR="$HOME/config/emacs/my-emacs-config"
EMACS_DIR="$HOME/.emacs.d"

echo "Setting up dotfiles..."

# Create .emacs.d directory if it doesn't exist
if [ ! -d "$EMACS_DIR" ]; then
    echo "Creating $EMACS_DIR directory..."
    mkdir -p "$EMACS_DIR"
fi

# Backup existing files
backup_if_exists() {
    if [ -e "$1" ] && [ ! -L "$1" ]; then
        echo "Backing up existing $1 to $1.backup"
        mv "$1" "$1.backup"
    fi
}

# Create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -e "$source" ]; then
        backup_if_exists "$target"
        echo "Creating symlink: $target -> $source"
        ln -sf "$source" "$target"
    else
        echo "Warning: $source does not exist, skipping..."
    fi
}

# Emacs configuration
echo "Setting up Emacs configuration..."
create_symlink "$DOTFILES_DIR/emacs/init.el" "$EMACS_DIR/init.el"

# Only create snippets symlink if the directory exists
if [ -d "$DOTFILES_DIR/emacs/snippets" ]; then
    create_symlink "$DOTFILES_DIR/emacs/snippets" "$EMACS_DIR/snippets"
fi

# Early init if it exists
if [ -f "$DOTFILES_DIR/emacs/early-init.el" ]; then
    create_symlink "$DOTFILES_DIR/emacs/early-init.el" "$EMACS_DIR/early-init.el"
fi

echo "Dotfiles setup complete!"
echo "Don't forget to install Emacs packages on first run."
