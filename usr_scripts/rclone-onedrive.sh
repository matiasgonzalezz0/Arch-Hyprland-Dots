#!/usr/bin/env bash

# Mounts OneDrive using rclone

mkdir -p ~/OneDrive
rclone --vfs-cache-mode writes mount OneDrive: ~/OneDrive & 
notify-send "OneDrive connected" "Microsoft OneDrive successfully mounted."
