----------------
--- MONITORS ---
----------------

-- Picks the monitor layout for the machine this config is running on:
--   * notebook (has a built-in eDP panel) -> monitors_notebook.lua
--   * desktop PC                         -> monitors_desktop.lua
-- Each profile may return a table of helpers (e.g. toggle_tv, used in keybindings.lua).

local function hasLaptopPanel()
    local p = io.popen("ls /sys/class/drm 2>/dev/null")
    if not p then return false end
    local out = p:read("*a") or ""
    p:close()
    return out:find("%-eDP%-") ~= nil
end

local profile = require(hasLaptopPanel() and "monitors_notebook" or "monitors_desktop")
return type(profile) == "table" and profile or {}
