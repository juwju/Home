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
  sudo chsh -s $(which zsh) $USER
else
  echo "Zsh is already the default shell."
fi

# Install Deno with automated responses
echo "Installing Deno..."
export DENO_INSTALL="$HOME/.deno"

# Create temporary script to handle the Deno installation with automated response
cat > /tmp/deno_install_script.sh << 'EOF'
#!/bin/bash
curl -fsSL https://deno.land/x/install/install.sh > /tmp/deno_installer.sh
sed -i 's/read -p "Edit shell configs to add deno to the PATH? (Y\/n) " yn/yn="Y"/g' /tmp/deno_installer.sh
bash /tmp/deno_installer.sh
EOF

# Make the script executable and run it
chmod +x /tmp/deno_install_script.sh
/tmp/deno_install_script.sh

# Ensure Deno is added to PATH for Zsh
echo "Ensuring Deno is added to PATH for Zsh..."
if ! grep -q 'export DENO_INSTALL="$HOME/.deno"' ~/.zshrc; then
  echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.zshrc
fi
if ! grep -q 'export PATH="$DENO_INSTALL/bin:$PATH"' ~/.zshrc; then
  echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.zshrc
fi

# Setup Deno autocompletion for Zsh
echo "Setting up Deno autocompletion for Zsh..."
mkdir -p ~/.zsh/completions

# Create a script to handle the autocompletion with automated response
cat > /tmp/deno_completion_script.sh << 'EOF'
#!/bin/bash
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
echo "zsh" | $HOME/.deno/bin/deno completions > ~/.zsh/completions/_deno
EOF

# Make the script executable and run it
chmod +x /tmp/deno_completion_script.sh
/tmp/deno_completion_script.sh

# Add autocompletion configuration to .zshrc if not already present
if ! grep -q 'fpath+=~/.zsh/completions' ~/.zshrc; then
  echo 'fpath+=~/.zsh/completions' >> ~/.zshrc
fi
if ! grep -q 'autoload -Uz compinit && compinit' ~/.zshrc; then
  echo 'autoload -Uz compinit && compinit' >> ~/.zshrc
fi

# Clean up temporary files
rm -f /tmp/deno_install_script.sh /tmp/deno_installer.sh /tmp/deno_completion_script.sh

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
