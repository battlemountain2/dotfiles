-- Hyprland default apps

TERMINAL     = "kitty"
FILE_MANAGER = "dolphin"
BROWSER      = "zen-browser"
EDITOR       = "kate"
CALCULATOR   = "gnome-calculator"

-- Desktop shell
--
-- Everything that talks to the shell routes through these. Swapping shells
-- (Noctalia -> Caelestia, etc.) is an edit here plus the subcommand names in
-- binds.lua -- not a hunt across five files.
--
--   SHELL_CMD           binary; also what autostart launches
--   SHELL_IPC           message prefix (note the trailing space)
--   SHELL_THEME_MODULE  Lua module the shell generates next to hyprland.lua
--   SHELL_LAYER         layer-surface namespace regex, for layer rules
SHELL_CMD          = "noctalia"
SHELL_IPC          = SHELL_CMD .. " msg "
SHELL_THEME_MODULE = "noctalia"
SHELL_LAYER        = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$"

-- Monitors
-- Actual mode/scale/HDR lives in optional/monitors-<hostname>.lua, falling
-- back to optional/monitors-default.lua. This is just the output name.
MONITOR1        = "DP-1"
PRIMARY_MONITOR = MONITOR1
