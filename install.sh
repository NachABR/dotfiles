#!/bin/bash
workdir=$(dirname "$0")

# ANSI escape codes for text formatting
bold=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
reset=$(tput sgr0)
yellow=$(tput setaf 3)

# Function to check if a package is installed
package_installed() {
  command -v "$1" &>/dev/null
}

# Function to install packages based on package manager
install_packages() {
  local packages=("$@")
  local package_manager

  if package_installed dnf; then
    package_manager="sudo dnf install --refresh -y"
  elif package_installed pacman; then
    package_manager="sudo pacman -Sy --noconfirm"
  elif package_installed apt; then
    package_manager="sudo apt install -y"
  elif package_installed zipper; then
    package_manager="sudo zypper install -y"
  elif package_installed apk; then
    package_manager="sudo apk add --update --no-cache"
  else
    echo "${bold}${red}Could not detect a compatible package manager on your system.${reset}"
    exit 1
  fi

  $package_manager "${packages[@]}"
}

# Interactive confirmation
interactive_confirmation() {
  read -p "${bold}This script may modify your shell configuration and cause breaking changes. Do you want to continue? (y/n): " confirm
  [[ "$confirm" != "y" && "$confirm" != "Y" ]] && { echo "${red}Aborted.${reset}"; exit 1; } || reset
}

# Process arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-interactive)
      no_interactive=true
      shift
      ;;
    --overwrite)
      overwrite=true
      shift
      ;;
    *)
      echo "${bold}${red}Invalid argument: $1${reset}"
      exit 1
      ;;
  esac
done

# Interactive confirmation
[[ ! $no_interactive ]] && interactive_confirmation

# List of packages to install
packages=(gcc git neovim wget zsh unzip fastfetch)

# Install packages
install_packages "${packages[@]}"

# Install Oh My Zsh
[[ $overwrite ]] && rm -rf "$ZSH"
echo -e -n | sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh 2>/dev/null) --unattended"

# Install Powerlevel10k theme for Oh My Zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k &> /dev/null

# Install plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting &> /dev/null
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &> /dev/null

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf &> /dev/null
$HOME/.fzf/install --all --no-fish --no-update-rc &> /dev/null

# Copy config files
cp "${workdir}/zsh/.zshrc" $HOME/.zshrc
cp "${workdir}/zsh/.p10k.zsh" $HOME/.p10k.zsh
cp "${workdir}/zsh/.fzf.zsh" $HOME/.fzf.zsh

# Set Zsh as the default shell
if [[ "$SHELL" != *"zsh"* ]]; then
  if package_installed lchsh; then
    echo -e -n "$(which zsh)\n" | sudo lchsh "$(whoami)"
  elif package_installed chsh; then
    chsh -s "$(which zsh)"
  else
    echo "${bold}${yellow}Could not detect chsh, using usermod command.${reset}"
    sudo usermod -s "$(which zsh)" "$(whoami)" &> /dev/null
  fi
fi

echo "${bold}${blue}Run \"p10k configure\" to change the Powerlevel10k prompt configuration.${reset}"
echo "${bold}${green}Installation completed.${reset}"
