-- Personal keybinding overrides. Loaded after Omarchy's defaults, so unbind
-- before rebinding anything they already claim.
--
-- See current bindings:  omarchy menu keybindings --print
--
-- Note on modifiers: SUPER is Command, ALT is Option. Option sits where Ctrl
-- lives on a PC keyboard, which is why workspaces moved to SUPER+ALT.

-- ---------------------------------------------------------------------------
-- Keyboard backlight
-- ---------------------------------------------------------------------------
-- The 2021 14" MBP has no dedicated keyboard-backlight keys, and F1/F2 emit
-- XF86MonBrightness* rather than F1/F2 -- which is why SUPER+F1 never fired.
-- Bare F1/F2 stays display brightness; Command+F1/F2 does the keyboard.
o.bind("SUPER + XF86MonBrightnessDown", "Keyboard backlight down", "omarchy-brightness-keyboard down", { locked = true, repeating = true })
o.bind("SUPER + XF86MonBrightnessUp", "Keyboard backlight up", "omarchy-brightness-keyboard up", { locked = true, repeating = true })

-- ---------------------------------------------------------------------------
-- Applications
-- ---------------------------------------------------------------------------
-- T for terminal. Floating moves to CTRL+ALT+SPACE to free it up.
hl.unbind("SUPER + T")
o.bind("SUPER + T", "Terminal", "xdg-terminal-exec --dir=/home/bry")
o.bind("CTRL + ALT + SPACE", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- Mirador plugin: fullscreen workspace/window overview. Takes over stock
-- SUPER+TAB ("Next workspace") -- redundant since workspace cycling already
-- lives on SUPER+ALT+LEFT/RIGHT above.
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Workspace overview", "omarchy-shell shell toggle mirador '{}'")

-- RETURN becomes Browser. SUPER+SHIFT+RETURN is then redundant with
-- SUPER+SHIFT+B, so it goes.
hl.unbind("SUPER + RETURN")
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + RETURN", "Browser", { omarchy = "browser" })

-- Muscle memory from the CachyOS dotfiles. All three of these keys were free
-- in Omarchy, so nothing had to be unbound.
--   SUPER+E  file manager (Omarchy's own is SUPER+SHIFT+F, still works)
--   SUPER+B  browser      (Omarchy's own is SUPER+SHIFT+B, still works)
--   CTRL+SHIFT+ESCAPE  task-manager reflex, opens btop
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("CTRL + SHIFT + ESCAPE", "System monitor", { tui = "btop" })

-- ---------------------------------------------------------------------------
-- Window management
-- ---------------------------------------------------------------------------
-- Command+Q quits, Command+W closes -- same split as macOS. Hyprland has one
-- dispatcher for both, so they behave identically here.
--
-- VERIFY THIS LINE against:
--   grep -n "Close window" /usr/share/omarchy/default/hypr/bindings/tiling.lua
-- and replace hl.dsp.window.close() with whatever they actually use.
o.bind("SUPER + Q", "Quit window", hl.dsp.window.close())

-- ---------------------------------------------------------------------------
-- Workspaces on SUPER + ALT (Command + Option)
--
-- Cycle workspaces with Command+Option+arrows, matching the number binds.
-- Takes over "Move window to group on left/right".
hl.unbind("SUPER + ALT + LEFT")
hl.unbind("SUPER + ALT + RIGHT")
-- Plain +1/-1 (not "e+1"/"e-1") so this always jumps/creates like the number
-- binds do, instead of being a no-op when no other workspace exists yet.
o.bind("SUPER + ALT + LEFT", "Previous workspace", hl.dsp.focus({ workspace = "-1" }))
o.bind("SUPER + ALT + RIGHT", "Next workspace" , hl.dsp.focus({ workspace = "+1" }))
---------------------------------------------------------------------------
-- Omarchy binds workspaces by keycode rather than digit so non-US layouts keep
-- working -- code:10 is the "1" key, up through code:19 for "0". Same trick
-- here.
--
-- This takes over SUPER+ALT+1..5, which were "Switch to group window 1-5".
-- Group creation (SUPER+G), moving in/out (SUPER+ALT+arrows, SUPER+ALT+G) and
-- cycling (SUPER+ALT+TAB) all survive -- only the direct-index jump is gone.
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)

  hl.unbind("SUPER + ALT + " .. key)

  o.bind("SUPER + ALT + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  end

  -- Move-window-to-workspace MOVED to SUPER+CTRL+n (Command+Ctrl) as of
  -- 2026-08-19, freeing SUPER+SHIFT+3/4/5 for the macOS screenshot trio.
  -- See the screenshots block at the end of this file.

  -- ---------------------------------------------------------------------------
  -- Left alone deliberately
  -- ---------------------------------------------------------------------------
  -- SUPER+W (close), SUPER+F (fullscreen): already match macOS muscle memory.
  -- The whole XF86 media row: Omarchy's handling is thorough and hardware-keyed.
  -- SUPER+SHIFT+n move-to-workspace, SUPER+TAB cycling, scratchpad, groups.
  --
  -- Worth a look before you keep them: SUPER+C / SUPER+V / SUPER+X are bound to
  -- "universal copy/paste/cut". On a Mac keyboard that is Command+C/V/X, which
  -- is copy/paste/cut everywhere else on the system. If they misbehave in apps,
-- unbind them:
--   hl.unbind("SUPER + C")
--   hl.unbind("SUPER + V")
--   hl.unbind("SUPER + X")


-- ---------------------------------------------------------------------------
-- Screenshots on Command+Shift+3/4/5, macOS-style
--
-- macOS uses Cmd+Shift+3 (whole screen), +4 (selection), +5 (capture UI).
-- Omarchy ships those on Cmd+CTRL+Shift+3/4/5 and puts plain screenshot on
-- PRINT -- a key this keyboard does not have.
--
-- Taking Cmd+Shift+n means move-window-to-workspace has to go somewhere, so it
-- moves to Cmd+Ctrl+n. That in turn displaces Omarchy's "Bar panel 1-9"
-- shortcuts, which are unbound below. Those are Omarchy-only and disappear if
-- this machine ever moves to Noctalia, so they are the cheapest thing to give up.
-- ---------------------------------------------------------------------------
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)

  hl.unbind("SUPER + SHIFT + " .. key)  -- was: Move window to workspace N
  hl.unbind("SUPER + CTRL + " .. key)   -- was: Bar panel N (1-9 only)

  o.bind(
    "SUPER + CTRL + " .. key,
    "Move window to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace) })
  )
end

o.bind("SUPER + SHIFT + code:12", "Screenshot display",   "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + SHIFT + code:13", "Screenshot selection", "omarchy-capture-screenshot")
o.bind("SUPER + SHIFT + code:14", "Capture menu",         "omarchy-menu toggle capture")
