#!/bin/bash

workdir=$(dirname "$0")

# ANSI escape codes for text formatting
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
reset=$(tput sgr0)

read -p "${bold}This script may modify your shell configuration and breaking changes. Do you want to continue? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "${red}Aborted.${reset}"
  exit 1
else
  reset
fi

packages="gcc git neovim wget zsh nodejs unzip"

# Function to check if a package is installed
package_installed() {
  if command -v "$1" &>/dev/null; then
    return 0
  else
    return 1
  fi
}


# Detect the package manager
if package_installed dnf; then
  # Use DNF (Fedora)
  sudo dnf install -y ${packages}
elif package_installed pacman; then
  # Use Pacman (Arch Linux)
  sudo pacman -Sy --noconfirm ${packages}
elif package_installed apt; then
  # Use APT (Debian/Ubuntu)
  sudo apt install -y ${packages}
elif package_installed zipper; then
  # Use Zypper (openSUSE)
  sudo zypper install -y ${packages}
elif package_installed apk; then
  # Use APK (Alpine Linux)
  sudo apk add --no-cache ${packages}
else
  echo "${bold}${red}Could not detect a compatible package manager on your system.${reset}"
  exit 1
fi

# Copy config files
cp ${workdir}/zsh/.zshrc ~/.zshrc
cp ${workdir}/zsh/.p10k.zsh ~/.p10k.zsh
cp ${workdir}/zsh/.fzf.zsh ~/.fzf.zsh


# Install Oh My Zsh
echo y | sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh 2>/dev/null) --unattended"  >/dev/null 2>&1
# Install Powerlevel10k theme for Oh My Zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k &> /dev/null

# Install plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting &> /dev/null

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &> /dev/null
~/.fzf/install --all --no-fish --no-update-rc &> /dev/null

# Install auto suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &> /dev/null

# Install nvchad
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
# TODO: set nvchad custom config

# Set Zsh as the default shell
if package_installed lchsh; then
  echo -e -n "$(which zsh)\n" | sudo lchsh $(whoami)
elif package_installed chsh; then
  chsh -s $(which zsh)
else
  echo "${bold}${red}Could not detect chsh, using usermod command.${reset}"
  sudo usermod -s $(which zsh) $(whoami) &> /dev/null
fi

echo "${bold}${blue}Run \"p10k configure\" to change the Powerlevel10k prompt configuration.${reset}"
echo "${bold}${green}Installation completed.${reset}"
zsh