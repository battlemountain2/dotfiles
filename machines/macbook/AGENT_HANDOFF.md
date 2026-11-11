# MacBook Deployment Guide for Next Agent (Aurora Linux — Umbriel + Noctalia)

> **Purpose:** Safely deploy the MacBook Umbriel + Noctalia configuration in `machines/macbook/` onto the user's **Apple Silicon MacBook running Aurora Linux**, without breaking the existing OS session, display/input setup, or desktop-only configs.

---

## 0. Hard Safety Rules (Read First)

1. **NEVER run `~/.local/bin/dotfiles push` on the MacBook.**
   The root-level Stow packages (`umbriel/`, `hypr/`, `portals/`, `noctalia/`, `systemd/`, `qt/`, `wireplumber/`, `bin/`, etc.) target the `x86_64` CachyOS NVIDIA desktop (`matcha`). Pushing them onto the MacBook would deploy `DP-1`/`DP-2` monitor rules, `ddcutil` bus numbers, `FiiO K11` DAC configs, `x86_64` binaries, and NVIDIA gaming rules.
2. **Back up before overwriting.**
   Before touching anything in `~/.config/` or `~/.local/`, copy existing configs (e.g. `~/.config/umbriel`, `~/.config/noctalia`, `~/.local/state/noctalia`, `~/.config/xdg-desktop-portal`, `~/.config/fusuma`) to a timestamped backup folder like `~/.backup-pre-umbriel-<date>/`.
3. **Keep the existing desktop session intact.**
   Do **not** uninstall the existing Aurora desktop session (KDE Plasma / Omarchy / Hyprland) or overwrite `/etc/greetd/` or SDDM config without keeping a working session fallback so the user can always log back into their previous desktop if anything fails.
4. **Verify every keybind target exists before committing to it.**
   Check which browser (`zen-browser`, `firefox`, `chromium`, `helium-browser`), terminal (`ghostty`, `kitty`, `alacritty`, `konsole`), and file manager (`dolphin`, `nautilus`) are installed on Aurora and update `machines/macbook/.config/umbriel/config.toml` if needed before deploying.
5. **Never push secrets or runtime state back to GitHub.**
   Do not copy `restore_token`, browser profiles, OAuth tokens, calendar accounts, clipboard history, or `screen_time.json` back into `~/dotfiles`.

---

## 1. Phase 1 — Inspect the MacBook First (Read-Only)

Run discovery commands before installing packages or copying files:

```bash
# 1. Architecture, OS flavor, and package manager
uname -m
cat /etc/os-release
which pacman yay paru dnf rpm-ostree brew 2>/dev/null

# 2. Current compositor/DE, login manager, and installed apps
echo "XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
ls /usr/share/wayland-sessions/ /etc/greetd/ /etc/sddm.conf* 2>/dev/null || true
for cmd in umbriel noctalia ghostty kitty alacritty dolphin nautilus zen-browser firefox helium-browser cliphist wl-copy brightnessctl fusuma; do
  command -v "$cmd" && echo "FOUND: $cmd" || echo "MISSING: $cmd"
done

# 3. Hardware details: display connector/modes, touchpad, keyboard backlight, user groups
cat /sys/class/drm/card*-*/status 2>/dev/null || true
ls /sys/class/backlight/ /sys/class/leds/*kbd* 2>/dev/null || true
groups
```

Determine whether the MacBook is:
- **Aurora ALARM (`aarch64`, `pacman`/AUR)** — Arch Linux ARM base; AUR packages (`umbriel-git`, `noctalia-git`) compile natively on `aarch64`.
- **Fedora Aurora / Immutable (`rpm-ostree` / `dnf` / Copr)** — Immutable root (`ostree`) or Fedora remix; do **not** run Arch `pacman` commands. Package installation must follow Fedora/Copr/container/Homebrew (`~/.local`) build paths safely without breaking `ostree` updates.

---

## 2. Phase 2 — Install Umbriel & Noctalia

Ensure **both** `umbriel` (plus `xdg-desktop-portal-umbriel`) and **Noctalia v5 (`noctalia` >= 5.4.1)** are installed for `aarch64`:

### If Aurora ALARM (`pacman` / AUR):
1. Check repos first: `pacman -Ss noctalia umbriel`.
2. Build missing components from AUR (`yay`/`paru` or `makepkg -si`):
   - `umbriel-git` (check `PKGBUILD` includes `xdg-desktop-portal-umbriel` or build it alongside; dependencies include `wlroots0.20`, `tomlplusplus`, `libdisplay-info`, `libei`, `cairo`, `pango`, `lcms2`, `xorg-xwayland`).
   - `noctalia` / `noctalia-git` (note: Noctalia v5 is the C++ rewrite, distinct from legacy v4 Quickshell `noctalia-shell`).
3. Supporting runtime tools: `cliphist`, `wl-clipboard`, `brightnessctl`, `adw-gtk3-theme`, `breeze` cursors, `polkit-kde-agent` (or Noctalia's built-in `polkit_agent = true` in `settings.toml`).

### If Fedora Aurora Remix / Atomic (`dnf` / `rpm-ostree`):
- Check if a Copr repo provides `umbriel` and `noctalia` for Fedora `aarch64`, or compile upstream [`noctalia-dev/umbriel`](https://github.com/noctalia-dev/umbriel) and [`noctalia-dev/noctalia`](https://github.com/noctalia-dev/noctalia) cleanly (and on atomic/immutable systems, check where user-built Wayland session files and binaries should live — e.g. `/usr/local/bin` or `~/.local/bin` + layered portal/session unit). Keep the stock Aurora KDE session selectable in SDDM!

---

## 3. Phase 3 — Set Up 3-Finger Swipe for Umbriel Overview

Umbriel `0.1.0` currently hardcodes **4-finger swipe** for workspace overview and **3-finger swipe** for workspace/strip navigation (`[gestures]` finger remapping does not exist in `config.toml` yet). Choose one of these two methods with the user:

### Option A (Zero source edits): `fusuma` + `input` group
1. Install `fusuma` (AUR `fusuma` or `gem install fusuma` + `libinput` tools).
2. Add user to the `input` group: `sudo usermod -aG input "$USER"` *(requires logout/reboot to take effect)*.
3. Copy `machines/macbook/.config/fusuma/config.yml` &rarr; `~/.config/fusuma/config.yml`:
   - Maps **3-finger swipe up** &rarr; `umbriel msg overview-open`
   - Maps **3-finger swipe down** &rarr; `umbriel msg overview-close`
   - Intentionally leaves 3-finger **left/right** unbound in `fusuma` so Umbriel's native 3-finger horizontal workspace swipe works without double-firing.
4. `machines/macbook/.config/umbriel/autostart.sh` automatically launches `fusuma -d` if present.
5. **Caveat:** Do **not** set `workspace_axis = "vertical"` with this option unless disabling scrolling-strip pan, or both `fusuma` and Umbriel may react to 3-finger vertical movement on scrolling workspaces. In `dwindle` mode (`workspace_axis = "horizontal"`), vertical 3-finger swipes stay free.

### Option B (Cleanest UX, since you may already be compiling `umbriel` on `aarch64`): Upstream Source Patch
1. In your `umbriel` source checkout, inspect `src/input/gestures.cpp` (`Gestures::handleSwipeUpdate` / finger-count checks).
2. Swap the 3-finger vertical swipe / 4-finger overview trigger so **3-finger swipe up/down** drives Umbriel's spring-animated overview natively (while keeping 3-finger horizontal swipes for workspaces).
3. Rebuild & install `umbriel`, and skip installing `fusuma`.

---

## 4. Phase 4 — Deploy MacBook Configs Selectively

Once Phase 1 discovery confirms package names and binaries, back up any existing files first, then deploy from `~/dotfiles`:

### A. Host-specific MacBook files (from `machines/macbook/`):
```bash
cp machines/macbook/.config/umbriel/config.toml ~/.config/umbriel/config.toml
cp machines/macbook/.config/umbriel/autostart.sh ~/.config/umbriel/autostart.sh
chmod +x ~/.config/umbriel/autostart.sh

mkdir -p ~/.config/xdg-desktop-portal
cp machines/macbook/.config/xdg-desktop-portal/{portals.conf,umbriel-portals.conf,Umbriel-portals.conf} ~/.config/xdg-desktop-portal/

cp machines/macbook/.config/noctalia/config.toml ~/.config/noctalia/config.toml
mkdir -p ~/.local/state/noctalia
# Only overwrite settings.toml after backing up any existing one!
cp machines/macbook/.local/state/noctalia/settings.toml ~/.local/state/noctalia/settings.toml

# If using Option A for 3-finger overview:
mkdir -p ~/.config/fusuma
cp machines/macbook/.config/fusuma/config.yml ~/.config/fusuma/config.yml
```

Then edit `~/.config/umbriel/config.toml` based on Phase 1 findings:
- Update `[output.eDP-1]` if the MacBook's DRM connector has a different name.
- Update `Mod+Return` / `Mod+B` (`zen-browser`), `Mod+T` (`ghostty`), `Mod+E` (`dolphin`) if different apps are installed on Aurora.
- Adjust `GDK_SCALE` / `[output.eDP-1] scale = 2.0` if using a different MacBook model/fractional scale.

### B. Safe architecture-independent extras to cherry-pick from root packages:
- **Custom Noctalia Luau plugins (all 22):**
  Copy `noctalia/.local/share/noctalia/plugins/` &rarr; `~/.local/share/noctalia/plugins/`.
  *(Review plugins like `pacman` or `gpu` and disable/hide any Arch/NVIDIA-only widgets if on Fedora Aurora or Apple GPU.)*
- **Optional portable dotfiles (copy selectively, not via `dotfiles push`):**
  - `ghostty/.config/ghostty/*` (check `Maple Mono NF` font is installed)
  - `fish/.config/fish/` & `starship/.config/starship.toml` (check `terax.fish` / desktop-only aliases)
  - `btop/.config/btop/*`, `gtk/.config/gtk-{3,4}.0/*`, `zed/.config/zed/*` *(strip desktop `musiccraft-mcp` path from `zed/settings.json`)*
  - `noctalia/.config/noctalia/snippets.json` *(trim desktop `!specs` / `pacman` entries if desired)*
  - Portable bin scripts: `noctalia-mpris`, `recent-files`, `remind`, `umbriel-smart-scroll` *(only if using scrolling workspaces)*

### C. Desktop-only items to **SKIP**:
- `umbriel/`, `hypr/`, `wireplumber/`, `easyeffects/`, `yabridge/`, `systemd/`, `obs-overlays/`, `gsr/`, `desktop-entries/`
- Scripts: `toggle-audio-sink`, `audio-launcher-control`, `game-quiet-mode.py`, `noctalia-bar-recover`, `tv`, `movie`, `bloodborne`, `cursor-calculator` *(compiled `x86_64` binary; build from `cursor-calculator` Rust source on `aarch64` if desired)*

---

## 5. Phase 5 — Validate Before & After Logging In

### Before switching sessions (Mandatory):
```bash
umbriel config validate -c ~/.config/umbriel/config.toml
```
Fix any warnings or errors before logging out. Make sure `/usr/share/wayland-sessions/umbriel.desktop` exists and points to `start-umbriel` / `umbriel`.

### After logging into Umbriel from your display manager:
Run through this verification checklist with the user:
1. **Display & Retina scaling:** Run `umbriel outputs` &rarr; verify `[output.<connector>]`, native resolution/refresh, `scale = 2.0`, and crisp XWayland apps (`xwayland_native_resolution = true`).
2. **Touchpad & Gestures:** Verify natural scrolling, two-finger tap/clickfinger right-click, 3-finger horizontal workspace swipe, and **3-finger vertical swipe up/down for overview** (`Mod+Tab` as fallback).
3. **Noctalia Shell & Palette Sync:** Run `noctalia msg templates-apply` and check `~/.config/umbriel/noctalia.toml` exists and borders/colors update cleanly.
4. **Hardware Keys:** Verify `F1`/`F2` screen brightness, `Cmd+F1`/`Cmd+F2` keyboard backlight (`noctalia msg keyboard-backlight-up/down`), volume/media keys, `Cmd+L` lock, and `Cmd+Shift+3/4/5` Noctalia screenshots.
5. **Battery & Lid Wake:** Verify battery widget updates accurately in Noctalia bar, and closing/opening the lid recovers display and PipeWire audio cleanly (`[events] lid_open`).
6. **Portals & Screen Share:** Verify file dialogs and Wayland screen sharing picker (`xdg-desktop-portal-umbriel`).

Once verified, keep MacBook-specific refinements inside `machines/macbook/` only (never pushing them back into root desktop packages, and sanitizing before committing).
