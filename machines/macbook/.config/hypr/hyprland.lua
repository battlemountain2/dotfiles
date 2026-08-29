-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- ---------------------------------------------------------------------------
-- Window rules ported from ~/dotfiles (CachyOS rig)
--
-- Only the machine-agnostic ones. Left behind deliberately: everything
-- gaming/Steam/tearing (no native gaming on aarch64), Dolphin/Ark/KDE sizing
-- (not installed), Noctalia rules, and the opacity overrides -- Omarchy
-- already manages opacity via its own default-opacity tag system in
-- default/hypr/windows.lua, and adding these would fight it.
--
-- Omarchy already ships suppress-maximize and the XWayland drag fix, so those
-- aren't duplicated here.
-- ---------------------------------------------------------------------------

-- Picture-in-Picture: float, pin above everything, keep aspect, corner-sized.
-- Worth having on a laptop -- YouTube/video PiP while working.
o.window({ title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, {
  float = true,
  pin = true,
  keep_aspect_ratio = true,
  size = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
})

-- Any floating window opens centered.
o.window({ float = true }, { center = true })

-- Smart borders: keep gaps and rounding, but drop the border when a single
-- tiled window owns the workspace (nothing to distinguish it from).
o.window({ float = false, workspace = "w[tv1]s[false]" }, { border_size = 0 })

-- File manager floats by default. Centered and sized explicitly rather than
-- relying on the generic float-centering rule above, so this works regardless
-- of rule evaluation order.
o.window("^(org\\.gnome\\.Nautilus)$", {
  float = true,
  center = true,
  size = { "min(monitor_w*0.6, 1200)", "min(monitor_h*0.7, 800)" },
})

-- Steam (incl. Big Picture) always opens on workspace 5. Desktop UI and Big
-- Picture share class "steam", so this catches both; games launched from Steam
-- have their own classes and are unaffected.
o.window("^(steam)$", { workspace = "5" })
