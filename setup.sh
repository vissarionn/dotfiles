#!/usr/bin/env bash

r='\033[0;31m'
g='\033[0;32m'
y='\033[1;33m'
b='\033[0;34m'
nc='\033[0m'

set -e

echo "==> Starting Dotfiles Setup..."

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

echo "==> Checking dependencies..."

if ! command_exists dms; then
  echo "${g}--> Installing DankMaterialShell...${nc}"
  curl -fsSL https://install.danklinux.com | sh
else
  echo "${g}--> DankMaterialShell is already installed.${nc}"
fi

if ! command_exists Hyprland; then
  echo "${g}--> Installing Hyprland...${nc}"
  yay -S --needed hyprland
else
  echo "${g}--> Hyprland is already installed.${nc}"
fi

if ! command_exists rofi; then
  echo "${g}--> Installing Rofi (rofi-wayland)...${nc}"
  yay -S --needed rofi-wayland
else
  echo "${g}--> Rofi is already installed.${nc}"
fi

if ! command_exists skwd-walld; then
  echo "${g}--> Installing skwd-wall-v2...${nc}"
  yay -S --needed skwd-wall-v2-bin skwd-lens-bin

  echo "${g}--> Enabling skwd-walld user service...${nc}"
  systemctl --user daemon-reload
  systemctl --user enable --now skwd-walld.service
else
  echo "${g}--> skwd-wall-v2 is already installed.${nc}"
fi

if ! command_exists sddm; then
  echo "${g}--> Installing SDDM...${nc}"
  yay -S --needed sddm
else
  echo "${g}--> SDDM is already installed.${nc}"
fi

if [ ! -d "$HOME/qylock" ]; then
  echo "${g}--> Installing qylock SDDM theme...${nc}"
  git clone https://github.com/Darkkal44/qylock/ "$HOME/qylock"
  pushd "$HOME/qylock" > /dev/null
  chmod +x sddm.sh
  ./sddm.sh
  popd > /dev/null
else
  echo "${g}--> qylock SDDM theme is already installed.${nc}"
fi

read -p "${b}Do you want to install NiflVeil? (y/N): ${nc}" choice
case "$choice" in
  y|Y )
    echo "${g}--> Installing NiflVeil...${nc}"
    if ! command_exists cargo; then
      echo "${r}Error: cargo is required to build NiflVeil. Please install rust/cargo first.${nc}"
    else
      TEMP_DIR=$(mktemp -d)
      git clone https://github.com/Mauitron/NiflVeil.git
      cd NiflVeil/niflveil
      cargo build --release
      sudo cp target/release/niflveil /usr/local/bin/
      cd ~
      rm -rf NiflVeil
      echo "${g}--> NiflVeil has successfully been installed.${nc}"
    fi
    ;;
  * )
    echo "${g}--> Skipping NiflVeil installation.${nc}"
    ;;
esac

echo "${b}==> Copying application configurations to ~/.config...${nc}"

CONFIG_TARGETS=("DankMaterialShell" "kitty" "rofi" "hypr" "skwd-wall-v2" "fastfetch")

for cfg in "${CONFIG_TARGETS[@]}"; do
  if [ -d "$HOME/dotfiles/configs/$cfg" ] || [ -f "$HOME/dotfiles/configs/$cfg" ]; then
    echo "${b}--> Replacing ~/.config/$cfg...${nc}"
    rm -rf "$HOME/.config/$cfg"
    cp -r "$HOME/dotfiles/configs/$cfg" "$HOME/.config/"
  else
    echo "${r}--> Warning: $HOME/dotfiles/configs/$cfg not found, skipping.${nc}"
  fi
done

echo "${b}==> Copying system assets (requires root permissions)...${nc}"

if [ -d "$HOME/dotfiles/fontconfig" ]; then
  echo "${b}--> Replacing /usr/share/fontconfig...${nc}"
  sudo rm -rf /usr/share/fontconfig
  sudo cp -r "$HOME/dotfiles/fontconfig" /usr/share/
fi

if [ -d "$HOME/dotfiles/fonts" ]; then
  echo "${b}--> Copying fonts to /usr/share/fonts...${nc}"
  sudo mkdir -p /usr/share/fonts
  sudo cp -r "$HOME/dotfiles/fonts/." /usr/share/fonts/
  sudo fc-cache -fv
fi

if [ -d "$HOME/dotfiles/sddm_themes" ]; then
  echo "${b}--> Copying SDDM themes to /usr/share/sddm/themes...${nc}"
  sudo mkdir -p /usr/share/sddm/themes
  sudo cp -r "$HOME/dotfiles/sddm_themes/." /usr/share/sddm/themes/
fi

echo "${g}==> Setup completed successfully!${nc}"
echo "${g}Please reboot for all changes to apply.${nc}"
