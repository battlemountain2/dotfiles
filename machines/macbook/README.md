# MacBook Profile (`aarch64` / Aurora Linux — Umbriel + Noctalia)

> **🤖 Next Agent / Deployment Runbook:** Start by reading **[`AGENT_HANDOFF.md`](AGENT_HANDOFF.md)** before modifying any files or installing packages on the MacBook. It covers Aurora Linux detection (`ostree`/`dnf` vs `pacman`/AUR), backups, 3-finger overview setup, and what to cherry-pick vs skip.

This directory contains the Apple Silicon MacBook (`aarch64`, 14" Retina) configuration, updated for **Aurora Linux** with **Umbriel** and **Noctalia 5.4+**, alongside the previous Omarchy 4 + Hyprland baseline and MacBook utility scripts.

It mirrors paths beneath `$HOME` and intentionally stays separate from the root desktop Stow packages (`cachyos-x8664`) because monitor layout, Retina scaling (`2x`), touchpad gestures, keyboard backlight, lid wake handling, and desktop NVIDIA/gaming rules differ between the two machines.

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

Depending on which Aurora variant is installed (**Aurora ALARM** with `pacman` or **Fedora Aurora Remix / Atomic**):

- **On Aurora ALARM (`aarch64` / `pacman`):**
  - Check if `noctalia` is in mirrors, or build `noctalia-git` / `umbriel-git` (+ `xdg-desktop-portal-umbriel`) from AUR via `yay`/`paru` or `makepkg -si`.
- **Shared Noctalia Plugins & App Configs:**
  - The 22 custom Noctalia Luau plugins in `~/dotfiles/noctalia/.local/share/noctalia/plugins/` plus `ghostty`, `zed`, `fish`, `starship`, `btop`, `gtk`, and `qt` packages at the root of `~/dotfiles` are architecture-independent and can be selectively copied over.

## 3-Finger Swipe for Umbriel Overview

Umbriel `0.1.0` hardcodes **4-finger swipe** for the workspace overview and **3-finger swipe** for workspace/strip navigation (no `[gestures]` finger-count setting exists in `config.toml` yet). See [`AGENT_HANDOFF.md`](AGENT_HANDOFF.md) for the two options:

1. **`fusuma` (included at `.config/fusuma/config.yml`):** Maps **3-finger swipe up/down** to `umbriel msg overview-open` / `overview-close`, leaving horizontal swipes to Umbriel natively. Requires membership in the `input` group (`sudo usermod -aG input "$USER"`).
2. **Source patch (when building `umbriel-git` on `aarch64`):** Patch `src/input/gestures.cpp` so 3-finger vertical swipes drive the native spring-animated overview.

## Previous MacBook Utilities & Omarchy Reference

Also preserved in this folder from the earlier `alarm` (`aarch64` Omarchy 4 + Hyprland) setup:
- Phone Wireless Bridge: LocalSend AirDrop daemon and BlueFerry iMessage/SMS hub
- Student & classroom scripts in `.local/bin/` & `.config/systemd/user/`:
  - `omarchy-ocr`, `omarchy-presentation-mode`, `omarchy-audio-guard`, `omarchy-display-rate` (ProMotion 120Hz/60Hz), `omarchy-power-profile-auto`, `voxtype.service`
  - `pcsx2` (`muvm/fex` wrapper) and `.local/bin/tv` / `movie`
- Legacy Omarchy / Hyprland configs under `.config/hypr/` and `.config/omarchy/` (see [`omarchy-addons.md`](omarchy-addons.md))
