-- Border colours, deliberately separated from config/decorations.lua.
--
-- Noctalia's Hyprland template appends `require("noctalia").apply_theme()` to
-- the END of hyprland.lua, and apply_theme() sets these exact keys. Last write
-- wins, so this module is required AFTER that line rather than before it.
--
-- VERIFIED 2026-08: Noctalia adds its apply_theme() line only when missing --
-- it does NOT rewrite the tail of hyprland.lua on regeneration. Confirmed by
-- changing the wallpaper and checking that both the gradient and the require
-- below it survived. So this arrangement is stable, not a temporary hack.
--
-- If borders ever go flat again, check that hyprland.lua still ends with
-- `require("config.borders")` BELOW the apply_theme() line -- that ordering is
-- the whole mechanism. Verify with:
--     hyprctl getoption general:col.active_border
-- Two colours + 45deg = correct. One colour + 0deg = the ordering broke.

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
