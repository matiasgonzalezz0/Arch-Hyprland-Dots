------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/ for workspace rules

-- Example windowrule v1
-- hl.window_rule({ match = { class = "kitty" }, float = true })

-- Example windowrule v2
-- hl.window_rule({ match = { class = "^(kitty)$", title = "^(kitty)$" }, float = true })

local activeOpa     = 0.95
local inactiveOpa   = 0.95
local fullscreenOpa = 0.95
local floatingOpa   = 0.95

hl.layer_rule({
    match        = { namespace = "waybar" },
    blur         = true,
    no_anim      = true,
    ignore_alpha = 0.5,
})

-- Ignore apps asking to start maximized, otherwise they cover the workspace instead of tiling
hl.window_rule({
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    match   = { class = "^(kitty)$" },
    opacity = activeOpa .. " override " .. inactiveOpa .. " override " .. fullscreenOpa .. " override",
})
hl.window_rule({ match = { class = "^(firefox)$" },         workspace = 10 })
-- hl.window_rule({ match = { class = "^(steam)$" },         workspace = 5  })
hl.window_rule({ match = { class = "^(vesktop)$" },          workspace = 15 })
hl.window_rule({ match = { title = "^(Spotify Premium)$" },  workspace = 20 })
