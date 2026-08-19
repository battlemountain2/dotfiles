-- Dynamic colors extracted by Noctalia from your wallpaper.
--
-- noctalia.lua is GENERATED -- Noctalia rewrites it when the theme changes,
-- so nothing here may depend on roles it doesn't currently emit. As of now
-- it returns only: primary, surface, secondary, error. Everything else is
-- derived with a fallback chain, so a regenerated noctalia.lua can add roles
-- (accent, tertiary, background) and they get picked up automatically -- and
-- can drop them again without going nil.
-- SHELL_THEME_MODULE, not a literal "noctalia": this file is the one place
-- that knows which shell generates the palette, and variables.lua is the one
-- place that names it. Between them, a shell swap touches no other file.
local shell = require(SHELL_THEME_MODULE).colors

-- First non-nil argument wins. This cannot use ipairs({...}), which stops at
-- the first nil and would defeat the entire point.
local function pick(...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if v then return v end
    end
end

local colors = {
    -- Roles noctalia.lua emits directly
    PRIMARY    = shell.primary,
    SECONDARY  = shell.secondary,
    SURFACE    = shell.surface,
    ERROR      = shell.error,

    -- Derived roles: not emitted today. A nil here silently collapses the
    -- border gradient to a single stop, which is what used to happen.
    ACCENT     = pick(shell.accent, shell.secondary, shell.primary),
    TERTIARY   = pick(shell.tertiary, shell.secondary, shell.primary),
    BACKGROUND = pick(shell.background, shell.surface),

    -- Legacy Cachy aliases so older configs don't break
    CACHYLGREEN = shell.primary,
    CACHYMGREEN = shell.secondary,
    CACHYDGREEN = pick(shell.tertiary, shell.secondary, shell.primary),
    CACHYLBLUE  = pick(shell.accent, shell.secondary, shell.primary),
    CACHYGRAY   = shell.surface,
}

-- Loud failure beats a silently collapsed gradient.
for _, key in ipairs({ "PRIMARY", "SECONDARY", "SURFACE", "ACCENT" }) do
    if not colors[key] then
        print("[Hyprland] WARNING: colors." .. key .. " is nil -- check " .. SHELL_THEME_MODULE .. ".lua")
    end
end

-- Return the table so require("config.colors") receives it
return colors
