#!/usr/bin/env bash

# Launches application after some time. This fixes an issue I had with programs not launching in the correct workspace.

sleep 2s

hyprctl dispatch exec -- [ workspace 17 silent ] ferdium &
# hyprctl dispatch exec -- [ workspace 19 ] kitty --hold btop &
# hyprctl dispatch exec -- [ workspace 20 silent ] spotify &
hyprctl dispatch exec -- [ workspace 20 silent ] spotify --enable-features=UseOzonePlatform --ozone-platform=wayland &
