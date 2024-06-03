#!/bin/bash

# Switches the keyboard layout and saves it to .cache.

if [ -z "$1" ]; then
	echo "Usage: switch_kbd_layout.sh device_name"
	exit 1
fi

hyprctl switchxkblayout $1 next

_kbd_layout=$(/usr/local/bin/get_kbd_layout.sh $1)

notify-send -h int:transient:1 --expire-time=1000 'Keyboard Layout' "Changed to $_kbd_layout" --icon=preferences-desktop-keyboard
echo $_kbd_layout > ~/.cache/kbd_layout
