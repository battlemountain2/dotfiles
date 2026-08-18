local mainMod = "SUPER"
local noctCall = SHELL_IPC  -- set in config/variables.lua
local launchPrefix = "" -- if you are not using UWSM, make this empty (e.g. "")

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- Window manipulation
-- killhovered comes from hyprtasking, which optional/plugins.lua treats as
-- possibly-absent. Without a fallback, a failed plugin build leaves you with
-- no way to close a window at all. Chain is deliberate: the Lua dispatcher
-- name for killactive is not confirmed on this version, so hyprctl is the
-- guaranteed last resort.
hl.bind(mainMod .. " + Q", function()
    if hl.plugin and hl.plugin.hyprtasking then
        hl.plugin.hyprtasking.killhovered()
    elseif hl.dsp and hl.dsp.window and hl.dsp.window.kill then
        hl.dispatch(hl.dsp.window.kill())
    else
        hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch killactive"))
    end
end)
hl.bind(mainMod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + W",           hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + J",           hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P",           hl.dsp.window.pin())

-- Baseline Focus Controls
hl.bind(mainMod .. " + Left",  function() hl.dispatch(hl.dsp.focus({ direction = "left" })) end)
hl.bind(mainMod .. " + Right", function() hl.dispatch(hl.dsp.focus({ direction = "right" })) end)
hl.bind(mainMod .. " + Up",    function() hl.dispatch(hl.dsp.focus({ direction = "up" })) end)
hl.bind(mainMod .. " + Down",  function() hl.dispatch(hl.dsp.focus({ direction = "down" })) end)

hl.bind("ALT + Tab", hl.dsp.window.cycle_next())

-- Move window position within the layout
hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "down" }))

-- Take the window with you
hl.bind(mainMod .. " + CONTROL + mouse_down", hl.dsp.window.move({ workspace = "m+1" }))
hl.bind(mainMod .. " + CONTROL + mouse_up",   hl.dsp.window.move({ workspace = "m-1" }))

-- Send the window and go with it
hl.bind(mainMod .. " + CONTROL + SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + Left",  hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r+1", follow = false }))
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "r-1", follow = false }))

-- Move window to workspace N without following it
for i = 1, 9 do
hl.bind(mainMod .. " + SHIFT + CONTROL + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
-- Move & Resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Keyboard Window Resizing
local step = 30

hl.bind(mainMod .. " + ALT + Left",  hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + Right", hl.dsp.window.resize({ x = step,  y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + Up",    hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + Down",  hl.dsp.window.resize({ x = 0, y = step,  relative = true }), {repeating = true })

------------------
---- LAUNCHER ----
------------------
hl.bind(mainMod .. " + Return",     hl.dsp.exec_cmd(launchPrefix .. EDITOR))
hl.bind(mainMod .. " + E",          hl.dsp.exec_cmd(launchPrefix .. FILE_MANAGER))
hl.bind(mainMod .. " + T",          hl.dsp.exec_cmd(launchPrefix .. TERMINAL))
hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd(launchPrefix .. CALCULATOR))
hl.bind(mainMod .. " + B",          hl.dsp.exec_cmd(launchPrefix .. BROWSER))
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"))
hl.bind(mainMod .. " + Z",          hl.dsp.exec_cmd(noctCall .. "settings-toggle"))
hl.bind(mainMod .. " + X",          hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center"))
hl.bind(mainMod .. " + Space",      hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher"))
hl.bind(mainMod .. " + period",     hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher /emo"))
hl.bind(mainMod .. " + L",          hl.dsp.exec_cmd(noctCall .. "session lock"))
hl.bind(mainMod .. " + ALT + C",    hl.dsp.exec_cmd(noctCall .. "panel-toggle session"))

---------------------------
---- HARDWARE CONTROLS ----
---------------------------

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctCall .. "volume-up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctCall .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(noctCall .. "volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(noctCall .. "mic-mute"),    { locked = true })
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center audio"))

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(noctCall .. "media toggle"),   { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(noctCall .. "media toggle"),   { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(noctCall .. "media next"),     { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(noctCall .. "media previous"), { locked = true })
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center media"))

-- Brightness
-- NOTE: these go through Noctalia. On a desktop with an external monitor
-- they need DDC/CI working (ddcutil + i2c group) to do anything.
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(noctCall .. "brightness-up"),   { locked = true,repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctCall .. "brightness-down"), { locked = true, repeating = true })

-------------------
---- UTILITIES ----
-------------------

-- Screen Capture
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind("Print",                 hl.dsp.exec_cmd(noctCall .. "screenshot-region"))
hl.bind(mainMod .. " + Print",   hl.dsp.exec_cmd(noctCall .. "screenshot-fullscreen"))

-- Theming and Wallpaper
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(noctCall .. "panel-toggle wallpaper"))

-- Clipboard
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(noctCall .. "panel-toggle clipboard"))

-- Autoclicker toggle (With Notification status)
hl.bind(mainMod .. " + ALT + K", hl.dsp.exec_cmd("/home/bry/.local/bin/autoclick-toggle"))

-----------------
---- TV / AV ----
-----------------

hl.bind("CONTROL + ALT + C", hl.dsp.exec_cmd("fish -c 'tv app com.limelight'"))
hl.bind("CONTROL + ALT + T", hl.dsp.exec_cmd("fish -c 'tv on'"))

-------------------------------
---- WORKSPACES & MONITORS ----
-------------------------------

-- Focus workspace N / move active window to workspace N
for i = 1, 9 do
hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + CONTROL + Left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CONTROL + Right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CONTROL + Up",   hl.dsp.focus({ workspace = "e-3" }))
hl.bind(mainMod .. " + CONTROL + Down", hl.dsp.focus({ workspace = "e+3" }))
-- Jump to the next empty workspace on this monitor
hl.bind(mainMod .. " + Home", hl.dsp.focus({ workspace = "emptym" }))

-- Gaming workspace
hl.bind(mainMod .. " + G", hl.dsp.focus({ workspace = "9" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))

-- Cycle workspaces with the K65's volume wheel
hl.bind(mainMod .. " + CONTROL + XF86AudioRaiseVolume", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind(mainMod .. " + CONTROL + XF86AudioLowerVolume", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",       hl.dsp.workspace.toggle_special())
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special" }))

-- Pull the focused scratchpad window out to the current workspace
hl.bind(mainMod .. " + SHIFT + S", function()
local current_ws = hl.get_active_monitor().active_workspace.id
hl.dispatch(hl.dsp.window.move({ workspace = current_ws }))
end)
