-- Require your updated dynamic colors module
local colors = require("config.colors")

hl.config({
    general = {
        allow_tearing = true,
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        extend_border_grab_area = 10,
        resize_on_border = true,
        -- Border COLOURS are NOT here. They live in config/borders.lua, which
        -- hyprland.lua requires after Noctalia's appended apply_theme() --
        -- otherwise that call overwrites them and this block does nothing.
    },
    decoration = {
        -- Squircle corners. The superellipse is what reads as "designed"
        -- rather than "rounded rect". Cheapest big win here.
        -- Check support: hyprctl getoption decoration:rounding_power
        rounding = 12,
        rounding_power = 4.0,

        -- Restrained transparency. 0.88 looked good in isolation but at
        -- 1440p it costs text contrast in Kate/Dolphin/Zen, and on OLED you
        -- do not need transparency to get depth — you have real blacks.
        active_opacity = 0.94,
        inactive_opacity = 0.86,
        fullscreen_opacity = 1,

        -- Dim does the focus-cue work that heavy transparency was doing,
        -- for a fraction of the cost and none of the readability hit.
        -- This is the change that makes the desktop feel deliberate.
        dim_inactive = true,
        dim_strength = 0.10,
        dim_special = 0.4,
        dim_around = 0.4,

        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            new_optimizations = true,

            -- The important one. Windows blur the wallpaper, not each other,
            -- so stacked translucent windows stay legible instead of
            -- compounding into grey soup. Also cheaper than normal blur.
            xray = true,

            special = true,
            popups = true,
            popups_ignorealpha = 0.4,

            -- Saturation lift behind the glass. Reads as a material.
            vibrancy = 0.28,
            vibrancy_darkness = 0.12,

            -- Grain. Kills gaussian banding, which is what makes cheap blur
            -- look like plastic. Matters more on OLED where banding shows.
            noise = 0.02,

            contrast = 1.05,
            brightness = 1.0,
        },

        -- Soft, slightly offset. On OLED the shadow falls into true black,
        -- so it reads as depth rather than as a grey halo.
        shadow = {
            enabled = true,
            range = 16,
            render_power = 3,
            offset = { 0, 4 },
            color = "rgba(0000006e)",
        },
    },
})

hl.layer_rule({
    name = "shell-surfaces",
    match = {
        namespace = SHELL_LAYER,  -- set in config/variables.lua
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
    -- Deliberately NOT xray: the bar should see windows behind it, unlike
    -- windows which should only see the wallpaper.
    xray = false,
})
