-- Loading runs in a separate process after Lua config processing finishes.
local function overview(action)
    return function()
        if hl.plugin and hl.plugin.scrolloverview then
            hl.plugin.scrolloverview._dispatch("overview", action)
        elseif action == "toggle" then
            hl.exec_cmd("/home/bry/.local/bin/scrolloverview-control toggle")
        end
    end
end

hl.bind("SUPER + Tab", overview("toggle"))

-- The external loader requests a reload once the plugin is available.
if not (hl.plugin and hl.plugin.scrolloverview) then
    return
end

hl.config({ plugin = { scrolloverview = {
    scale = 0.5,
    layout = "auto",
    workspace_gap = 80,
    wallpaper = 2,
    blur = true,
    shadow = { enabled = true, range = 30 },
} } })

hl.define_submap("scrolloverview", function()
    -- Close the preview under the pointer without leaving the overview.
    hl.bind("SUPER + Q", function()
        hl.plugin.scrolloverview._dispatch("window", "close")
    end)
    -- A custom submap replaces the plugin's default click handling.
    hl.bind("mouse:272", function()
        hl.plugin.scrolloverview._dispatch("overview", "select")
        hl.plugin.scrolloverview._dispatch("window", "select")
        hl.plugin.scrolloverview._dispatch("overview", "close all")
    end, { mouse = true, ignore_mods = true })
    hl.bind("SUPER + Up", function() hl.plugin.scrolloverview._dispatch("navigate", "up") end)
    hl.bind("SUPER + Down", function() hl.plugin.scrolloverview._dispatch("navigate", "down") end)
    hl.bind("escape", overview("close all"))
    hl.bind("SUPER + Tab", overview("close all"))
end)
