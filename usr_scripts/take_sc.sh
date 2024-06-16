#!/usr/bin/env bash

# Package requirements: grim, slurp and wl-clipboard  

# Takes a screenshot and saves it to clipboard.
# If an extra argument is passed, the screenshot is saved to that location too.

_area_selected=$(slurp -w 0)

if [ -z "$_area_selected" ]; then
	echo "No area selected"
	exit
fi

if [ -z "$1" ]
then
	grim -g "$_area_selected" - | wl-copy
	_notif_msg="Screenshot saved to clipboard"
else
	grim -g "$_area_selected" -t png $1
	wl-copy < $1
	_notif_msg="Screenshot saved to $1"
fi

notify-send -h int:transient:1 'Screenshot' "$_notif_msg" --icon=emblem-photos
