local mainMod = "SUPER"
local noctCall = SHELL_IPC  -- set in config/variables.lua
local launchPrefix = "" -- if you are not using UWSM, make this empty (e.g. "")

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- Window manipulation
-- Use window.close() to gracefully close the active window (xdg_toplevel.close).
-- Note: window.kill() sends SIGKILL to the process PID, which kills all windows
-- belonging to multi-window processes (e.g. Helium/Chromium/Brave/Firefox).
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(mainMod .. " + F",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
pcall(hl.unbind, mainMod .. " + W")
hl.bind(mainMod .. " + W",           hl.dsp.window.fullscreen({ mode = "maximized" }))
pcall(hl.unbind, mainMod .. " + SHIFT + W")
hl.bind(mainMod .. " + SHIFT + W",   hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + J",           hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + P",   hl.dsp.window.pin())
hl.bind(mainMod .. " + P",           hl.dsp.exec_cmd(noctCall .. "panel-toggle oldirtty/color_picker:panel"))

-- Baseline Focus Controls & Carousel Navigation
-- Each monitor has nine numbered workspaces; include empty destinations.
local function adjacent_workspace(delta)
    local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
    local monitor = hl.get_active_monitor()
    if not ws or not monitor then return nil end
    local first, last
    if monitor.name == "DP-1" then first, last = 1, 9
    elseif monitor.name == "DP-2" then first, last = 10, 18
    else return nil end
    if ws.id < first or ws.id > last then return nil end
    local target = math.max(first, math.min(last, ws.id + delta))
    if target ~= ws.id then return target end
end

-- Navigate the scrolling layout itself, keeping focus on this workspace.
-- Left/right traverse horizontal columns; up/down traverse vertical strips.
local function navigate_carousel(dir)
    return function()
        local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
        if ws and ws.tiled_layout == "scrolling" then
            hl.dispatch(hl.dsp.layout("focus " .. dir:sub(1, 1)))
        else
            hl.dispatch(hl.dsp.focus({ direction = dir }))
        end
    end
end

hl.bind(mainMod .. " + Left",  navigate_carousel("left"))
hl.bind(mainMod .. " + Right", navigate_carousel("right"))
hl.bind(mainMod .. " + Up",    navigate_carousel("up"))
hl.bind(mainMod .. " + Down",  navigate_carousel("down"))

hl.bind("ALT + Tab", hl.dsp.exec_cmd("noctalia msg window-switcher"))

-- Move window position within the layout
hl.bind(mainMod .. " + SHIFT + Left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + Up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + Down",  hl.dsp.window.move({ direction = "down" }))

-- Browse the LG's vertical scrolling layout; elsewhere take the window with you.
local function ctrl_scroll(direction, workspace_delta)
    return function()
        local ws = hl.get_active_special_workspace() or hl.get_active_workspace()
        if ws and ws.tiled_layout == "scrolling" and ws.id >= 10 and ws.id <= 18 then
            -- Move the carousel view itself by one window-sized step.
            hl.dispatch(hl.dsp.layout(direction == "down" and "move +col" or "move -col"))
        elseif ws and ws.id >= 1 and ws.id <= 9 then
            -- Numeric targets create empty destinations; m+/-1 only visits existing ones.
            local step = direction == "down" and 1 or -1
            local target = ((ws.id - 1 + step) % 9) + 1
            hl.dispatch(hl.dsp.window.move({ workspace = target }))
        else
            hl.dispatch(hl.dsp.window.move({ workspace = workspace_delta }))
        end
    end
end
hl.bind(mainMod .. " + CONTROL + mouse_down", ctrl_scroll("down", "m+1"))
hl.bind(mainMod .. " + CONTROL + mouse_up",   ctrl_scroll("up", "m-1"))

-- Send the window and go with it
hl.bind(mainMod .. " + CONTROL + SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + Left",  hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r+1", follow = false }))
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "r-1", follow = false }))

-- Focus a display while leaving fullscreen windows on their current workspace.
local function focus_monitor(selector)
    return function()
        local previous = hl.get_active_monitor()
        hl.dispatch(hl.dsp.focus({ monitor = selector }))
        local monitor = hl.get_active_monitor()
        if not monitor or (previous and monitor.name == previous.name) then return end

        -- no_warps keeps ordinary window focus still; move only on a monitor change.
        local width, height = monitor.width / monitor.scale, monitor.height / monitor.scale
        if monitor.transform % 2 == 1 then width, height = height, width end
        hl.dispatch(hl.dsp.cursor.move({
            x = math.floor(monitor.position.x + width / 2),
            y = math.floor(monitor.position.y + height / 2),
        }))
    end
end

for key, direction in pairs({ Left = "l", Right = "r", Up = "u", Down = "d" }) do
    hl.bind(mainMod .. " + ALT + " .. key, focus_monitor(direction))
end

hl.bind(mainMod .. " + ALT + 1", focus_monitor("DP-1"))
hl.bind(mainMod .. " + ALT + 2", focus_monitor("DP-2"))

-- Move the focused window onto the target monitor's active workspace.
hl.bind(mainMod .. " + ALT + mouse_up",   hl.dsp.window.move({ monitor = "DP-1" }))
hl.bind(mainMod .. " + ALT + mouse_down", hl.dsp.window.move({ monitor = "DP-2" }))

-- Move window to workspace N without following it
for i = 1, 9 do
hl.bind(mainMod .. " + SHIFT + CONTROL + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
-- Move & Resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Keyboard Window Resizing
local step = 30

hl.bind(mainMod .. " + ALT + SHIFT + Left",  hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + SHIFT + Right", hl.dsp.window.resize({ x = step,  y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + SHIFT + Up",    hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + SHIFT + Down",  hl.dsp.window.resize({ x = 0, y = step,  relative = true }), { repeating = true })

------------------
---- LAUNCHER ----
------------------
hl.bind(mainMod .. " + Return",     hl.dsp.exec_cmd(launchPrefix .. EDITOR))
hl.bind(mainMod .. " + E",          hl.dsp.exec_cmd(launchPrefix .. FILE_MANAGER))
hl.bind(mainMod .. " + T",          hl.dsp.exec_cmd(launchPrefix .. TERMINAL))
hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd("/home/bry/.local/bin/cursor-calculator"))
hl.bind(mainMod .. " + B",          hl.dsp.exec_cmd(launchPrefix .. BROWSER))
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"))
hl.bind(mainMod .. " + Z",          hl.dsp.exec_cmd(noctCall .. "settings-toggle"))
hl.bind(mainMod .. " + comma",      hl.dsp.exec_cmd("/home/bry/.local/bin/hypr-keybinds"))
hl.bind(mainMod .. " + X",          hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center"))
hl.bind(mainMod .. " + Space",      hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher"))
hl.bind(mainMod .. " + period",     hl.dsp.exec_cmd(noctCall .. "panel-toggle liamwh/emoji-picker:desktop"))
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
hl.bind(mainMod .. " + ALT + A", hl.dsp.exec_cmd("/home/bry/.local/bin/toggle-audio-sink"), { locked = true })

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
hl.bind(mainMod .. " + ALT + W", hl.dsp.exec_cmd(noctCall .. "panel-toggle wallpaper"))

-- Clipboard
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(noctCall .. "panel-toggle clipboard"))

-- Recover the portrait bar without restarting the desktop shell.
hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd("/home/bry/.local/bin/noctalia-bar-recover"))

-- Autoclicker toggle (With Notification status)
hl.bind(mainMod .. " + ALT + K", hl.dsp.exec_cmd("/home/bry/.local/bin/autoclick-toggle"))

-- GPU Screen Recorder Overlay & Shortcuts (ShadowPlay)
hl.bind("ALT + Z", hl.dsp.exec_cmd("gsr-ui launch-show"))
hl.bind("ALT + C", hl.dsp.exec_cmd("gsr-ui-cli replay-save"))
hl.bind("ALT + R", hl.dsp.exec_cmd("gsr-ui-cli toggle-record"))

-----------------
---- TV / AV ----
-----------------

hl.bind("CONTROL + ALT + T", hl.dsp.exec_cmd("fish -c 'tv on'"))

---------------------
---- STREAM MODE ----
---------------------

-- Toggle Noctalia Stream Privacy Mode (DND notifications on/off)
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd("/home/bry/.config/hypr/scripts/stream_mode.sh"))

-------------------------------
---- WORKSPACES & MONITORS ----
-------------------------------

-- Focus workspace N / move active window to workspace N
for i = 1, 9 do
hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + CONTROL + Left",  hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + CONTROL + Right", hl.dsp.focus({ workspace = "+1" }))
-- Move the window one workspace on its monitor and follow it.
local function ctrl_vertical_navigation(delta)
    return function()
        local target = adjacent_workspace(delta)
        if target then
            hl.dispatch(hl.dsp.window.move({ workspace = target, follow = true }))
        end
    end
end
hl.bind(mainMod .. " + CONTROL + Up", ctrl_vertical_navigation(-1))
hl.bind(mainMod .. " + CONTROL + Down", ctrl_vertical_navigation(1))
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



-- Desktop magnification, independent of individual app zoom.
local function desktop_zoom(multiplier)
    return function()
        local current = hl.get_config("cursor.zoom_factor") or 1.0
        local target = math.max(1.0, math.min(4.0, current * multiplier))
        if target < 1.01 then target = 1.0 end
        hl.config({ cursor = { zoom_factor = target } })
    end
end
hl.bind("SUPER + SHIFT + mouse_up", desktop_zoom(1.1), { submap_universal = true })
hl.bind("SUPER + SHIFT + mouse_down", desktop_zoom(1 / 1.1), { submap_universal = true })
