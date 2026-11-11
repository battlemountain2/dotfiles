-- Keep this dedicated FL Studio Wine environment on 8 and away from games on 9.
local flPrefix = os.getenv("HOME") .. "/.local/share/fl-studio-cachyos/prefix"
local flEnvironmentEntry = "\0WINEPREFIX=" .. flPrefix .. "\0"
local flTag = "fl-studio-isolated"

local function audit(message)
    local file = io.open(os.getenv("HOME") .. "/.local/share/fl-studio-cachyos/logs/workspace-routing.log", "a")
    if file then
        file:write(os.date("%Y-%m-%d %H:%M:%S"), " ", message, "\n")
        file:close()
    end
end

local function belongsToFL(window)
    if not window or not window.pid or window.pid <= 0 then return false end
    local file = io.open("/proc/" .. tostring(window.pid) .. "/environ", "rb")
    if not file then return false end
    local environment = file:read(262144) or ""
    file:close()
    return ("\0" .. environment .. "\0"):find(flEnvironmentEntry, 1, true) ~= nil
end

-- Tag the known main class before mapping, and the rest by exact prefix below.
hl.window_rule({
    name = "fl-studio-workspace-8",
    match = { class = "(?i)^(fl64|explorer)\\.exe$" },
    tag = "+" .. flTag,
    workspace = "8 silent",
})
hl.window_rule({
    name = "fl-studio-window-placement",
    match = { tag = flTag },
    -- Floating avoids tiling splash/plugin/dialog windows to the column size.
    float = true,
    center = false,
    focus_on_activate = true,
    idle_inhibit = "focus",
})
hl.window_rule({
    name = "fl-studio-desktop-maximize",
    match = {
        class = "(?i)^explorer\\.exe$",
        title = "(?i)^FLStudio.*$",
    },
    fullscreen_state = 1,
})

-- Unlike pointer confinement, this does not change Deadlock's input behavior.
-- Workspace 8 restores normal focus to FL; workspace 9 protects the game.
local focusGuard = hl.window_rule({
    name = "fl-studio-gaming-focus-guard",
    enabled = false,
    match = { tag = flTag },
    no_focus = true,
    no_initial_focus = true,
    focus_on_activate = false,
    no_follow_mouse = true,
})
local guardEnabled = false
local function updateFocusGuard()
    local gaming = hl.get_workspace(9)
    local enabled = gaming ~= nil and gaming.active == true
    if enabled ~= guardEnabled then
        focusGuard:set_enabled(enabled)
        guardEnabled = enabled
        audit("gaming_focus_guard=" .. tostring(enabled))
    end
end

local function tagFL(window)
    if not belongsToFL(window) then return false end
    hl.dispatch(hl.dsp.window.tag({ window = window, tag = "+" .. flTag }))
    return true
end

local autoMaximizedWindows = {}

local function maximizeDesktopIfFL(window)
    if not window or not belongsToFL(window) then return end
    local isDesktop = (window.class and window.class:lower() == "explorer.exe")
        or (window.title and window.title:find("FLStudio"))
    if not isDesktop then return end

    local winKey = window.address or tostring(window.pid)
    if autoMaximizedWindows[winKey] then return end

    if window.fullscreen == 0 then
        autoMaximizedWindows[winKey] = true
        hl.dispatch(hl.dsp.window.fullscreen({ window = window, mode = "maximized" }))
        audit("auto_maximized win=" .. tostring(winKey) .. " title=" .. tostring(window.title))
    elseif window.fullscreen == 1 then
        autoMaximizedWindows[winKey] = true
    end
end

local function routeFL(window)
    if not window or not window.mapped or not tagFL(window) then return end
    -- Allow detached windows (like Mixer/Plugins) to stay freely on Monitor 2 (workspaces >= 10)
    if window.workspace and window.workspace.id and window.workspace.id >= 10 then
        return
    end
    -- Ensure FL Studio windows stay off the gaming workspace 9 and default to 8
    if not window.workspace or window.workspace.id ~= 8 then
        hl.dispatch(hl.dsp.window.move({ window = window, workspace = 8, follow = false }))
    end
    maximizeDesktopIfFL(window)
    audit("pid=" .. tostring(window.pid) .. " workspace="
        .. tostring(window.workspace and window.workspace.addressable_name))
end

-- The early event tags helper/installer windows before their initial focus;
-- the late event routes them once they are mapped and can be moved safely.
hl.on("window.open_early", tagFL)
hl.on("window.open", routeFL)
hl.on("window.title", maximizeDesktopIfFL)
hl.on("window.close", function(window)
    if window then
        local winKey = window.address or tostring(window.pid)
        autoMaximizedWindows[winKey] = nil
    end
end)
hl.on("window.move_to_workspace", function(window, workspace)
    if workspace and workspace.id == 9 then routeFL(window) end
end)
hl.on("workspace.active", updateFocusGuard)
hl.on("monitor.focused", updateFocusGuard)
hl.on("config.reloaded", function()
    updateFocusGuard()
    for _, window in ipairs(hl.get_windows()) do routeFL(window) end
    audit("focus_guard_ready=" .. tostring(guardEnabled))
end)
-- Quick DAW Toggle: SUPER + ALT + M toggles between FL Studio (workspace 8) and previous workspace
local mainMod = "SUPER"
local lastNonFLWorkspace = 1

hl.on("workspace.active", function()
    local ws = hl.get_active_workspace()
    if ws and ws.id and ws.id ~= 8 and ws.id ~= 9 then
        lastNonFLWorkspace = ws.id
    end
end)

hl.bind(mainMod .. " + ALT + M", function()
    local ws = hl.get_active_workspace()
    if ws and ws.id == 8 then
        hl.dispatch(hl.dsp.focus({ workspace = lastNonFLWorkspace }))
    else
        hl.dispatch(hl.dsp.focus({ workspace = 8 }))
    end
end)
