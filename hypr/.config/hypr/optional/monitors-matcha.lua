-- Monitor config for host `cachyos-x8664`.
--
-- Selected by hyprland.lua, which tries optional/monitors-<hostname>.lua and
-- falls back to optional/monitors-default.lua. Another machine gets its own
-- file; nothing here needs to be portable.
--
-- Wiki: https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Output names come from `hyprctl monitors`.
--
-- Merged from the old config/monitors.lua. render.cm_auto_hdr in
-- config/misc.lua is a no-op without supports_hdr set here.

hl.monitor({
    output = "DP-1",
    mode = "2560x1440@240",
    position = "0x0",
    scale = 1,
    bitdepth = 10,
    cm = "srgb",
    vrr = 2,

    -- Merged from config/monitors.lua. render.cm_auto_hdr in config/misc.lua
    -- is a no-op without supports_hdr set here. Verified via `hyprctl eval`
    -- that hl.monitor() accepts these without throwing on 0.56.2 -- though
    -- "accepts" is not the same as "honours", so check hyprctl monitors -j.
    supports_hdr = 1,
    sdr_max_luminance = 300,
})
