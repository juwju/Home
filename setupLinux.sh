#!/bin/bash
#TODO: ajouter la création de rep /home/JUWJU
#TODO: Ajouter la connexion à Juwju via mot de passe et téléchargement de ./script et autre fichier dans /home/JUWJU
#set -e  # Stop the script immediately if any command fails

clear
cat <<'EOF'
===============================================
🚀 Deno & Zsh Setup Script 1.6
===============================================

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

sleep 4

# Ensure setfacl is available; if not, install the 'acl' package.
if ! command -v setfacl &> /dev/null; then
  echo "setfacl command not found. Installing 'acl' package..."
  sudo apt update && sudo apt install -y acl
fi

# Grant full permissions on /opt and all its contents to the current user without changing ownership
echo "Granting full permissions on /opt to user $USER..."
sudo setfacl -R -m u:"$USER":rwx /opt
sudo setfacl -dR -m u:"$USER":rwx /opt

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

# Determine the path for zsh
zsh_path=$(which zsh)

# Change the default shell for the current user if needed
current_shell=$(getent passwd "$USER" | cut -d: -f7)
if [ "$current_shell" != "$zsh_path" ]; then
  echo "Changing the default shell for the current user to Zsh..."
  sudo chsh -s "$zsh_path" "$USER"
else
  echo "Zsh is already the default shell for the current user."
fi

# Change the default shell for new users by updating /etc/default/useradd
if [ -f /etc/default/useradd ]; then
  echo "Setting default shell for new users to Zsh..."
  if grep -q '^SHELL=' /etc/default/useradd; then
    sudo sed -i "s|^SHELL=.*|SHELL=$zsh_path|" /etc/default/useradd
  else
    echo "SHELL=$zsh_path" | sudo tee -a /etc/default/useradd > /dev/null
  fi
else
  echo "/etc/default/useradd not found; skipping default shell configuration for new users."
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

# Add alias in Zsh to replace "deno task" with "jj"
if ! grep -q 'alias jj="deno task"' ~/.zshrc; then
  echo 'alias jj="deno task"' >> ~/.zshrc
fi

# Create the JUWJU directory in the user's home directory
mkdir -p "$HOME/JUWJU"

# Final message and switch to Zsh
echo ""
echo "✅ Installation completed!"
echo "➡️ Next steps:"
echo "  1️⃣ Open a new terminal."
echo "  2️⃣ Run 'deno --version' to verify the Deno installation."
echo "  3️⃣ Start using Deno with Zsh!"
echo ""

sleep 4

# Switch to Zsh immediately
exec zsh



