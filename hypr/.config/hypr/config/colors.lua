-- Dynamic colors extracted by Noctalia from your wallpaper.
--
-- noctalia.lua is GENERATED -- Noctalia rewrites it when the theme changes,
-- so nothing here may depend on roles it doesn't currently emit. As of now
-- it returns only: primary, surface, secondary, error. Everything else is
-- derived with a fallback chain, so a regenerated noctalia.lua can add roles
-- (accent, tertiary, background) and they get picked up automatically -- and
-- can drop them again without going nil.
local noctalia = require("noctalia").colors

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
    PRIMARY    = noctalia.primary,
    SECONDARY  = noctalia.secondary,
    SURFACE    = noctalia.surface,
    ERROR      = noctalia.error,

    -- Derived roles: not emitted today. A nil here silently collapses the
    -- border gradient to a single stop, which is what used to happen.
    ACCENT     = pick(noctalia.accent, noctalia.secondary, noctalia.primary),
    TERTIARY   = pick(noctalia.tertiary, noctalia.secondary, noctalia.primary),
    BACKGROUND = pick(noctalia.background, noctalia.surface),

    -- Legacy Cachy aliases so older configs don't break
    CACHYLGREEN = noctalia.primary,
    CACHYMGREEN = noctalia.secondary,
    CACHYDGREEN = pick(noctalia.tertiary, noctalia.secondary, noctalia.primary),
    CACHYLBLUE  = pick(noctalia.accent, noctalia.secondary, noctalia.primary),
    CACHYGRAY   = noctalia.surface,
}

-- Loud failure beats a silently collapsed gradient.
for _, key in ipairs({ "PRIMARY", "SECONDARY", "SURFACE", "ACCENT" }) do
    if not colors[key] then
        print("[Hyprland] WARNING: colors." .. key .. " is nil -- check noctalia.lua")
    end
end

-- Return the table so require("config.colors") receives it
return colors
