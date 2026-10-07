-----------------------------
--- MONITORS (DESKTOP PC) ---
-----------------------------

-- Dynamic multi-monitor + workspace layout.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Screens are matched by their EDID description (make/model), NOT by connector
-- name, because connector names (DP-1, DP-3, HDMI-A-1...) differ between machines
-- and ports. To see what each screen reports:  hyprctl monitors all | grep -E '^Monitor|description'
--
-- Behaviour:
--   * Known screens are laid out left -> right by their `slot`, whatever subset is present.
--   * Unknown screens are appended to the right of the known ones.
--   * The laptop panel (if any) sits below the leftmost screen.
--   * The TV is off by default, always placed all the way to the left, and is
--     toggled with toggle_tv() (bound in keybindings.lua).
--   * Workspaces: screens get blocks of 5 in priority order (list order below, then
--     unknown, laptop, TV); with 1-2 screens the blocks are 10 wide. The last screen
--     also takes the rest up to 20.
-- Layout is (re)applied on start, on reload and on hotplug.

local LAPTOP     = "eDP-2"
local laptopSpec = { mode = "2880x1800@120", scale = 1.5 }

-- Known screens in PRIORITY order (first = primary). `match` is a substring of the
-- monitor's description; `slot` is its physical position, 1 = leftmost.
local screens = {
    { match = "MSI MAG 275QF", mode = "2560x1440@180", scale = 1, slot = 2 }, -- center (main)
    { match = "LS27AG32x",     mode = "1920x1080@165", scale = 1, slot = 3 }, -- right  (Samsung Odyssey G3)
    { match = "LS27FG51x",     mode = "2560x1440@180", scale = 1, slot = 1 }, -- left   (Samsung Odyssey G5)
}

-- Optional extra screen, off unless toggled on. `desc` must be the start of its
-- description (used for a desc: rule so it can be re-enabled while it's disabled
-- and therefore missing from hl.get_monitors()). Never leave it empty: "desc:"
-- with an empty string matches every monitor.
-- `w` is its pixel width, only used to make room for it before it's re-enabled.
-- resolveMode falls back to the fastest 4K rate the driver actually offers.
-- `edid` is the product name stored in its EDID, used to find its connector while
-- it's disabled (see redetectTv).
local TV = { desc = "Technical Concepts Ltd Beyond TV", edid = "Beyond TV",
             mode = "3840x2160@144", scale = 2, w = 3840 }
assert(TV.desc ~= "", "TV.desc must not be empty")
local TV_RULE = "desc:" .. TV.desc

-- TV on/off state survives `hyprctl reload` but resets to off on a new login.
local TV_STATE = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-tv-enabled"

local function tvWanted()
    local f = io.open(TV_STATE, "r")
    if f then f:close() return true end
    return false
end

local function setTvWanted(on)
    if on then
        local f = io.open(TV_STATE, "w")
        if f then f:write("1") f:close() end
    else
        os.remove(TV_STATE)
    end
end

-- Safety net at config-eval so screens are usable before the first apply().
-- The TV is deliberately NOT disabled here, even when unwanted: it's left enabled so
-- Hyprland takes its CRTC over from the boot console, and apply() then turns it off.
-- Starting it disabled leaves that CRTC lit in the kernel while aquamarine 0.15 hands
-- it to another screen, whose modesets then fail (EINVAL) -> a random monitor stays
-- dark or frozen on the console. See hyprwm/aquamarine#428.
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

-- Only use the wanted mode if the panel actually advertises it (otherwise it would
-- be driven at something it can't display -> black screen). If that exact refresh
-- isn't offered, use the highest advertised refresh at the same resolution that
-- doesn't exceed it; failing that, the preferred mode.
-- Returns the mode string plus its pixel width/height (for layout positioning).
local function resolveMode(mon, wanted)
    local w, h, r = parseMode(wanted)
    if w then
        local best
        for _, m in ipairs(mon.available_modes or {}) do
            if m.width == w and m.height == h then
                if not r or math.abs(m.refresh_rate - r) < 1.5 then
                    return wanted, w, h
                end
                if m.refresh_rate < r and (not best or m.refresh_rate > best.refresh_rate) then
                    best = m
                end
            end
        end
        if best then
            return string.format("%dx%d@%.2f", w, h, best.refresh_rate), w, h
        end
    end
    local p = preferredMode(mon)
    return "preferred", (p and p.width) or mon.width or 1920, (p and p.height) or mon.height or 1080
end

local function isTv(mon)
    return (mon.description or ""):sub(1, #TV.desc) == TV.desc
end

local function knownScreen(mon)
    local desc = mon.description or ""
    for i, s in ipairs(screens) do
        if desc:find(s.match, 1, true) then return s, i end
    end
end

local function apply()
    local wantTv = tvWanted()

    local known, unknown, laptop, tv = {}, {}, nil, nil
    for _, m in ipairs(hl.get_monitors()) do
        if m.name == LAPTOP then
            local mode, w, h = resolveMode(m, laptopSpec.mode)
            laptop = { name = m.name, mode = mode, scale = laptopSpec.scale, w = w, h = h }
        elseif isTv(m) then
            local mode, w, h = resolveMode(m, TV.mode)
            tv = { name = m.name, mode = mode, scale = TV.scale, w = w, h = h }
        else
            local s, prio = knownScreen(m)
            if s then
                local mode, w, h = resolveMode(m, s.mode)
                known[#known + 1] = { name = m.name, mode = mode, scale = s.scale, w = w, h = h,
                                      slot = s.slot, prio = prio }
            else
                local p = preferredMode(m)
                unknown[#unknown + 1] = { name = m.name, mode = "preferred", scale = m.scale or 1,
                                          w = (p and p.width) or m.width or 1920,
                                          h = (p and p.height) or m.height or 1080 }
            end
        end
    end

    -- Turn the TV off if it's on but not wanted; this fires monitor.removed, which
    -- re-runs apply() without it.
    if tv and not wantTv then
        hl.monitor({ output = TV_RULE, disabled = true })
        tv = nil
    end

    -- Physical row, left -> right: TV at x=0, then known screens by slot, then unknown.
    local row = {}
    table.sort(known, function(a, b) return a.slot < b.slot end)
    for _, e in ipairs(known)   do row[#row + 1] = e end
    for _, e in ipairs(unknown) do row[#row + 1] = e end

    local layout, x = {}, 0
    if tv then
        layout[#layout + 1] = { output = tv.name, mode = tv.mode, pos = "0x0", scale = tv.scale }
        x = math.floor(tv.w / tv.scale + 0.5)
    elseif wantTv then
        -- Wanted but disabled (so not listed, width unknown): leave room for it using
        -- the width hint; it's enabled at 0x0 once the others have moved (below).
        x = math.floor(TV.w / TV.scale + 0.5)
    end
    local rowStart = x
    for _, e in ipairs(row) do
        layout[#layout + 1] = { output = e.name, mode = e.mode, pos = x .. "x0", scale = e.scale }
        x = x + math.floor(e.w / e.scale + 0.5)
    end
    if laptop then
        local first = row[1]
        local y = first and math.floor(first.h / first.scale + 0.5) or 0
        layout[#layout + 1] = { output = laptop.name, mode = laptop.mode, pos = rowStart .. "x" .. y, scale = laptop.scale }
    end

    if #layout == 0 then return end

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
    if wantTv and not tv then
        -- If it's connected this fires monitor.added and apply() runs again with it present.
        hl.monitor({ output = TV_RULE, disabled = false, mode = TV.mode, position = "0x0", scale = TV.scale })
    end

    -- Workspace blocks in priority order: known screens (list order), unknown, laptop, TV.
    table.sort(known, function(a, b) return a.prio < b.prio end)
    local order = {}
    for _, e in ipairs(known)   do order[#order + 1] = e.name end
    for _, e in ipairs(unknown) do order[#order + 1] = e.name end
    if laptop then order[#order + 1] = laptop.name end
    if tv     then order[#order + 1] = tv.name end

    -- The last screen also takes whatever is left up to 20, so e.g. with 3 screens the
    -- blocks are 1-5, 6-10, 11-20 (and 11-15 / 16-20 once the TV joins).
    local blockSize = (#order <= 2) and 10 or 5
    local ws = 1
    for i, name in ipairs(order) do
        local count = blockSize
        if i == #order and #order > 1 then count = math.max(blockSize, 21 - ws) end
        for _ = 1, count do
            hl.workspace_rule({ workspace = ws, monitor = name, persistent = true })
            ws = ws + 1
        end
    end

    -- Drop persistence from any leftover workspaces and pin them to the primary screen,
    -- so they don't linger as empty persistent workspaces on a removed monitor.
    local primary = order[1]
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

-- The TV's connector name, found by its EDID (works while it's disabled).
local function tvConnector()
    local p = io.popen("ls -d /sys/class/drm/card*-* 2>/dev/null")
    if not p then return nil end
    local out = p:read("*a") or ""
    p:close()
    for dir in out:gmatch("[^\n]+") do
        local f = io.open(dir .. "/edid", "rb")
        if f then
            local edid = f:read("*a") or ""
            f:close()
            if edid:find(TV.edid, 1, true) then return dir:match("card%d+%-(.+)$") end
        end
    end
end

-- If the TV was in standby when the driver probed it (e.g. off at boot), the driver
-- only offers it up to 4K@60 and never re-checks. tv-redetect (usr_scripts/) re-probes
-- the connector; the resulting hotplug re-runs apply() with the 120/144 Hz modes.
-- `sudo -n` so it silently does nothing if the sudoers rule isn't installed.
local function redetectTv()
    local conn = tvConnector()
    if conn then
        hl.exec_cmd("sudo -n /usr/local/bin/tv-redetect " .. conn)
    end
end

local M = {}

function M.toggle_tv()
    local on = not tvWanted()
    setTvWanted(on)
    hl.exec_cmd("notify-send -t 1500 'TV' '" .. (on and "enabled" or "disabled") .. "'")
    apply()
    if on then redetectTv() end
end

return M
