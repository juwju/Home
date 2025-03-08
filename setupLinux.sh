#!/bin/bash

# Opening message
clear
echo "==============================================="
echo "🚀 Deno & Zsh Setup Script"
echo "==============================================="
echo ""
echo "🔴 **IMPORTANT:** A free Juwju account is required to proceed with the installation."
echo "   - If you don't have an account yet, go to **https://juwju.com** and create one."
echo "   - You will need to log in during the setup process."
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

# Install Deno with automated responses using here-document
echo "Installing Deno..."
export DENO_INSTALL="$HOME/.deno"

# Use here-document to provide "Y" as answer to the PATH configuration prompt
(
echo "Y"  # Answer to "Edit shell configs to add deno to the PATH? (Y/n)"
) | curl -fsSL https://deno.land/x/install/install.sh | sh

# Ensure Deno is added to PATH for Zsh (in case the automated response didn't work)
echo "Ensuring Deno is added to PATH for Zsh..."
if ! grep -q 'export DENO_INSTALL="$HOME/.deno"' ~/.zshrc; then
  echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.zshrc
fi
if ! grep -q 'export PATH="$DENO_INSTALL/bin:$PATH"' ~/.zshrc; then
  echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.zshrc
fi

# Setup Deno autocompletion for Zsh with automated response
echo "Setting up Deno autocompletion for Zsh..."
mkdir -p ~/.zsh/completions

# Use here-document to provide "zsh" as answer to the autocompletion prompt
echo "zsh" | "$HOME/.deno/bin/deno" completions > ~/.zsh/completions/_deno

# Add autocompletion configuration to .zshrc if not already present
if ! grep -q 'fpath+=~/.zsh/completions' ~/.zshrc; then
  echo 'fpath+=~/.zsh/completions' >> ~/.zshrc
fi
if ! grep -q 'autoload -Uz compinit && compinit' ~/.zshrc; then
  echo 'autoload -Uz compinit && compinit' >> ~/.zshrc
fi

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
