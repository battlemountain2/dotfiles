#!/bin/sh

# 1. Unlock KDE Wallet if PAM kwallet is configured
if [ -x /usr/lib/pam_kwallet_init ]; then
    /usr/lib/pam_kwallet_init &
fi

# 2. Update D-Bus and systemd user activation environments
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd --all &
fi
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XCURSOR_THEME XCURSOR_SIZE QT_QPA_PLATFORMTHEME GDK_SCALE &
fi

# 3. Inform portals / apps of dark mode preference
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' &
fi

# 4. Polkit agent (prefers Noctalia's built-in agent if enabled; plasma-polkit-agent as fallback)
systemctl --user start plasma-polkit-agent >/dev/null 2>&1 &

# 5. Clipboard history store for Noctalia
if command -v cliphist >/dev/null 2>&1; then
    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &
fi

# 6. Optional 3-finger vertical overview gesture helper (requires user in 'input' group)
if command -v fusuma >/dev/null 2>&1 && [ -f "$HOME/.config/fusuma/config.yml" ]; then
    fusuma -d &
fi

# 7. Noctalia Desktop Shell
if command -v noctalia >/dev/null 2>&1; then
    noctalia &
fi
