-------------------
--- MY PROGRAMS ---
-------------------

-- See https://wiki.hypr.land/Configuring/Keywords/

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show drun"

-------------------
--- KEYBINDINGS ---
-------------------

-- See https://wiki.hypr.land/Configuring/Keywords/
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + RETURN",            hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",                 hl.dsp.window.close())
-- hl.bind(mainMod .. " + M",              hl.dsp.exit())
hl.bind(mainMod .. " + V",                 hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R",                 hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",                 hl.dsp.window.pseudo())        -- dwindle
hl.bind(mainMod .. " + T",                 hl.dsp.layout("togglesplit"))  -- dwindle
hl.bind(mainMod .. " + SHIFT + BACKSPACE", hl.dsp.exec_cmd("wlogout"))
hl.bind("CTRL + ALT + L",                  hl.dsp.exec_cmd("~/.config/hypr/scripts/LockScreen.sh"))

-- Applications
hl.bind(mainMod .. " + U",         hl.dsp.exec_cmd("zen-browser"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("zen-browser --private-window"))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(fileManager))

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down"  }))

-- Move window with mainMod + hjkl
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left"  }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up"    }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down"  }))

-- Switch workspaces with mainMod + [0-9] and mainMod + CTRL + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9] and mainMod + SHIFT + CTRL + [0-9]
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key,                hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,        hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. key,         hl.dsp.focus({ workspace = i + 10 }))
    hl.bind(mainMod .. " + SHIFT + CTRL + " .. key, hl.dsp.window.move({ workspace = i + 10 }))
end

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),                       { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),                             { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),                         { locked = true })

-- Switch keyboard layout (to get the name use "hyprctl devices")
-- hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("/usr/local/bin/switch_kbd_layout.sh royuan-gaming-keyboard"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("/usr/local/bin/switch_kbd_layout.sh sofle-eyelash-sofle-keyboard"))

-- Screenshot
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/usr/local/bin/take_sc.sh ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%m-%s).png"))

-- Restart Waybar and Hyprpaper
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("/usr/local/bin/restart_waybar.sh && /usr/local/bin/restart_swaync.sh"))
