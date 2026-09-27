-- Monitor modes, placement, rotation and color settings are owned by HyprMod
-- in hyprland-gui.lua, loaded at the end of hyprland.lua. Do not duplicate
-- hl.monitor definitions here; GUI edits must remain authoritative.

-- Portrait workspaces 10-18; keep workspaces 1-9 on the AOC.
hl.workspace_rule({ workspace = "10", monitor = "desc:LG Electronics LG ULTRAGEAR 506NTVSGT967", default = true, persistent = true, gaps_out = { top = 8, right = 8, bottom = 80, left = 8 }, layout = "scrolling", layout_opts = { direction = "down" } })
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Additional LG workspaces use the same vertical scrolling layout.
for i = 11, 18 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "desc:LG Electronics LG ULTRAGEAR 506NTVSGT967", gaps_out = { top = 8, right = 8, bottom = 80, left = 8 }, layout = "scrolling", layout_opts = { direction = "down" } })
end
