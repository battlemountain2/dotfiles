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

-- HyprExpo active submap for keyboard navigation
hl.define_submap("hyprexpo", function()
    -- Arrow navigation (both plain and with SUPER held down)
    hl.bind("left",                function() hl.plugin.hyprexpo.kb_focus("left") end)
    hl.bind("right",               function() hl.plugin.hyprexpo.kb_focus("right") end)
    hl.bind("up",                  function() hl.plugin.hyprexpo.kb_focus("up") end)
    hl.bind("down",                function() hl.plugin.hyprexpo.kb_focus("down") end)

    hl.bind(mainMod .. " + Left",  function() hl.plugin.hyprexpo.kb_focus("left") end)
    hl.bind(mainMod .. " + Right", function() hl.plugin.hyprexpo.kb_focus("right") end)
    hl.bind(mainMod .. " + Up",    function() hl.plugin.hyprexpo.kb_focus("up") end)
    hl.bind(mainMod .. " + Down",  function() hl.plugin.hyprexpo.kb_focus("down") end)

    -- Vim keys
    hl.bind("h", function() hl.plugin.hyprexpo.kb_focus("left") end)
    hl.bind("l", function() hl.plugin.hyprexpo.kb_focus("right") end)
    hl.bind("k", function() hl.plugin.hyprexpo.kb_focus("up") end)
    hl.bind("j", function() hl.plugin.hyprexpo.kb_focus("down") end)

    -- Selection / Confirm / Cancel
    hl.bind("return",            function() hl.plugin.hyprexpo.kb_confirm() end)
    hl.bind("space",             function() hl.plugin.hyprexpo.kb_confirm() end)
    hl.bind("escape",            function() hl.plugin.hyprexpo.expo("cancel") end)
    hl.bind(mainMod .. " + Tab", function() hl.plugin.hyprexpo.expo("toggle") end)

    -- Direct 1-9 workspace selection
    for i = 1, 9 do
        hl.bind(tostring(i),           function() hl.plugin.hyprexpo.kb_selecti(i) end)
        hl.bind(mainMod .. " + " .. i, function() hl.plugin.hyprexpo.kb_selecti(i) end)
    end
end)

