#!/bin/bash

# Copies files and sets up all dots.

_user=$(whoami)

cp -r ./config/* /home/$_user/.config/

# Link the style and config of waybar
ln -sf /home/$_user/.config/waybar/style/\[Dark\]\ Latte-Wallust\ combined.css \
	/home/$_user/.config/waybar/style.css
ln -sf /home/$_user/.config/waybar/configs/\[TOP\]\ Default_v2 \
	/home/$_user/.config/waybar/config

cp ./.zshrc /home/$_user/

sudo cp ./usr_scripts/* /usr/local/bin
