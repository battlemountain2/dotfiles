-- Require your updated dynamic colors module
local colors = require("config.colors")

-- Look and feel configuration
hl.config({
    general = {
        allow_tearing = true,
        gaps_in = 3,
        gaps_out = 8,
        border_size = 2,
        extend_border_grab_area = 10,
        resize_on_border = true,
        col = {
            active_border = {
                -- Dynamic gradient active border using Primary -> Accent
                colors = { colors.PRIMARY, colors.ACCENT },
          angle = 45,
            },
          -- Subdued background color for inactive windows
          inactive_border = colors.SURFACE,
        },
    },
    group = {
        col = {
            border_active = colors.PRIMARY,
          border_inactive = colors.SURFACE,
          border_locked_active = colors.ACCENT,
          border_locked_inactive = colors.SURFACE,
        },
        groupbar = {
            col = {
                active = colors.PRIMARY,
          inactive = colors.SURFACE,
          locked_active = colors.ACCENT,
          locked_inactive = colors.SURFACE,
            },
        },
    },
    decoration = {
        dim_special = 0.3,
        rounding = 10,
        active_opacity = 0.95,
        inactive_opacity = 0.80,
        fullscreen_opacity = 1,
        blur = {
            size = 5,
            passes = 4,
            special = true,
            vibrancy = 0.1696,
        },
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },
    },
})

-- Bypassing the Lua helper and passing raw layer rules directly
hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})
