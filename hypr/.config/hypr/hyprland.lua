-- Bry's Hyprland Configuration

require("config.animations")
require("config.environment")
require("config.colors")
-- Noctalia's generated theme sets general.col.* and group.col.* -- the same
-- keys config.decorations sets. Last write wins, so this must run BEFORE
-- decorations or the gradient there is silently overwritten by a flat colour.
local noctalia_ok, noctalia = pcall(require, "noctalia")

if noctalia_ok then
    noctalia.apply_theme()
end

require("config.decorations")
require("config.variables")
require("config.autostart")
require("config.inputs")
require("config.binds")
require("config.misc")
-- require("config.monitors") Commented out to apply OLED monitor changes
pcall(require,"optional.monitors-gaming")
require("config.windowrules")
require("config.workspaces")
pcall(require, "optional.plugins")
