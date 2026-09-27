# Arch-Hyprland-Dots

Configuration files that I use for my Hyprland installation.

My neovim configs live in [matiasgonzalezz0/Neovim-Config](https://github.com/matiasgonzalezz0/Neovim-Config).

## How it works

The configs **live in this repo**. `~/.config/<app>` and `~/.zshrc` are symlinks pointing here, so editing a config edits the file in the repo, and changes show up in `git status` directly. There is no copy/sync step.

Consequences:

- Don't move or delete this repo folder: the symlinks would break and the apps would lose their configs. If it has to move, run `./link.sh` again from the new location.
- The checked-out branch is what the apps use. Switching branches changes the live configs.

## Layout

| Path | Linked to | Notes |
|---|---|---|
| `config/<app>/` | `~/.config/<app>` | cava, fastfetch, hypr, kitty, MangoHud, rofi, swaync, wallust, waybar, wlogout |
| `.zshrc` | `~/.zshrc` | |
| `usr_scripts/` | copied to `/usr/local/bin` | not linked, see below |

The Hyprland config is Lua (`config/hypr/hyprland.lua` and the files next to it).

## Scripts

- `./link.sh` creates the symlinks. Anything already at a target that isn't a symlink is moved to `~/.config-backup/<timestamp>/` first. Safe to run again. To manage a new app, move its folder into `config/`, add it to `_config_names` in `link.sh`, and run it.
- `./install_scripts.sh` shows a checklist of the scripts in `usr_scripts/` (marked new / changed / same compared to `/usr/local/bin`) and installs the ticked ones with `sudo`. It never deletes anything.

### Requirements

A fresh Arch install is very bare, so:

- `link.sh`: only `bash` and `coreutils`, present on every install.
- `install_scripts.sh`: also needs `whiptail` (package `libnewt`) and `sudo` (not in Arch's base install), plus `diffutils`.
- `git` to clone this repo in the first place.

```sh
sudo pacman -S --needed git libnewt sudo diffutils
```

These are only the scripts' requirements. The programs the configs are for (Hyprland, waybar, rofi, wallust, ...) are installed separately.

`/usr/local/bin` also contains files that don't belong here (distro-provided ones like the CachyOS `mkinitcpio` wrapper, and private work scripts). Scripts are therefore brought from the machine into `usr_scripts/` **by hand**, only the ones that are mine.

## Generated files (gitignored)

These are rewritten by wallust (on wallpaper change) or by scripts, so they are not tracked:

- wallust outputs, whose sources are the templates in `config/wallust/templates/` (see `config/wallust/wallust.toml`): `cava/config`, `kitty/kitty.conf`, `hypr/wallust/wallust-hyprland.conf`, `rofi/wallust/colors-rofi.rasi`, `swaync/wallust/colors-wallust.css`, `waybar/wallust/colors-waybar.css`. To change kitty or cava settings, edit the template, not the generated file.

On a fresh install, kitty and cava have no config until wallust runs once (e.g. by setting a wallpaper).
