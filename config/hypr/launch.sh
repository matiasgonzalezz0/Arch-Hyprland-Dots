#!/usr/bin/env bash

# Launches application after some time. This fixes an issue I had with programs not launching in the correct workspace.

sleep 2s

# Notebook only (detected by its built-in eDP panel)
if compgen -G '/sys/class/drm/*-eDP-*' >/dev/null; then
    # Clear SDDM ghost cursor left on screen after login
    (hyprctl dispatch 'hl.dsp.dpms({action="off"})' && sleep 1 && hyprctl dispatch 'hl.dsp.dpms({action="on"})') &

    rog-control-center &
fi

# hyprctl dispatch exec -- [ workspace 17 silent ] ferdium &
# hyprctl dispatch exec -- [ workspace 20 silent ] tidal-hifi --enable-features=UseOzonePlatform --ozone-platform=wayland &

# radeon-profile &
# easyeffects &
