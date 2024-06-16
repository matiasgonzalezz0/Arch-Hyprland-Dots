#!/usr/bin/env bash

# Copies current dots and saves them to this repository.
# The files/directories are the ones stored in the "_config_names" array.
# It also copies files outside of ".config", like ".zshrc".
# The "usr_scripts" files are copied from "/usr/local/bin/"
# ALL PREVIOUS DOTS STORED IN THIS REPOSITORY WILL BE DELETED

_user=$(whoami)

rm -r ./config/*

_config_names=(
	"cava"
	"fastfetch"
	"hypr"
	"kitty"
	"MangoHud"
	"rofi"
	"spotify-flags.conf"
	"swaync"
	"wallust"
	"waybar"
	"wlogout"
)

for _name in ${_config_names[@]}; do
	cp -r /home/$_user/.config/$_name ./config/
done

cp /home/$_user/.zshrc .

rm -r ./usr_scripts/*

cp /usr/local/bin/* ./usr_scripts/

echo "Local repository files updated."
