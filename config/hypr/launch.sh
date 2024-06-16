#!/usr/bin/env bash

# Launches application after some time. This fixes an issue I had with programs not launching in the correct workspace.

sleep 2s

hyprctl dispatch exec -- [ workspace 19 ] kitty --hold btop &
hyprctl dispatch exec -- [ workspace 16 silent ] firefox -new-window 'https://web.whatsapp.com/' &
hyprctl dispatch exec -- [ workspace 20 silent ] spotify --enable-features=UseOzonePlatform --ozone-platform=wayland &
