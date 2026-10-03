#!/usr/bin/env bash
# Fast fd search ignoring heavy folders, piped into your themed Rofi dmenu
chosen=$(fd --type f --hidden --follow \
    --exclude .git \
    --exclude node_modules \
    --exclude .cache \
    --exclude .local/share/Steam \
    . ~ | rofi -dmenu -config ~/.config/rofi/config.rasi -p "Files")

[ -n "$chosen" ] && xdg-open "$chosen"
