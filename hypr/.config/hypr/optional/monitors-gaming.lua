-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Example: output can be found with hyprctl monitors. Edit variables.lua for the monitor outputs instead of here directly
-- hl.monitor({
--     output    = "MONITOR1",
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

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
