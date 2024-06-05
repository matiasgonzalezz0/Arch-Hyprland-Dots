#!/usr/bin/env bash

# Gets the layout of the keyboard passed as argument.

if [ -z "$1" ]; then
	echo "Usage: get_kbd_layout.sh device_name"
	exit 1
fi

_kbd_layout=$(hyprctl devices -j | gojq -r '.keyboards[] | select(.name == "'"${1}"'") | .active_keymap' | cut -c 1-2 | tr 'A-Z' 'a-z')

echo "${_kbd_layout^^}"
