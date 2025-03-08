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
echo "⚠️  NOTE: This script requires sudo privileges at certain steps."
echo "   You will be prompted to enter your password during installation."
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
echo "Appuyez sur la BARRE D'ESPACE pour continuer ou CTRL+C pour quitter..."
read -n1 -r key

if [[ "$key" != " " ]]; then
    echo "Installation aborted."
    exit 1
fi

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
  # Utilisez sudo pour éviter l'erreur d'authentification PAM
  sudo chsh -s $(which zsh) $USER
else
  echo "Zsh is already the default shell."
fi

# Install Deno with automated response using -y flag
echo "Installing Deno..."
export DENO_INSTALL="$HOME/.deno"
# Utilisation de l'option -y pour automatiser l'installation
curl -fsSL https://deno.land/x/install/install.sh | sh -s -- -y

# Assurer que Deno est ajouté au PATH pour Zsh
echo "Ensuring Deno is added to PATH for Zsh..."
if ! grep -q 'export DENO_INSTALL="$HOME/.deno"' ~/.zshrc; then
  echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.zshrc
fi
if ! grep -q 'export PATH="$DENO_INSTALL/bin:$PATH"' ~/.zshrc; then
  echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.zshrc
fi

# Configuration de l'autocomplétion pour Zsh
echo "Setting up Deno autocompletion for Zsh..."
mkdir -p ~/.zsh/completion

# Spécifier explicitement "zsh" comme argument pour la commande completions
$HOME/.deno/bin/deno completions zsh > ~/.zsh/completion/_deno

# Ajouter la configuration d'autocomplétion à .zshrc si elle n'est pas déjà présente
if ! grep -q 'fpath=(~/.zsh/completion $fpath)' ~/.zshrc; then
  echo 'fpath=(~/.zsh/completion $fpath)' >> ~/.zshrc
fi
if ! grep -q 'autoload -U compinit' ~/.zshrc; then
  echo 'autoload -U compinit' >> ~/.zshrc
  echo 'compinit' >> ~/.zshrc
fi

# Message de fin
echo ""
echo "✅ Installation completed!"
echo "➡️ Next steps:"
echo "  1️⃣ Open a new terminal"
echo "  2️⃣ Run 'deno --version' to check if Deno is installed"
echo "  3️⃣ Start using Deno with Zsh!"
echo ""

# Pause avant de changer de shell
read -n1 -r -p "Press SPACE to continue and switch to Zsh..." key

# Appliquer les changements immédiatement
exec zsh

