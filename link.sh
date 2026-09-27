#!/usr/bin/env bash

# Symlinks the configs in this repo into place, so the files live in the repo.
# Anything already at a target that isn't a symlink is moved to
# ~/.config-backup/<timestamp>/ first. Safe to run again.

set -euo pipefail

_repo="$(cd "$(dirname "$0")" && pwd)"
_backup="$HOME/.config-backup/$(date +%Y%m%d-%H%M%S)"

_config_names=(
	"cava"
	"fastfetch"
	"hypr"
	"kitty"
	"MangoHud"
	"rofi"
	"swaync"
	"wallust"
	"waybar"
	"wlogout"
)

link() {
	local _src="$_repo/$1" _dst="$2"

	if [[ ! -e "$_src" ]]; then
		echo "missing: $1 does not exist in the repo, skipping $_dst (move it into the repo first)" >&2
		return
	fi
	if [[ -L "$_dst" && "$(readlink "$_dst")" == "$_src" ]]; then
		echo "ok:     $_dst"
		return
	fi
	if [[ -e "$_dst" && ! -L "$_dst" ]]; then
		mkdir -p "$_backup"
		mv "$_dst" "$_backup/"
		echo "backup: $_dst -> $_backup/"
	fi
	mkdir -p "$(dirname "$_dst")"
	ln -sfn "$_src" "$_dst"
	echo "linked: $_dst -> $_src"
}

for _name in "${_config_names[@]}"; do
	link "config/$_name" "$HOME/.config/$_name"
done

link ".zshrc" "$HOME/.zshrc"
