-- Dynamic colors extracted by Noctalia from your wallpaper
local noctalia = require("noctalia").colors

-- Store all variables inside a local table
local colors = {
    -- Map Noctalia's dynamic Material roles to your color variables
    PRIMARY    = noctalia.primary,
    SECONDARY  = noctalia.secondary,
    ACCENT     = noctalia.accent,
    SURFACE    = noctalia.surface,
    BACKGROUND = noctalia.background,

    -- Legacy Cachy aliases so older configs don't break
    CACHYLGREEN = noctalia.primary,
    CACHYMGREEN = noctalia.secondary,
    CACHYDGREEN = noctalia.tertiary,
    CACHYLBLUE  = noctalia.accent,
    CACHYGRAY   = noctalia.surface,
}

-- Return the table so require("config.colors") receives it
return colors
