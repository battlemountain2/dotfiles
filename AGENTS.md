# Dotfiles project

This repository describes two Hyprland machines owned by the same user.

- The repository-root `hypr/`, `noctalia/`, `kitty/`, and hardware-audio
  packages describe the x86_64 desktop (`cachyos-x8664`).
- `machines/macbook/` is a sanitized reference snapshot of the aarch64
  MacBook (`alarm`) running Omarchy.

## Goal

Gradually converge the desktop on Omarchy while preserving the best behavior
from both machines. Prefer shared interaction patterns, not identical complete
configuration trees.

## Safety and ownership

- Do not deploy or overwrite configuration merely because it exists here.
- Start migration work with a comparison and a plan unless explicitly asked to
  implement it.
- Never edit `/usr/share/omarchy`; it is package-owned. Omarchy customizations
  belong under `~/.config/`.
- Preserve the desktop's monitor, Nvidia, OLED/240 Hz, gaming, tearing, DDC/CI,
  TV/AV, PipeWire, and WirePlumber behavior as host-specific configuration.
- Preserve the MacBook's aarch64/Asahi, Retina scaling, touchpad gestures,
  keyboard backlight, battery, fingerprint, and idle behavior as host-specific
  configuration.
- Do not blindly copy either machine's `hyprland.lua`, shell configuration, or
  monitor configuration over the other.
- Do not commit credentials, tokens, cookies, browser profiles, calendar
  account data, OAuth state, clipboard history, or generated session state.
- Preserve unrelated user changes in a dirty worktree.

## Convergence priorities

1. Inventory equivalent behavior between the desktop and MacBook.
2. Separate shared keybindings/window rules from hardware-specific settings.
3. Replace Noctalia IPC with Omarchy APIs only when the equivalent is known.
4. Keep Omarchy defaults and add the smallest possible user overrides.
5. Validate Hyprland edits with `hyprctl reload` and then
   `hyprctl configerrors` on the target machine.
6. Treat `machines/macbook/` as reference material until a reviewed migration
   explicitly promotes files into deployable packages.

## Current correspondence

- Noctalia shell -> Omarchy Shell
- Hyprtasking overview -> Mirador overview
- Kitty/Dolphin/Kate/Zen -> Omarchy defaults plus user-selected applications
- Desktop workspace 9 gaming rules -> desktop-only
- MacBook three-finger gestures and Retina scale -> MacBook-only

When uncertain about current Hyprland window-rule syntax, consult the official
Hyprland documentation before editing rules.
