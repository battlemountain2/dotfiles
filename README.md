# Bry's Hyprland dotfiles

This repository now contains both sides of the setup:

- The root-level Stow packages are the existing CachyOS desktop configuration,
  built around custom Hyprland and Noctalia.
- [`machines/macbook`](machines/macbook) is a sanitized snapshot of the current
  aarch64 MacBook configuration, built around Omarchy 4 and Hyprland.

The MacBook snapshot is intentionally reference-only. Do not Stow it wholesale
onto the desktop: monitor, GPU, input, idle, and application assumptions differ.
Use it as source material while migrating the desktop to Omarchy in reviewed
steps.

## Continue on the desktop

```bash
cd ~/dotfiles
git pull --ff-only
codex
```

Recommended first request:

```text
Read AGENTS.md and compare the root desktop configuration with
machines/macbook. Produce a phased plan for moving the desktop to Omarchy while
preserving its Nvidia, monitor, OLED/240 Hz, gaming, DDC/CI, TV/AV, audio, and
application behavior. Do not modify files yet.
```

After reviewing that plan:

```text
Implement only phase 1. Preserve host-specific behavior, inspect the current
Omarchy defaults before adding overrides, and validate every Hyprland change.
```

## Updating the MacBook snapshot

Copy only deliberate user configuration into `machines/macbook/.config`.
Never copy runtime state, cloned plugin repositories, `calendar-sync.json`,
OAuth data, credentials, cookies, clipboard history, or backup files. Remove
plugin `sessionState` values from `shell.json` before committing.
