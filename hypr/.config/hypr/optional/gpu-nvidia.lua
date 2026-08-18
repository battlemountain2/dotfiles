-- NVIDIA-specific environment. Loaded with pcall from hyprland.lua, so a
-- machine that doesn't ship this file simply skips it.
--
-- These are actively WRONG on other GPUs, not merely inert:
-- LIBVA_DRIVER_NAME=nvidia breaks video decode on AMD/Intel/Apple silicon.
-- On another machine, write optional/gpu-<vendor>.lua and point hyprland.lua
-- at it instead.

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
