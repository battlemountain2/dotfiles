# MacBook Omarchy profile

Snapshot source:

- Hostname: `alarm`
- Architecture: `aarch64`
- Omarchy: `4.0.0.r6673.g5939caf-1`
- Desktop shell: Omarchy Shell
- Window manager: Hyprland using Omarchy's Lua configuration

This directory mirrors paths beneath `$HOME`, but it is reference-only during
the desktop migration. It intentionally excludes backups, generated state,
calendar synchronization configuration, cloned plugins/themes, authentication
material, and Spotify UI session state.

## Notable behavior

- Retina scale 2
- Natural touchpad scrolling and 4-finger launcher swipe
- Three-finger horizontal workspace gestures & Mirador overview
- Mac-style Command shortcuts, screenshots, and floating window rules
- MacBook keyboard-backlight bindings and dynamic brightness control
- PiP, centered floating windows, smart borders, blur, shadows, and dimming
- Omarchy Shell custom bar (`bry.bar`) and Control Center (`bry.control-center`)
- Phone Wireless Bridge: LocalSend AirDrop daemon and BlueFerry iMessage/SMS hub
- Student & classroom toolkit:
  - Floating calculator (`Cmd + Option + C`, `omarchy-calc-toggle`)
  - Dropdown scratchpad (`Cmd + N`, `omarchy-scratchpad`)
  - Instant OCR grabber (`Cmd + Shift + O`, `omarchy-ocr`)
  - Classroom presentation mode (`Cmd + Option + P`, `omarchy-presentation-mode`)
  - Audio Guard auto-mute on headphone disconnect (`omarchy-audio-guard`)
  - ProMotion 120Hz/60Hz rate switcher with 20% battery alert (`omarchy-display-rate`)
  - Push-to-talk voice dictation (`Cmd + Shift + V`, `voxtype`)
- Helper scripts in `.local/bin/` and user systemd daemons in `.config/systemd/user/`

See [`omarchy-addons.md`](omarchy-addons.md) for reproducible plugin and theme
sources rather than vendored third-party repositories.
