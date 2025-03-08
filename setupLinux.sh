#!/bin/bash

# Met à jour les paquets du système
echo "Mise à jour des paquets du système..."
sudo apt update
sudo apt upgrade -y

# Vérifie si 'unzip' est installé, sinon l'installe
if ! command -v unzip &> /dev/null; then
  echo "'unzip' n'est pas installé. Installation de unzip..."
  sudo apt install -y unzip
else
  echo "'unzip' est déjà installé."
fi

# Télécharge et installe Deno
echo "Installation de Deno..."
curl -fsSL https://deno.land/x/install/install.sh | sh

# Ajoute Deno au PATH (si nécessaire)
if ! grep -q "$HOME/.deno/bin" ~/.bashrc; then
  echo "Ajout de Deno au PATH..."
  echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.bashrc
  echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
else
  echo "Deno est déjà dans le PATH."
fi

# Vérifie l'installation de Deno
echo "Vérification de l'installation de Deno, fermez le terminal, ouvrez un nouveau et exécuté : 'deno --version'..."

echo "Installation terminée."
