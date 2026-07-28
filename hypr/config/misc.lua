local noctalia_colors = require("noctalia").colors

hl.config({
    dwindle = {
        preserve_split = true,
    },
    misc = {
        col = {
            splash = noctalia_colors.primary,
        },
        middle_click_paste = false,
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
          vrr = 1,
    },
    xwayland = {
        force_zero_scaling = true
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})
