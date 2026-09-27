#!/usr/bin/env bash

# Pick which scripts from usr_scripts/ to install into /usr/local/bin.
# New and changed scripts start ticked. Never deletes anything.
# Run as your normal user; sudo is only used for the copy.

set -euo pipefail

_src="$(cd "$(dirname "$0")" && pwd)/usr_scripts"
_dst="${DST:-/usr/local/bin}"

_items=()
for _file in "$_src"/*; do
	_name=$(basename "$_file")
	if [[ ! -e "$_dst/$_name" ]]; then
		_items+=("$_name" "new" ON)
	elif cmp -s "$_file" "$_dst/$_name"; then
		_items+=("$_name" "same" OFF)
	else
		_items+=("$_name" "changed" ON)
	fi
done

_choice=$(whiptail --title "Install scripts to $_dst" --separate-output \
	--checklist "Space to toggle, Enter to confirm" 20 60 12 \
	"${_items[@]}" 3>&1 1>&2 2>&3) || exit 0

[[ -z "$_choice" ]] && exit 0

while read -r _name; do
	sudo install -m 755 "$_src/$_name" "$_dst/$_name"
	echo "installed $_name"
done <<<"$_choice"
