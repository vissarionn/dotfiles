#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Starting Dotfiles Setup..."

# Helper function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# -----------------------------------------------------------------------------
# 1. Dependency Checks & Installations
# -----------------------------------------------------------------------------
echo "==> Checking dependencies..."

# DankMaterialShell
if ! command_exists dms; then
  echo "--> Installing DankMaterialShell..."
  curl -fsSL https://install.danklinux.com | sh
else
  echo "--> DankMaterialShell is already installed."
fi

# Hyprland
if ! command_exists Hyprland; then
  echo "--> Installing Hyprland..."
  yay -S --needed hyprland
else
  echo "--> Hyprland is already installed."
fi

# Rofi
if ! command_exists rofi; then
  echo "--> Installing Rofi (rofi-wayland)..."
  yay -S --needed rofi-wayland
else
  echo "--> Rofi is already installed."
fi

# skwd-wall-v2
if ! command_exists skwd-walld; then
  echo "--> Installing skwd-wall-v2..."
  yay -S --needed skwd-wall-v2-bin skwd-lens-bin

  echo "--> Enabling skwd-walld user service..."
  systemctl --user daemon-reload
  systemctl --user enable --now skwd-walld.service
else
  echo "--> skwd-wall-v2 is already installed."
fi

# SDDM
if ! command_exists sddm; then
  echo "--> Installing SDDM..."
  yay -S --needed sddm
else
  echo "--> SDDM is already installed."
fi

# -----------------------------------------------------------------------------
# 2. Optional Dependency: NiflVeil
# -----------------------------------------------------------------------------
read -p "Do you want to install NiflVeil? (y/N): " choice
case "$choice" in
  y|Y )
    echo "--> Installing NiflVeil..."
    if ! command_exists cargo; then
      echo "Error: cargo is required to build NiflVeil. Please install rust/cargo first."
    else
      TEMP_DIR=$(mktemp -d)
      git clone https://github.com/Mauitron/NiflVeil.git
      cd NiflVeil/niflveil
      cargo build --release
      sudo cp target/release/niflveil /usr/local/bin/
      cd ~
      rm -rf NiflVeil
      echo "--> NiflVeil has successfully been installed."
    fi
    ;;
  * )
    echo "--> Skipping NiflVeil installation."
    ;;
esac

# -----------------------------------------------------------------------------
# 3. Copy User Configs (Replaces existing configs in ~/.config)
# -----------------------------------------------------------------------------
echo "==> Copying application configurations to ~/.config..."
mkdir -p ~/.config

CONFIG_TARGETS=("DankMaterialShell" "kitty" "rofi" "hypr" "skwd-wall-v2" "fastfetch")

for cfg in "${CONFIG_TARGETS[@]}"; do
  if [ -d "$DOTFILES_DIR/configs/$cfg" ] || [ -f "$DOTFILES_DIR/configs/$cfg" ]; then
    echo "--> Replacing ~/.config/$cfg..."
    rm -rf "$HOME/.config/$cfg"
    cp -r "$DOTFILES_DIR/configs/$cfg" "$HOME/.config/"
  else
    echo "--> Warning: $DOTFILES_DIR/configs/$cfg not found, skipping."
  fi
done

# -----------------------------------------------------------------------------
# 4. Copy System Assets (Requires Sudo)
# -----------------------------------------------------------------------------
echo "==> Copying system assets (requires root permissions)..."

# Fontconfig
if [ -d "$DOTFILES_DIR/fontconfig" ]; then
  echo "--> Replacing /usr/share/fontconfig..."
  sudo rm -rf /usr/share/fontconfig
  sudo cp -r "$DOTFILES_DIR/fontconfig" /usr/share/
fi

# Fonts
if [ -d "$DOTFILES_DIR/fonts" ]; then
  echo "--> Copying fonts to /usr/share/fonts..."
  sudo mkdir -p /usr/share/fonts
  sudo cp -r "$DOTFILES_DIR/fonts/." /usr/share/fonts/
  sudo fc-cache -fv
fi

# SDDM Themes
if [ -d "$DOTFILES_DIR/sddm_themes" ]; then
  echo "--> Copying SDDM themes to /usr/share/sddm/themes..."
  sudo mkdir -p /usr/share/sddm/themes
  sudo cp -r "$DOTFILES_DIR/sddm_themes/." /usr/share/sddm/themes/
fi

echo "==> Setup completed successfully!"
echo "Please reboot for all changes to apply."
