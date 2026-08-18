-- Portable environment only. Anything tied to specific hardware belongs in
-- optional/, not here -- see optional/gpu-nvidia.lua.

hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("XCURSOR_SIZE", "24")  -- 48 on a HiDPI panel running scale 2
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
