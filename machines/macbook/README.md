# MacBook Profile (`aarch64` / Aurora Linux — Umbriel + Noctalia)

This directory contains reference configuration for the Apple Silicon MacBook (`aarch64`, 14" Retina), updated for **Aurora Linux** with **Umbriel** and **Noctalia 5.4+**, alongside the earlier Omarchy/Hyprland reference files.

This directory mirrors paths beneath `$HOME`, and intentionally stays separate from the desktop Stow packages under `~/dotfiles/` because monitor layout, HiDPI scaling (`2x`), touchpad gestures, keyboard backlight, lid events, and NVIDIA/gaming rules differ between the two machines.

## Included Umbriel + Noctalia Configs

- [`.config/umbriel/config.toml`](.config/umbriel/config.toml)
  - Retina HiDPI (`scale = 2.0`, `xwayland_native_resolution = true`, `GDK_SCALE = "2"`)
  - MacBook touchpad (`natural_scroll = true`, `click_method = "clickfinger"`, `tap = true`, `scroll_factor = 0.4`, `follows_mouse_max_scroll = 0.0`)
  - Keyboard backlight (`Mod+XF86MonBrightnessUp/Down` &rarr; `noctalia msg keyboard-backlight-up/down`)
  - macOS-style screenshots (`Mod+Shift+3/4/5` &rarr; Noctalia fullscreen/region/annotate)
  - Workspaces on `Mod+Alt+...` and `Mod+Ctrl+...` (Command/Option ergonomics)
  - Lid wake PipeWire/WirePlumber recovery (`[events] lid_open`)
  - Smart borders, Zen browser blur, PiP, Dolphin/Nautilus/portal float sizing
- [`.config/umbriel/autostart.sh`](.config/umbriel/autostart.sh) — Starts Noctalia, `cliphist`, D-Bus/systemd env, polkit agent, and `fusuma` (if installed)
- [`.config/fusuma/config.yml`](.config/fusuma/config.yml) — Maps **3-finger vertical swipe up/down** to `umbriel msg overview-open` / `overview-close`
- [`.config/noctalia/config.toml`](.config/noctalia/config.toml) & [`.local/state/noctalia/settings.toml`](.local/state/noctalia/settings.toml) — Sanitized, single-display Retina UI scale (`1.0`), `battery` widget enabled, desktop-only `ddcutil` / `DP-1` / `DP-2` / NVIDIA widgets stripped
- [`.config/xdg-desktop-portal/`](.config/xdg-desktop-portal) — `umbriel-portals.conf`, `Umbriel-portals.conf`, `portals.conf`

## Installing Umbriel & Noctalia on Aurora Linux (`aarch64`)

Depending on which Aurora Silicon variant you installed (**Aurora ALARM** with `pacman` or **Fedora Aurora Remix** with `dnf`):

- **On Aurora ALARM (`aarch64` / `pacman`):**
  - Check if `noctalia` is available in your mirrors, or build `noctalia-git` / `umbriel-git` (+ `xdg-desktop-portal-umbriel`) from the AUR via `yay`/`paru` or `makepkg -si`.
- **Shared Noctalia Plugins & App Configs:**
  - The 22 custom Noctalia Luau plugins in `~/dotfiles/noctalia/.local/share/noctalia/plugins/` plus `ghostty`, `zed`, `fish`, `starship`, `btop`, `gtk`, and `qt` packages at the root of `~/dotfiles` are architecture-independent and can be copied over directly.

## 3-Finger Swipe for Umbriel Overview

Umbriel `0.1.0` currently hardcodes **4-finger swipe** for the workspace overview and **3-finger swipe** for workspace/strip navigation (there is no `[gestures]` finger-count setting in `config.toml` yet). Two options for 3-finger overview:

1. **`fusuma` (included at `.config/fusuma/config.yml`):**
   - Install `fusuma` (e.g. `yay -S fusuma` / `gem install fusuma`) and ensure your user is in the `input` group: `sudo usermod -aG input "$USER"`.
   - `config.yml` binds **3-finger swipe up/down** to `umbriel msg overview-open` / `overview-close`, leaving horizontal 3-finger swipes to Umbriel natively.
2. **Source patch (when building `umbriel-git` on `aarch64`):**
   - Update `src/input/gestures.cpp` to trigger `Overview` on 3-finger vertical swipes before compiling.

## Earlier Omarchy Reference Files

See [`omarchy-addons.md`](omarchy-addons.md) and `.config/hypr/` / `.config/omarchy/` in this folder for the earlier Omarchy 4 + Hyprland baseline.
