-- Input configuration

hl.config({
    cursor = { no_warps = true, zoom_detached_camera = false, zoom_rigid = false, zoom_disable_aa = true },
    scrolling = { follow_focus = false },
    input = {
        -- Focus on hover across all windows
        follow_mouse = 1,
        -- sensitivity = -0.25,
        accel_profile = "flat",
    },
    -- Uncomment the section below to enable software cursors; this can help with cursor display or behavior issues
     --cursor = {
         --no_hardware_cursors = 1,
     --},
})

--hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
--hl.gesture({ fingers = 3, direction = "down",       action = "close" })
--hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
--hl.gesture({ fingers = 3, direction = "left",       action = "float" })
