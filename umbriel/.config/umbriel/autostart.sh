#!/bin/sh

# 1. Unlock KDE Wallet with PAM credentials from display manager
if [ -x /usr/lib/pam_kwallet_init ]; then
    /usr/lib/pam_kwallet_init &
fi

# 2. Update DBus and systemd activation environments
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd --all &
fi
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XCURSOR_THEME XCURSOR_SIZE QT_QPA_PLATFORMTHEME &
fi

# 3. Inform portals / apps of dark mode preference
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' &

# 4. KDE background daemons & Polkit agent
systemctl --user start plasma-polkit-agent &
[ -x /usr/lib/kdeconnectd ] && /usr/lib/kdeconnectd &
command -v kded6 >/dev/null 2>&1 && kded6 &

# 5. Clipboard history store for Noctalia
command -v cliphist >/dev/null 2>&1 && {
    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &
}

# 6. GPU Screen Recorder daemon
command -v gsr-ui >/dev/null 2>&1 && gsr-ui launch-daemon &

# 7. Audio effects
if command -v easyeffects >/dev/null 2>&1; then
    (sleep 2 && env QT_QPA_PLATFORMTHEME='' easyeffects --service-mode --hide-window) &
fi

# 8. Noctalia Desktop Shell
command -v noctalia >/dev/null 2>&1 && noctalia &
