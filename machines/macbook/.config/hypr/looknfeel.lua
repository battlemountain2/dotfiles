-- Omarchy ships workspace-switch animation disabled by default (the rest of
-- the animation set -- window pop-in/out, fades, layers -- is already on via
-- Omarchy's defaults and costs effectively nothing on this GPU). Turn on a
-- slide to match the horizontal swipe/arrow-key workspace switching.
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "easeOutQuint", style = "slide" })

hl.config({
    decoration = {
        -- Rounding/shadow/dim are corner and border effects, not full-screen
        -- passes -- they cost essentially nothing next to blur.
        rounding = 10,
        rounding_power = 2.5,

        shadow = {
            enabled = true,
            range = 12,
            render_power = 2,
            color = "rgba(00000055)",
        },

        dim_inactive = true,
        dim_strength = 0.12,

        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            new_optimizations = true,
            xray = false,
            noise = 0.015,
            contrast = 1.0,
            brightness = 0.7,
            vibrancy = 0.2,
            vibrancy_darkness = 0.7,
            popups = true,
            popups_ignorealpha = 0.2,
        },
    },
})
