-- Monitor modes, placement, rotation and color settings for host `matcha`.

hl.monitor({
    output = "desc:AOC Q27G41ZDF RK2S3UA000087",
    disabled = false,
    mode = "2560x1440@240.00Hz",
    position = "0x0",
    scale = 1,
    bitdepth = 10,
    vrr = 2,
    cm = "srgb",
    sdrbrightness = 0.5,
    sdr_min_luminance = 0,
    sdr_max_luminance = 418,
    min_luminance = 0,
    max_luminance = 418,
    max_avg_luminance = 418,
})

hl.monitor({
    output = "DP-2",
    disabled = false,
    mode = "2560x1440@200.01Hz",
    position = "2560x-1120",
    scale = 1,
    transform = 3,
})

-- Portrait workspaces 10-18; keep workspaces 1-9 on the AOC.
hl.workspace_rule({ workspace = "10", monitor = "desc:LG Electronics LG ULTRAGEAR 506NTVSGT967", default = true, persistent = true, gaps_out = { top = 8, right = 8, bottom = 80, left = 8 }, layout = "scrolling", layout_opts = { direction = "down" } })
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Additional LG workspaces use the same vertical scrolling layout.
for i = 11, 18 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "desc:LG Electronics LG ULTRAGEAR 506NTVSGT967", gaps_out = { top = 8, right = 8, bottom = 80, left = 8 }, layout = "scrolling", layout_opts = { direction = "down" } })
end

-- Keep portrait carousel windows near the preferred browser height.
-- Two windows fit with a visible portion of the next one for click-to-follow.
for i = 10, 18 do
    hl.window_rule({
        name = "portrait-carousel-size-" .. tostring(i),
        match = { workspace = tostring(i), float = false },
        scrolling_width = 0.43,
    })
end
