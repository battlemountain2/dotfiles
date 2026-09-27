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

-- Carousel navigation for scrolling layouts on both monitors.
-- Moves across windows/columns within the active monitor's carousel,
-- preventing monitor-hopping and avoiding accidental workspace jumps.
local function navigate_carousel(dir, delta)
    return function()
        local orig_mon = hl.get_active_monitor()
        local orig_ws = hl.get_active_special_workspace() or hl.get_active_workspace()
        if not orig_mon or not orig_ws then return end
        local orig_mon_name = orig_mon.name
        local orig_ws_id = orig_ws.id

        -- Try directional focus first
        hl.dispatch(hl.dsp.focus({ direction = dir }))

        local new_mon = hl.get_active_monitor()
        local new_ws = hl.get_active_special_workspace() or hl.get_active_workspace()

        -- If focus tried to jump across monitors or workspaces:
        if (new_mon and new_mon.name ~= orig_mon_name) or (new_ws and new_ws.id ~= orig_ws_id) then
            hl.dispatch(hl.dsp.focus({ monitor = orig_mon_name }))
            hl.dispatch(hl.dsp.layout(delta > 0 and "move +col" or "move -col"))
            local final_mon = hl.get_active_monitor()
            if final_mon and final_mon.name ~= orig_mon_name then
                hl.dispatch(hl.dsp.focus({ monitor = orig_mon_name }))
            end
        end
    end
end

hl.bind(mainMod .. " + Left",  navigate_carousel("left",  -1))
hl.bind(mainMod .. " + Right", navigate_carousel("right",  1))
hl.bind(mainMod .. " + Up",    navigate_carousel("up",    -1))
hl.bind(mainMod .. " + Down",  navigate_carousel("down",   1))

hl.bind("ALT + Tab", hl.dsp.window.cycle_next())

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
hl.bind(mainMod .. " + ALT + 1", function()
    hl.dispatch(hl.dsp.focus({ monitor = "DP-1" }))
    hl.dispatch(hl.dsp.cursor.move({ x = 1280, y = 720 }))
end)
hl.bind(mainMod .. " + ALT + 2", function()
    hl.dispatch(hl.dsp.focus({ monitor = "DP-2" }))
    hl.dispatch(hl.dsp.cursor.move({ x = 3280, y = 160 }))
end)

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
hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd(noctCall .. "panel-toggle yuuto/calculator:panel"))
hl.bind(mainMod .. " + B",          hl.dsp.exec_cmd(launchPrefix .. BROWSER))
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"))
hl.bind(mainMod .. " + Z",          hl.dsp.exec_cmd(noctCall .. "settings-toggle"))
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

-- Autoclicker toggle (With Notification status)
hl.bind(mainMod .. " + ALT + K", hl.dsp.exec_cmd("/home/bry/.local/bin/autoclick-toggle"))

-- GPU Screen Recorder Overlay
hl.bind("ALT + Z", hl.dsp.exec_cmd("gsr-ui launch-show"))

-----------------
---- TV / AV ----
-----------------

hl.bind("CONTROL + ALT + T", hl.dsp.exec_cmd("fish -c 'tv on'"))

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
