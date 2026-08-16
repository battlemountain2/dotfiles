-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

-- Beziers
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("overshoot",      { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.1}   } })
hl.curve("snap",           { type = "bezier", points = { {0.2, 1},     {0.3, 1}     } })

-- Springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })
hl.curve("rubber",         { type = "spring", mass = 1, stiffness = 70,      dampening = 10         })

-- ── Animations ───────────────────────────────────────────────────────────

hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "quick" })

-- Windows: split in/out. Overshoot on close makes a window bounce OUTWARD
-- and then vanish, which reads as a glitch — so only `in` gets the bounce.
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4, bezier = "overshoot", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "snap",      style = "popin 85%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "snap" })

--Fade
hl.animation({ leaf = "fadeIn",     enabled = true, speed = 3, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",    enabled = true, speed = 2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 2, bezier = "almostLinear" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 3, bezier = "almostLinear" })

-- Border colour transition on focus change.
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "almostLinear" })

-- Gradient rotation. This is the signature Hyprland look and you already
-- have the gradient set up for it (PRIMARY -> ACCENT at 45deg).
--
-- COST: `loop` means continuous repaint of every window border, forever.
-- On a 240Hz panel that is real, measurable GPU time even when idle. Set
-- enabled = false if you notice it, or raise speed to slow the rotation.
hl.animation({ leaf = "borderangle", enabled = true, speed = 100, bezier = "linear", style = "loop" })

-- Workspaces: 5ds is ~half a second, which fights hyprtasking's own
-- overview timing. 3 keeps the motion readable without the lag.
hl.animation({ leaf = "workspaces",          enabled = true, speed = 3, bezier = "quick", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2, bezier = "quick", style = "slide top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 2, bezier = "quick", style = "slide bottom" })

-- Layers: Noctalia's bar/panels/OSD. Note decorations.lua sets no_anim on
-- the noctalia layer rule, so these apply to other layer surfaces only.
hl.animation({ leaf = "layersIn",  enabled = true, speed = 3, bezier = "overshoot", style = "popin 90%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "snap",      style = "popin 90%" })
