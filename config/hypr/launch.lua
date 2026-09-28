-----------------
--- AUTOSTART ---
-----------------

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

local keyboard = "Sofle"

hl.on("hyprland.start", function()
    -- exec-once = $terminal
    -- exec-once = nm-applet &
    -- exec-once = waybar & hyprpaper & firefox
    hl.exec_cmd("waybar")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("swaync")
    -- Note: originally `exec` (re-runs on reload) — check for a hyprland.reload event if needed
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("/usr/local/bin/get_kbd_layout.sh " .. keyboard .. " > ~/.cache/kbd_layout")
    -- hl.exec_cmd("/usr/local/bin/rclone-onedrive.sh")

    -- Note: the XWayland primary output is set dynamically in monitors.lua (apply()).

    -- Autostart applications
    -- hl.exec_cmd("firefox https://web.whatsapp.com/")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/launch.sh")
end)
