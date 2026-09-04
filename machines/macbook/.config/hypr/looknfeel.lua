-- ── Curves & Beziers (Ported from desktop) ─────────────────────────────────
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })
hl.curve("overshoot",      { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.1} } })
hl.curve("easeInQuad",     { type = "bezier", points = { {0.11, 0},    {0.5, 0} } })

-- ── Animations ─────────────────────────────────────────────────────────────
hl.animation({ leaf = "global",     enabled = true, speed = 3, bezier = "quick" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4, bezier = "overshoot", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 6, bezier = "easeInQuad", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 3, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeSwitch",  enabled = true, speed = 2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeDim",     enabled = true, speed = 3, bezier = "almostLinear" })
hl.animation({ leaf = "border",      enabled = true, speed = 4, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4, bezier = "quick", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2, bezier = "quick", style = "slide top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 2, bezier = "quick", style = "slide bottom" })

-- ── Decorations & Squircle Corners ─────────────────────────────────────────
hl.config({
    decoration = {
        -- Squircle corners (superellipse) matching desktop
        rounding = 12,
        rounding_power = 4.0,

        shadow = {
            enabled = true,
            range = 14,
            render_power = 2,
            color = "rgba(00000055)",
        },

        dim_inactive = true,
        dim_strength = 0.10,

        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            new_optimizations = true,
            -- X-Ray: windows blur wallpaper rather than each other
            xray = true,
            noise = 0.02,
            contrast = 1.05,
            brightness = 1.0,
            vibrancy = 0.28,
            vibrancy_darkness = 0.12,
            popups = true,
            popups_ignorealpha = 0.3,
        },
    },
    misc = {
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
    },
})
