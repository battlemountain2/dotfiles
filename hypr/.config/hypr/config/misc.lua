-- Route through config.colors like every other module, NOT through the shell
-- module directly -- config/colors.lua is what makes a shell swap a one-file
-- edit instead of a grep. This was the last hardcoded `require("noctalia")`.
local colors = require("config.colors")

hl.config({
    render = {
        cm_auto_hdr = 1,
    },
    dwindle = {
        preserve_split = true,
        -- New windows always land on the right/bottom of the split
        -- (0 = follow cursor, 1 = left/top, 2 = right/bottom).
        force_split = 2,
    },
    misc = {
        col = {
            splash = colors.PRIMARY,
        },
        middle_click_paste = false,
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
    },
    xwayland = {
        force_zero_scaling = true
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})

