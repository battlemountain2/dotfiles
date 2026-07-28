-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
hl.exec_cmd("hyprpm reload -n && hyprctl reload")
hl.exec_cmd("dbus-update-activation-environment --systemd --all")
hl.exec_cmd("noctalia")
hl.exec_cmd("kded6")
hl.exec_cmd("sleep 2 && env QT_QPA_PLATFORMTHEME='' easyeffects --service-mode --hide-window")
hl.exec_cmd("xhost +SI:localuser:root")

-- Force land on Workspace 1 upon logging in
hl.exec_cmd("hyprctl dispatch workspace 1")
end)
