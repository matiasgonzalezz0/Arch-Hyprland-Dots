----------------
--- MONITORS ---
----------------

-- Dynamic multi-monitor + workspace layout.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Behaviour:
--   * 0 externals  -> laptop only, workspaces 1-10.
--   * 1 external   -> external is primary (ws 1-10), laptop gets 11-20.
--   * 2-3 externals-> generalised by priority, blocks of 5.
--   * all 4 known  -> reproduce the saved layout exactly (positions + 5 ws each).
-- Monitors are matched by connector name. Layout is (re)applied on start and on hotplug.

local LAPTOP = "eDP-2"

-- Laptop's own spec.
local laptopSpec      = { mode = "2880x1800@120", scale = 1.5 }
-- Laptop position in the full saved-4 layout (centered below HDMI-A-1).
local laptopSavedPos  = "0x1440"

-- Known externals in PRIORITY order (first = preferred primary). `savedPos` is the
-- absolute position used ONLY when the full saved-4 set is present.
local externals = {
    { name = "DP-3",     mode = "2560x1440@144", scale = 1, savedPos = "2560x0" },
    { name = "DP-1",     mode = "1920x1080@144", scale = 1, savedPos = "5120x0" },
    { name = "HDMI-A-1", mode = "2560x1440@144", scale = 1, savedPos = "0x0"    },
}

-- Safety net at config-eval so the laptop is always usable before the first apply().
hl.monitor({ output = LAPTOP, mode = laptopSpec.mode, position = "auto", scale = laptopSpec.scale })
hl.monitor({ output = "",     mode = "preferred",     position = "auto", scale = "auto" })

-- ---------------------------------------------------------------------------

local function parseMode(mode)
    local w, h, r = mode:match("^(%d+)x(%d+)@([%d%.]+)")
    if not w then w, h = mode:match("^(%d+)x(%d+)") end
    return tonumber(w), tonumber(h), tonumber(r)
end

-- The monitor's own preferred mode (falls back to the largest one it advertises).
local function preferredMode(mon)
    local best
    for _, m in ipairs(mon.available_modes or {}) do
        if m.preferred then return m end
        local area, bestArea = m.width * m.height, best and (best.width * best.height) or -1
        if area > bestArea or (area == bestArea and m.refresh_rate > best.refresh_rate) then
            best = m
        end
    end
    return best
end

-- Monitors are matched by connector name, so a different screen plugged into a known
-- port would inherit that port's hardcoded mode and be driven at something it cannot
-- display (black screen / "no signal"). Only keep the hardcoded mode if the panel
-- actually advertises it; otherwise fall back to its preferred mode.
-- Returns the mode string to use and its pixel width (for layout positioning).
local function resolveMode(mon, wanted)
    local w, h, r = parseMode(wanted)
    if w then
        for _, m in ipairs(mon.available_modes or {}) do
            if m.width == w and m.height == h
                and (not r or math.abs(m.refresh_rate - r) < 1.5) then
                return wanted, w
            end
        end
    end
    local p = preferredMode(mon)
    return "preferred", (p and p.width) or mon.width or 1920
end

local function apply()
    -- Map connected monitors by connector name.
    local map = {}
    for _, m in ipairs(hl.get_monitors()) do
        map[m.name] = m
    end

    local known = {}
    for _, e in ipairs(externals) do known[e.name] = true end

    -- Present externals, known ones first in priority order, then unknown ones.
    local present = {}
    for _, e in ipairs(externals) do
        if map[e.name] then
            local mode, width = resolveMode(map[e.name], e.mode)
            present[#present + 1] = {
                name = e.name, mode = mode, scale = e.scale, savedPos = e.savedPos,
                width = width,
            }
        end
    end
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= LAPTOP and not known[m.name] then
            local p = preferredMode(m)
            present[#present + 1] = {
                name = m.name, mode = "preferred", scale = m.scale or 1, savedPos = nil,
                width = (p and p.width) or m.width or 1920,
            }
        end
    end

    local hasLaptop = map[LAPTOP] ~= nil
    local n         = #present + (hasLaptop and 1 or 0)
    if n == 0 then return end
    local blockSize = (n <= 2) and 10 or 5

    -- Is the full saved-4 set present (all known externals + laptop, no extras)?
    local fullSaved = hasLaptop and (#present == #externals)
    for _, e in ipairs(externals) do
        if not map[e.name] then fullSaved = false end
    end

    -- Build the final monitor layout (output, mode, position, scale) in screen order.
    -- (We're already in the Lua context, so call hl.monitor / hl.workspace_rule
    -- directly — `hyprctl keyword` is rejected by the Lua parser.)
    local layout = {}
    local laptopMode = hasLaptop and resolveMode(map[LAPTOP], laptopSpec.mode) or laptopSpec.mode
    if fullSaved then
        -- `present` is the known externals in priority order here, with modes already resolved.
        for _, e in ipairs(present) do
            layout[#layout + 1] = { output = e.name, mode = e.mode, pos = e.savedPos, scale = e.scale }
        end
        layout[#layout + 1] = { output = LAPTOP, mode = laptopMode, pos = laptopSavedPos, scale = laptopSpec.scale }
    else
        local x = 0
        for _, e in ipairs(present) do
            layout[#layout + 1] = { output = e.name, mode = e.mode, pos = x .. "x0", scale = e.scale }
            x = x + math.floor(e.width / e.scale + 0.5)
        end
        if hasLaptop then
            layout[#layout + 1] = { output = LAPTOP, mode = laptopMode, pos = x .. "x0", scale = laptopSpec.scale }
        end
    end

    -- Apply in two passes to avoid transient overlaps (Hyprland warns "monitors
    -- colliding / undefined behaviour" if a monitor is momentarily placed where
    -- another still sits). First park every monitor in a far, non-overlapping slot,
    -- then move each to its final position — no intermediate state ever overlaps.
    for i, m in ipairs(layout) do
        hl.monitor({ output = m.output, mode = m.mode, position = (i * 50000) .. "x0", scale = m.scale })
    end
    for _, m in ipairs(layout) do
        hl.monitor({ output = m.output, mode = m.mode, position = m.pos, scale = m.scale })
    end

    -- Screen order for workspace blocks: externals (priority) then laptop last.
    local screens = {}
    for _, e in ipairs(present) do screens[#screens + 1] = e.name end
    if hasLaptop then screens[#screens + 1] = LAPTOP end

    local ws = 1
    for _, name in ipairs(screens) do
        for _ = 1, blockSize do
            hl.workspace_rule({ workspace = ws, monitor = name, persistent = true })
            ws = ws + 1
        end
    end

    -- Drop persistence from any leftover workspaces and pin them to the primary screen,
    -- so they don't linger as empty persistent workspaces on a removed monitor.
    local primary = (present[1] and present[1].name) or LAPTOP
    for w = ws, 20 do
        hl.workspace_rule({ workspace = w, monitor = primary, persistent = false })
    end

    -- Keep XWayland's notion of the primary output in sync (best-effort).
    hl.exec_cmd(string.format('command -v xrandr >/dev/null 2>&1 && xrandr --output %s --primary', primary))
end

-- Debounce hotplug bursts (docks emit several monitor events at once).
local armed = false
local function schedule()
    if armed then return end
    armed = true
    hl.timer(function()
        armed = false
        apply()
    end, { timeout = 300, type = "oneshot" })
end

hl.on("hyprland.start",  function() schedule() end)
hl.on("monitor.added",   function() schedule() end)
hl.on("monitor.removed", function() schedule() end)

-- Also apply at config-eval time. On a live `hyprctl reload` the hyprland.start
-- event does NOT re-fire, so this is what re-applies the layout on reload; on initial
-- boot hyprland.start / monitor.added re-trigger it once monitors are fully enumerated.
schedule()
