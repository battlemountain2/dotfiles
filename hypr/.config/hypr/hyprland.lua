-- Bry's Hyprland Configuration

-- Globals first. binds, windowrules, workspaces and decorations all read
-- these, so loading them anywhere else lets require-order silently decide
-- what works.
require("config.variables")

require("config.animations")
require("config.environment")

-- Hardware-specific env, split out so another machine ships a different
-- optional/gpu-*.lua instead of editing environment.lua.
pcall(require, "optional.gpu-nvidia")

require("config.colors")

-- The shell's generated theme sets general.col.* and group.col.* -- the same
-- keys config.decorations sets. Last write wins, so this runs BEFORE
-- decorations. See the note at the bottom of this file: Noctalia appends its
-- own apply_theme() call after everything here, which undoes that ordering.
local shell_theme_ok, shell_theme = pcall(require, SHELL_THEME_MODULE)

if shell_theme_ok then
    shell_theme.apply_theme()
end

require("config.decorations")
require("config.autostart")
require("config.inputs")
require("config.binds")
require("config.misc")

-- Per-host monitors. optional/monitors-<hostname>.lua wins when present,
-- otherwise optional/monitors-default.lua. One repo, several machines, no
-- branching. Run `hostname` and name a file after it to override.
local function detect_host()
    local h = os.getenv("HOSTNAME") or os.getenv("HOST")
    if h and h ~= "" then return h end

    -- io.popen may be unavailable depending on how the Lua host is sandboxed,
    -- hence the pcall rather than calling it directly.
    local ok, pipe = pcall(io.popen, "hostname")
    if ok and pipe then
        local out = pipe:read("*l")
        pipe:close()
        if out and out ~= "" then return out end
    end

    return nil
end

local host = detect_host()
local monitors_loaded = false

if host then
    monitors_loaded = pcall(require, "optional.monitors-" .. host)
end

if not monitors_loaded then
    monitors_loaded = pcall(require, "optional.monitors-default")
end

if not monitors_loaded then
    print("[Hyprland] WARNING: no monitor config loaded (host=" .. tostring(host) .. ")")
end

require("config.windowrules")
require("config.workspaces")
pcall(require, "optional.plugins")

-- APPENDED BY NOCTALIA -- do not rely on anything after this line staying put.
-- Noctalia's Hyprland template re-adds this on every theme regeneration, and
-- because it lands at the end of the file it overrides the border colours set
-- in config/decorations.lua.
require("noctalia").apply_theme()

-- ---------------------------------------------------------------------------
-- EVERYTHING BELOW RUNS AFTER NOCTALIA'S apply_theme().
--
-- That is the entire point: apply_theme() sets general.col.* and group.col.*,
-- so our border colours have to be applied after it or they do nothing.
--
-- If this require ever vanishes, or ends up ABOVE the apply_theme() line, then
-- Noctalia rewrites the tail of this file on every theme regeneration and this
-- approach is dead -- see the notes in config/borders.lua.
-- ---------------------------------------------------------------------------
require("config.borders")
