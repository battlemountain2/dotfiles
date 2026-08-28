-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

-- Beziers
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } }) -- unused; slow in and out, kept as an option
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("overshoot",      { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.1}   } })
hl.curve("snap",           { type = "bezier", points = { {0.2, 1},     {0.3, 1}     } }) -- unused: ~88% of motion in the first 31%, read as instant
-- The only accelerating curve here. Every other bezier above front-loads
-- (fast start, slow tail); this one holds briefly then speeds up, so a
-- window leaving the screen reads as launching rather than being yanked.
hl.curve("easeInQuad",     { type = "bezier", points = { {0.11, 0},    {0.5, 0}     } })

-- Springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 }) -- unused
hl.curve("rubber",         { type = "spring", mass = 1, stiffness = 70,      dampening = 10         }) -- unused; bouncier than `easy`

-- ── Animations ───────────────────────────────────────────────────────────

hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "quick" })

-- Windows: split in/out. Overshoot on close makes a window bounce OUTWARD
-- and then vanish, which reads as a glitch — so only `in` gets the bounce.
--
-- Out uses `slide` (no direction = Hyprland picks the nearest screen edge),
-- so closed windows fly off rather than shrinking in place.
--
-- easeInQuad, not easeOutQuint: a front-loaded curve threw the window off
-- before you could register it. Accelerating means the first third is slow
-- and visible, then it leaves fast. 5ds because that slow head costs real
-- time -- at 4ds there wasn't enough of it to see. Settled on 6ds.
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 4, bezier = "overshoot", style = "popin 85%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 6, bezier = "easeInQuad", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "easeOutQuint" })

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
hl.animation({ leaf = "borderangle", enabled = false, speed = 100, bezier = "linear", style = "loop" })

-- Workspaces: 5ds is ~half a second, which fights hyprtasking's own
-- overview timing. 4 is the compromise -- readable, still ahead of the
-- overview, and less abrupt than the 3 it used to be.
hl.animation({ leaf = "workspaces",          enabled = true, speed = 4, bezier = "quick", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2, bezier = "quick", style = "slide top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 2, bezier = "quick", style = "slide bottom" })

-- Layers: Noctalia's bar/panels/OSD. Note decorations.lua sets no_anim on
-- the noctalia layer rule, so these apply to other layer surfaces only.
hl.animation({ leaf = "layersIn",  enabled = true, speed = 3, bezier = "overshoot", style = "popin 90%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2, bezier = "easeOutQuint", style = "popin 90%" })
