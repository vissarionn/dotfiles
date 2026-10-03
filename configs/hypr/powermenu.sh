#!/usr/bin/env bash

# Options
shutdown="Shutdown (P)"
reboot="Reboot (R)"
lock="Lock (L)"
suspend="Suspend (S)"
logout="Log Out (X)"

# Rofi command
ROFI_CMD="rofi -dmenu -i -p 'Power Menu' -theme ~/.config/rofi/powermenu.rasi"

# Launch rofi with single key accelerators
chosen=$(printf "$shutdown\n$reboot\n$lock\n$suspend\n$logout" | $ROFI_CMD \
    -kb-custom-1 "p" \
    -kb-custom-2 "r" \
    -kb-custom-3 "l" \
    -kb-custom-4 "s" \
    -kb-custom-5 "x")

# Get exit code
status=$?

# Match action based on status code OR selected string
case "$status" in
    10) systemctl poweroff ;;                      # Pressed 'p'
    11) systemctl reboot ;;                        # Pressed 'r'
    12) loginctl lock-session ;;                   # Pressed 'l'
    13) systemctl suspend ;;                       # Pressed 's'
    14) pkill -15 Hyprland || hyprctl dispatch exit ;; # Pressed 'x'
    0)  # Selected via Enter / Mouse
        case "$chosen" in
            "$shutdown") systemctl poweroff ;;
            "$reboot")   systemctl reboot ;;
            "$lock")     loginctl lock-session ;;
            "$suspend")  systemctl suspend ;;
            "$logout")   pkill -15 Hyprland || hyprctl dispatch exit ;;
        esac
        ;;
esac
