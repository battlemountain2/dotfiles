-- /home/bry/.config/hypr/optional/plugins.lua
--
-- HyprExpo+ (sandwichfarm/hyprexpo) configuration & keybinds.

local colors = require("config.colors")
local mainMod = "SUPER"

hl.config({
    plugin = {
        hyprexpo = {
            columns = 3,
            gaps_in = 6,
            gaps_out = 12,
            bg_col = "rgb(111111)",
            workspace_method = "first 1",
            cancel_key = "escape",
            show_cursor = 1,
            drag_drop_enable = 1,
            keynav_enable = 1,
            number_key_mode = "workspace",
            keynav_wrap_h = 1,
            keynav_wrap_v = 1,

            -- Borders: follow Noctalia theme primary color for active/focused tile, black for inactive
            border_width = 2,
            border_color = "rgb(000000)",
            border_color_current = colors.PRIMARY,
            border_color_focus = colors.PRIMARY,
            border_color_hover = colors.ACCENT,

            -- Hide workspace numbers / labels
            label_enable = 0,
            show_workspace_numbers = 0,
            show_workspace_names = 0,
            selection_label_enable = 0,

            -- Rounded tile corners matching desktop aesthetic
            tile_rounding = 10,
        },
    },
})

-- Super + Tab toggles the workspace overview
hl.bind(mainMod .. " + Tab", function()
    if hl.plugin and hl.plugin.hyprexpo then
        hl.plugin.hyprexpo.expo("toggle")
    else
        hl.dispatch("hyprexpo:expo", "toggle")
    end
end)
