#!/bin/bash

# Opening message
clear
echo "==============================================="
echo "🚀 Deno & Zsh Setup Script"
echo "==============================================="
echo ""
echo "This script will install and configure the necessary components in three steps:"
echo ""
echo "1️⃣ **Update System**: Ensure your system is up to date."
echo "2️⃣ **Setup Zsh**: Install Zsh and make it your default shell (new terminal experience)."
echo "3️⃣ **Setup Deno**: Install Deno, a secure and modern runtime for JavaScript and TypeScript."
echo "   - Deno is built on V8 and Rust."
echo "   - It offers built-in TypeScript support and secure-by-default execution."
echo ""
echo "➡️ Once the installation is complete, the script will switch to Zsh automatically."
echo ""
read -n1 -r -p "Press SPACE to continue..." key
clear

# Update system packages
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Check if 'unzip' is installed, install if missing
if ! command -v unzip &> /dev/null; then
  echo "'unzip' is not installed. Installing unzip..."
  sudo apt install -y unzip
else
  echo "'unzip' is already installed."
fi

# Check if 'zsh' is installed, install if missing
if ! command -v zsh &> /dev/null; then
  echo "'zsh' is not installed. Installing zsh..."
  sudo apt install -y zsh
else
  echo "'zsh' is already installed."
fi

# Check if Zsh is the default shell, change if needed
if [[ "$SHELL" != *zsh ]]; then
  echo "Changing the default shell to Zsh..."
  chsh -s $(which zsh)
else
  echo "Zsh is already the default shell."
fi

# Install Deno
echo "Installing Deno..."
curl -fsSL https://deno.land/x/install/install.sh | sh

# Add Deno to PATH for Zsh
echo "Adding Deno to PATH for Zsh..."
echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.zshrc
echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.zshrc

# Set up Deno autocompletion for Zsh
echo "Setting up Deno autocompletion for Zsh..."
mkdir -p ~/.zsh/completions
deno completions zsh > ~/.zsh/completions/_deno
echo 'fpath+=~/.zsh/completions' >> ~/.zshrc
echo 'autoload -Uz compinit && compinit' >> ~/.zshrc

# Next steps message
echo ""
echo "✅ Installation completed!"
echo "➡️ Next steps:"
echo "  1️⃣ Open a new terminal"
echo "  2️⃣ Run 'deno --version' to check if Deno is installed"
echo "  3️⃣ Start using Deno with Zsh!"
echo ""

# Pause before switching shell
read -n1 -r -p "Press SPACE to continue and switch to Zsh..." key

# Apply changes immediately
exec zsh
