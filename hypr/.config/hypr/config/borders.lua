-- Border colours, deliberately separated from config/decorations.lua.
--
-- Noctalia's Hyprland template appends `require("noctalia").apply_theme()` to
-- the END of hyprland.lua, and apply_theme() sets these exact keys. Last write
-- wins, so this module is required AFTER that line rather than before it.
--
-- TEST IN PROGRESS (2026-08): this works only if Noctalia adds its line when
-- missing rather than rewriting the file tail every regeneration. To check:
-- change your wallpaper, then run
--     hyprctl getoption general:col.active_border
-- Two colours + 45deg -> this survived, the arrangement holds.
-- One colour  + 0deg  -> Noctalia rewrote the tail; this file lost, and the
--                        fallback is to let Noctalia own borders outright.

local colors = require("config.colors")

hl.config({
    general = {
        col = {
            active_border = {
                colors = { colors.PRIMARY, colors.ACCENT },
                angle = 45,
            },
            inactive_border = colors.SURFACE,
        },
    },
    group = {
        col = {
            border_active         = colors.PRIMARY,
            border_inactive       = colors.SURFACE,
            border_locked_active  = colors.ACCENT,
            border_locked_inactive = colors.SURFACE,
        },
        groupbar = {
            col = {
                active         = colors.PRIMARY,
                inactive       = colors.SURFACE,
                locked_active  = colors.ACCENT,
                locked_inactive = colors.SURFACE,
            },
        },
    },
})
