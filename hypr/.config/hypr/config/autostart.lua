-- Auto-start config
hl.on("hyprland.start", function ()
hl.exec_cmd("hyprpm reload -n && hyprctl reload")
hl.exec_cmd("dbus-update-activation-environment --systemd --all")
hl.exec_cmd("systemctl --user start gpu-screen-recorder-ui")
hl.exec_cmd("systemctl --user start plasma-polkit-agent")
hl.exec_cmd("/usr/lib/kdeconnectd")

-- Clipboard history store for Noctalia launcher
hl.exec_cmd("wl-paste --type text --watch cliphist store")
hl.exec_cmd("wl-paste --type image --watch cliphist store")

hl.exec_cmd(SHELL_CMD)

-- Keeps one trailing empty workspace present so Noctalia's bar shows
-- "(highest used) + 1" instead of all 9. See scripts/dynamic-workspaces.sh.
hl.exec_cmd("pkill -f dynamic-workspaces.sh; \"$HOME/.config/hypr/scripts/dynamic-workspaces.sh\"")

-- kded6 is kept for plasma_accentcolor_service (writes accent into kdeglobals).
-- Its Plasma-shell-specific modules are disabled in ~/.config/kded6rc, which is
-- global — a Plasma session inherits it and will come up without a system tray,
-- global menu, or lock/logout shortcuts. Acceptable; Plasma is a rescue path only.
-- Baloo deliberately left loaded — indexer isn't running anyway.
hl.exec_cmd("kded6")

-- Force GTK/Zen Browser to acknowledge dark mode preference
hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")

hl.exec_cmd("sleep 2 && env QT_QPA_PLATFORMTHEME='' easyeffects --service-mode --hide-window")
end)
