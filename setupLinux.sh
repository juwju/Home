#!/bin/bash
set -e  # Stop the script immediately if any command fails

clear
cat <<'EOF'
=========================================================
🚀 Setup Juwju requirement : Deno & Zsh Setup Script 1.7
=========================================================

🔴 **IMPORTANT:** A free Juwju account is required to proceed with the installation.
   - If you don't have an account yet, go to https://juwju.com and create one.
   - You will need to log in during the setup process.

⚠️  NOTE: This script requires sudo privileges at certain steps.
   You will be prompted to enter your password during installation.

This script will install and configure the necessary components in three steps:

1️⃣ **Update System**: Ensure your system is up to date.
2️⃣ **Setup Zsh**: Install Zsh and make it your default shell.
3️⃣ **Setup Deno**: Install Deno, a secure and modern runtime for JavaScript and TypeScript.
   - Deno is built on V8 and Rust.
   - It offers built-in TypeScript support and secure-by-default execution.

➡️ Once the installation is complete, the script will automatically switch to Zsh.

EOF

sleep 2

clear

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Check if 'unzip' is installed; install if missing
if ! command -v unzip &> /dev/null; then
  echo "'unzip' is not installed. Installing unzip..."
  sudo apt install -y unzip
else
  echo "'unzip' is already installed."
fi

# Check if 'zsh' is installed; install if missing
if ! command -v zsh &> /dev/null; then
  echo "'zsh' is not installed. Installing zsh..."
  sudo apt install -y zsh
else
  echo "'zsh' is already installed."
fi

# Check if Zsh is the default shell; change if necessary
if [[ "$SHELL" != *zsh ]]; then
  echo "Changing the default shell to Zsh..."
  sudo chsh -s "$(which zsh)" "$USER"
else
  echo "Zsh is already the default shell."
fi

# Install Deno with automated confirmation
echo "Installing Deno..."
export DENO_INSTALL="$HOME/.deno"
curl -fsSL https://deno.land/x/install/install.sh | sh -s -- -y

# Ensure Deno is added to PATH in the Zsh configuration
echo "Ensuring Deno is added to PATH for Zsh..."
if ! grep -q 'export DENO_INSTALL="$HOME/.deno"' ~/.zshrc; then
  echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.zshrc
fi
if ! grep -q 'export PATH="$DENO_INSTALL/bin:$PATH"' ~/.zshrc; then
  echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.zshrc
fi

# Set up Deno autocompletion for Zsh
echo "Setting up Deno autocompletion for Zsh..."
mkdir -p ~/.zsh/completion
"$HOME/.deno/bin/deno" completions zsh > ~/.zsh/completion/_deno

if ! grep -q 'fpath=(~/.zsh/completion $fpath)' ~/.zshrc; then
  echo 'fpath=(~/.zsh/completion $fpath)' >> ~/.zshrc
fi
if ! grep -q 'autoload -U compinit' ~/.zshrc; then
  {
    echo 'autoload -U compinit'
    echo 'compinit'
  } >> ~/.zshrc
fi

# Final message and switch to Zsh
echo ""
echo "✅ Installation completed!"
echo "➡️ Next steps:"
echo "  1️⃣ Open a new terminal."
echo "  2️⃣ Run 'deno --version' to verify the Deno installation."
echo "  3️⃣ Start using Deno with Zsh!"
echo ""

read -n1 -r -p "Press the SPACE BAR to continue and switch to Zsh..." key
if [[ "$key" != " " ]]; then
    echo -e "\nShell switch aborted."
    exit 1
fi

# Switch to Zsh immediately
exec zsh

