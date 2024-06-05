#!/usr/bin/env bash

# Package requirements: grim, slurp and wl-clipboard  

# Takes a screenshot and saves it to clipboard.
# If an extra argument is passed, the screenshot is saved to that location too.

if [ -z "$1" ]
then
	grim -g "$(slurp -w 0)" - | wl-copy
	_notif_msg="Screenshot saved to clipboard"
else
	grim -g "$(slurp -w 0)" -t png $1
	wl-copy < $1
	_notif_msg="Screenshot saved to $1"
fi

notify-send -h int:transient:1 'Screenshot' "$_notif_msg" --icon=emblem-photos
