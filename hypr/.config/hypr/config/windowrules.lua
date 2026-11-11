-- Window rules wiki https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Center ordinary floating windows. Anonymous X11 menus must keep the anchor
-- coordinates supplied by their app instead of being centered on the monitor.
hl.window_rule({ match = { float = true, xwayland = false }, center = true })
hl.window_rule({ match = { float = true, xwayland = true, class = "negative:^$" }, center = true })

-- ChatGPT's pet overlay shares the main window's title and opens as floating.
-- Native Wayland and XWayland use different capitalization for the app class.
hl.window_rule({
    name = "chatgpt-pet-clear-overlay",
    match = { class = "^[Cc]hatgpt$", title = "^ChatGPT$", float = true },
    center = false,
    no_initial_focus = true,
    no_follow_mouse = true,
    no_blur = true,
    no_dim = true,
    no_shadow = true,
    border_size = 0,
    opacity = "1.0 override 1.0 override",
})

-- Lemon Studio startup splash: transparent shaped disc overlay
hl.window_rule({
    name = "lemonstudio-splash",
    match = { class = "^(lemonstudio-splash|lemonstudio)$", title = "^(Lemon Studio Splash|Lemon Studio)$", float = true },
    center = true,
    no_blur = true,
    no_dim = true,
    no_shadow = true,
    border_size = 0,
    rounding = 0,
    no_anim = true,
})

-- Picture-in-Picture
hl.window_rule({
    match               = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
               float               = true,
               keep_aspect_ratio   = true,
               size                = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
               pin                 = true,
})

-- Smart borders: keep gaps + rounding, drop the border on a lone tiled window
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0 })

-- Gaming
local gamingApps = "^(steam_app.*|gamescope)$"
local nativeGames = "^(cs2|deadlock|dota2|Bloodborne|bb-probe)$"
local gamingWorkspace = "9"

hl.window_rule({ match = { content = "game" }, workspace = gamingWorkspace, idle_inhibit = "focus" })
hl.window_rule({ match = { class = gamingApps }, workspace = gamingWorkspace, idle_inhibit = "focus" })
hl.window_rule({ match = { class = nativeGames }, workspace = gamingWorkspace, idle_inhibit = "focus" })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Launching\\.{3})$" }, float = true, center = true, workspace = gamingWorkspace })
hl.window_rule({
    name = "steam-popups",
    match = { class = "^(steam)$", title = "^$" },
    float = true,
    center = false,
    stay_focused = true,
    min_size = { 1, 1 },
})
hl.window_rule({
    match = {
        class         = gamingApps,
        title         = "^(.+)$",
               initial_title = "negative:^(.*\\\\home\\\\.*)$",
    },
    content          = "game",
    decorate         = false,
    fullscreen_state = 2,
    size             = { "monitor_w", "monitor_h" },
    sync_fullscreen  = true,
})
hl.window_rule({
    match = {
        class         = "^(steam_app.*)$",
               initial_title = "^$",
    },
    center           = true,
    float            = true,
    fullscreen       = false,
    fullscreen_state = 0,
    workspace        = gamingWorkspace,
})

-- Apps

-- Always float terminal windows
hl.window_rule({
    name = "floating-terminals",
    match = { class = "^(ghostty|com\\.mitchellh\\.ghostty|kitty)$" },
    float = true,
})

-- One size for file-management windows so Dolphin and the portal file picker
-- always match. Change it here and both follow.
local fileWindowSize = { "max(monitor_w, monitor_h)*0.50", "min(monitor_w, monitor_h)*0.55" }

hl.window_rule({ match = { class = "^(.*\\.exe)$", float = true }, center = true, fullscreen_state = 0 })
hl.window_rule({ match = { class = "^(.*[Ll]auncher.*)$" }, float = true })
hl.window_rule({ match = { class = "^(.*[Cc]alc.*)$" }, float = true, size = { "max(monitor_w, monitor_h)*0.17", "min(monitor_w, monitor_h)*0.43" } })
hl.window_rule({ match = { class = "^(org\\.kde\\.keditfiletype)$" }, float = true })
hl.window_rule({ match = { class = "^(org\\.kde\\.ark)$" }, size = { "max(monitor_w, monitor_h)*0.40", "min(monitor_w, monitor_h)*0.40" } })
hl.window_rule({
    match = { class = "^(.*satty.*)$" },
               float = true,
               min_size = { "max(monitor_w, monitor_h)*0.35", "min(monitor_w, monitor_h)*0.35" },
})
hl.window_rule({ match = { class = "^(dev\\.)?(noctalia\\.Noctalia(\\.Settings)?)$" }, float = true, size = { "monitor_w*0.70", "monitor_h*0.70" } })

-- Portal file pickers default to ~750x690, which is small on 1440p.
-- Matches the dotted KDE class; the gtk backend uses a hyphenated class and
-- is left at its own default. Float/centre come from the modal rules above.
hl.window_rule({
    match = { class = "^(org\\.freedesktop\\.impl\\.portal\\.desktop\\..*)$" },
    size  = fileWindowSize,
})
hl.window_rule({
    match = {
        class = "^(org\\.kde\\.dolphin)$",
               title = "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Configure.*|Properties.*|Choose\\sApplication.*)$",
    },
    float = true,
    size = fileWindowSize,
})

-- Opacity Overrides (100% Solid Opaque / Zero Transparency)
-- Prevents background bleed-through and preserves color accuracy for video playback,
-- photo viewing, web browsing, creative tools, and games whether active or inactive.
local terminals = "^(kitty|ghostty|com\\.mitchellh\\.ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"
local browsers = "^([Hh]elium.*|[Ff]irefox.*|[Gg]oogle-chrome.*|[Cc]hromium.*|[Bb]rave-browser.*|chrome-.*)$"
local mediaPlayers = "^(.*[Ss]tremio.*|[Cc]ider.*|[Ss]potify.*|mpv|.*vlc.*|.*haruna.*|org\\.kde\\.elisa|.*plex.*|kodi|celluloid|totem|FreeTube)$"
local creativeAndGraphics = "^(.*gwenview.*|loupe|eog|imv|feh|viewnior|nomacs|Gimp.*|gimp.*|.*inkscape.*|blender|krita|kdenlive|org\\.freecad\\.FreeCAD)$"
local opaqueUtilities = "^(com\\.obsproject\\.Studio|obs|gpu-screen-recorder-ui|.*satty.*|steam|steamwebhelper|sober|org\\.vinegarhq\\.Sober|PrismLauncher|heroic|lutris|org\\.kde\\.okular|libreoffice.*|.*[Cc]alc.*|org\\.gnome\\.Calculator)$"

hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" })
hl.window_rule({ match = { class = browsers }, opacity = "1.0 override 1.0 override" })
-- Zen Browser: allow client translucency (Zen mods & wallpaper blur) and keep smooth 60fps when unfocused
hl.window_rule({ match = { class = "^([Zz]en.*)$" }, render_unfocused = true })
-- Iris Mail: allow client translucency & wallpaper dual-kawase blur for liquid glass sidebar
hl.window_rule({
    match = { class = "^(io\\.github\\.battlemountain2\\.Iris)$" },
    opacity = "0.98 override 0.98 override",
})
hl.window_rule({ match = { class = mediaPlayers }, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { class = creativeAndGraphics }, opacity = "1.0 override 1.0 override" })
hl.window_rule({ match = { class = opaqueUtilities }, opacity = "1.0 override 1.0 override" })

-- Float Utility Windows
local floatApps = {
    { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
    { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
    { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

    -- Float Common Modals
    local modalMatches = {
        { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
        { initial_title = "^(Open File)$" },
        -- Portal backends use two different class conventions:
        --   gtk/hyprland: xdg-desktop-portal-gtk      (hyphens)
        --   kde:          org.freedesktop.impl.portal.desktop.kde  (dots)
        -- Verified with hyprctl activewindow. Both forms needed.
        { class = "^(.*[Xx]dg-[Dd]esktop-[Pp]ortal.*)$" },
        { class = "^(org\\.freedesktop\\.impl\\.portal\\.desktop\\..*)$" },
        { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
        { class = "^(.*dialog.*)$" },
        { title = "^(.*dialog.*)$" },
        { class = "^(hyprland-share-picker)$"},
    }
    for _, m in ipairs(modalMatches) do hl.window_rule({ match = m, float = true }) end

        -- Ignore maximize requests from all apps. You'll probably like this.
        hl.window_rule({
            name  = "suppress-maximize-events",
            match = { class = ".*" },
            suppress_event = "maximize",
        })

        -- Fix some dragging issues with XWayland
        hl.window_rule({
            name  = "fix-xwayland-drags",
            match = {
                class      = "^$",
                title      = "^$",
                xwayland   = true,
                float      = true,
                fullscreen = false,
                pin        = false,
            },
            -- Anonymous X11 menus carry their own anchor coordinates. The
            -- generic floating-window centering rule must not reposition them.
            center = false,
            -- These menus never take normal window focus. Keep them solid
            -- instead of applying inactive-window translucency/dimming.
            opacity = "1.0 override 1.0 override",
            no_dim = true,
            no_blur = true,
            no_focus = true,
        })

        -- Allow screen tearing for competitive games to minimize input lag
        local tearingGames = "^(cs2|deadlock|dota2|steam_app_730|steam_app_1422450|steam_app_2767030|steam_app_2356550|steam_app_105600)$"
        hl.window_rule({ match = { class = tearingGames }, immediate = true })

-- Subtle entry/exit scale for the LG portrait workspace.
hl.window_rule({ match = { workspace = "10", float = false }, animation = "popin 95%" })
