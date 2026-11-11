-- Route through config.colors like every other module, NOT through the shell
-- module directly -- config/colors.lua is what makes a shell swap a one-file
-- edit instead of a grep. This was the last hardcoded `require("noctalia")`.
local colors = require("config.colors")

hl.config({
    render = {
        cm_auto_hdr = 0,
        direct_scanout = 2,
    },
    dwindle = {
        preserve_split = true,
        -- New windows always land on the right/bottom of the split
        -- (0 = follow cursor, 1 = left/top, 2 = right/bottom).
        force_split = 2,
    },
    misc = {
        disable_hyprland_logo = true,
        vrr = 2, -- Enable VRR for fullscreen windows.
        col = {
            splash = colors.PRIMARY,
        },
        middle_click_paste = false,
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|com\\.mitchellh\\.ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
        render_unfocused_fps = 60, -- Prevents OBS and background window captures from dropping to 15 FPS
    },
    xwayland = {
        force_zero_scaling = true
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})
