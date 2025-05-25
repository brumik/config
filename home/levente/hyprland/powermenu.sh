#!/bin/usr/env sh
echo -e "Suspend\nLogout\nPower Off" | wofi --dmenu --prompt "Power Menu" --insensitive | xargs -r -I{} bash -c 'choice="${1,,}"; [[ $choice == suspend ]] && systemctl suspend || [[ $choice == logout ]] && (hyprctl dispatch exit || swaymsg exit || loginctl terminate-user "$USER") || [[ $choice == power\ off ]] && systemctl poweroff' _ {}
