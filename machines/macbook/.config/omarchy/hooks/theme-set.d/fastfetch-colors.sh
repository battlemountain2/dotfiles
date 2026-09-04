#!/bin/bash
# Regenerates ~/.config/fastfetch/config.jsonc from the current Omarchy theme's colors.toml
# Runs automatically via omarchy-hook theme-set whenever the theme changes.

python3 - <<'PYEOF'
import os, sys, json
try:
    import tomllib
except ImportError:
    import toml as tomllib

home = os.path.expanduser("~")
colors_toml = os.path.join(home, ".local/state/omarchy/current/theme/colors.toml")
config_file = os.path.join(home, ".config/fastfetch/config.jsonc")
branding_logo = os.path.join(home, ".config/omarchy/branding/logo-small.txt")

if not os.path.isfile(colors_toml):
    sys.exit(0)

with open(colors_toml, "rb") as f:
    c = tomllib.load(f)

def hex_to_ansi(hex_str):
    hex_str = hex_str.lstrip('#')
    r, g, b = tuple(int(hex_str[i:i+2], 16) for i in (0, 2, 4))
    return f"\u001b[38;2;{r};{g};{b}m"

muted_ansi = hex_to_ansi(c.get("muted", "#61666b"))
reset_ansi = "\u001b[0m"

accent = c.get("accent", "#6d829d")
green = c.get("green", "#9fcbdb")
blue = c.get("blue", "#6d829d")
magenta = c.get("magenta", "#9eabd1")

cfg = {
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "file" if os.path.exists(branding_logo) else "builtin",
    "source": branding_logo if os.path.exists(branding_logo) else "",
    "color": { "1": accent },
    "padding": { "top": 2, "right": 6, "left": 2 }
  },
  "display": {
    "disableLinewrap": True
  },
  "modules": [
    "break",
    "break",
    {
      "type": "custom",
      "format": f"{muted_ansi}┌──────────────────────Hardware──────────────────────┐{reset_ansi}"
    },
    { "type": "host", "key": " PC", "keyColor": green },
    { "type": "cpu", "key": "│ ├", "showPeCoreCount": True, "keyColor": green },
    { "type": "gpu", "key": "│ ├", "detectionMethod": "pci", "format": "{name}", "keyColor": green },
    { "type": "display", "key": "│ ├󱄄", "keyColor": green },
    { "type": "disk", "key": "│ ├󰋊", "keyColor": green },
    { "type": "memory", "key": "│ ├", "keyColor": green },
    { "type": "swap", "key": "└ └󰓡 ", "keyColor": green },
    {
      "type": "custom",
      "format": f"{muted_ansi}└────────────────────────────────────────────────────┘{reset_ansi}"
    },
    "break",
    {
      "type": "custom",
      "format": f"{muted_ansi}┌──────────────────────Software──────────────────────┐{reset_ansi}"
    },
    {
      "type": "command",
      "key": "\ue900 OS",
      "keyColor": blue,
      "text": "version=$(omarchy-version) && echo \"Omarchy Mx Mac $version\""
    },
    { "type": "kernel", "key": "│ ├", "keyColor": blue },
    { "type": "wm", "key": "│ ├", "keyColor": blue },
    { "type": "terminal", "key": "│ ├", "keyColor": blue },
    { "type": "packages", "key": "│ ├󰏖", "keyColor": blue },
    {
      "type": "command",
      "key": "│ ├󰸌",
      "keyColor": blue,
      "text": "theme=$(omarchy-theme-current); echo -e \"$theme \\e[38m●\\e[37m●\\e[36m●\\e[35m●\\e[34m●\\e[33m●\\e[32m●\\e[31m●\""
    },
    { "type": "terminalfont", "key": "└ └", "keyColor": blue },
    {
      "type": "custom",
      "format": f"{muted_ansi}└────────────────────────────────────────────────────┘{reset_ansi}"
    },
    "break",
    {
      "type": "custom",
      "format": f"{muted_ansi}┌────────────────Age / Uptime / Update───────────────┐{reset_ansi}"
    },
    {
      "type": "command",
      "key": "󱦟 OS Age",
      "keyColor": magenta,
      "text": "echo $(( ($(date +%s) - $(stat -c %W /)) / 86400 )) days"
    },
    { "type": "uptime", "key": "󱫐 Uptime", "keyColor": magenta },
    {
      "type": "command",
      "key": " Update",
      "keyColor": magenta,
      "text": "updated=$(omarchy-version-pkgs); echo \"$updated\""
    },
    {
      "type": "custom",
      "format": f"{muted_ansi}└────────────────────────────────────────────────────┘{reset_ansi}"
    },
    "break"
  ]
}

os.makedirs(os.path.dirname(config_file), exist_ok=True)
with open(config_file, "w") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
