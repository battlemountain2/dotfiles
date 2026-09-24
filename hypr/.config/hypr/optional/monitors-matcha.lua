-- Monitor settings for matcha: single active definition for the AOC panel.
-- Preserves effective HyprMod settings verified on 2026-09-09.
-- HDR capability overrides retain their previous effective defaults.
hl.monitor({
    output = "desc:AOC Q27G41ZDF RK2S3UA000087",
    disabled = false,
    mode = "2560x1440@240.00Hz",
    position = "0x0",
    scale = 1,
    bitdepth = 10,
    vrr = 3,
    cm = "srgb",
    sdrbrightness = 0.5,
    sdr_min_luminance = 0,
    sdr_max_luminance = 418,
    min_luminance = 0,
    max_luminance = 418,
    max_avg_luminance = 418,
})

