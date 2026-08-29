#!/bin/bash
# Regenerates ~/.config/kdeglobals from the current Omarchy theme's colors.toml
# so Qt/KDE apps (Dolphin, etc. -- QT_QPA_PLATFORMTHEME=kde reads kdeglobals)
# stay in sync whenever the Omarchy theme changes. Runs automatically via
# omarchy-hook theme-set (see omarchy-theme-set) plus once manually on install.

set -e

COLORS_TOML="$HOME/.local/state/omarchy/current/theme/colors.toml"
KDEGLOBALS="$HOME/.config/kdeglobals"
SCHEME_DIR="$HOME/.local/share/color-schemes"
SCHEME_FILE="$SCHEME_DIR/Omarchy.colors"
THEME_NAME="${1:-omarchy}"

[[ -f $COLORS_TOML ]] || exit 0

hex_to_rgb() {
  local hex=${1#\#}
  printf "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

get() {
  sed -n "s/^$1 = \"\(#[0-9A-Fa-f]*\)\"/\1/p" "$COLORS_TOML" | head -1
}

bg=$(hex_to_rgb "$(get background)")
bg_dark=$(hex_to_rgb "$(get dark_background)")
bg_darker=$(hex_to_rgb "$(get darker_background)")
bg_light=$(hex_to_rgb "$(get lighter_background)")
fg=$(hex_to_rgb "$(get foreground)")
fg_light=$(hex_to_rgb "$(get light_foreground)")
fg_bright=$(hex_to_rgb "$(get bright_foreground)")
accent=$(hex_to_rgb "$(get accent)")
selection=$(hex_to_rgb "$(get selection)")
muted=$(hex_to_rgb "$(get muted)")

cat >"$KDEGLOBALS" <<EOF
[KDE]
contrast=4

[General]
ColorScheme=Omarchy
Name=$THEME_NAME

[ColorEffects:Disabled]
Color=$bg_darker
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=$muted
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=$bg_darker
BackgroundNormal=$bg_light
DecorationFocus=$accent
DecorationHover=$accent
ForegroundActive=$accent
ForegroundInactive=$muted
ForegroundLink=$fg_light
ForegroundNegative=255,180,171
ForegroundNeutral=$fg_bright
ForegroundNormal=$fg
ForegroundPositive=$fg_bright
ForegroundVisited=$fg_light

[Colors:Selection]
BackgroundAlternate=$bg_darker
BackgroundNormal=$selection
DecorationFocus=$accent
DecorationHover=$accent
ForegroundActive=$fg_bright
ForegroundInactive=$muted
ForegroundLink=$fg_light
ForegroundNegative=147,0,10
ForegroundNeutral=$fg_bright
ForegroundNormal=$fg_bright
ForegroundPositive=$fg_bright
ForegroundVisited=$fg_light

[Colors:Tooltip]
BackgroundAlternate=$bg_darker
BackgroundNormal=$bg_dark
DecorationFocus=$accent
DecorationHover=$accent
ForegroundActive=$accent
ForegroundInactive=$muted
ForegroundLink=$fg_light
ForegroundNegative=255,180,171
ForegroundNeutral=$fg_bright
ForegroundNormal=$fg
ForegroundPositive=$fg_bright
ForegroundVisited=$fg_light

[Colors:View]
BackgroundAlternate=$bg_dark
BackgroundNormal=$bg
DecorationFocus=$accent
DecorationHover=$accent
ForegroundActive=$accent
ForegroundInactive=$muted
ForegroundLink=$fg_light
ForegroundNegative=255,180,171
ForegroundNeutral=$fg_bright
ForegroundNormal=$fg
ForegroundPositive=$fg_bright
ForegroundVisited=$fg_light

[Colors:Window]
BackgroundAlternate=$bg_dark
BackgroundNormal=$bg
DecorationFocus=$accent
DecorationHover=$accent
ForegroundActive=$accent
ForegroundInactive=$muted
ForegroundLink=$fg_light
ForegroundNegative=255,180,171
ForegroundNeutral=$fg_bright
ForegroundNormal=$fg
ForegroundPositive=$fg_bright
ForegroundVisited=$fg_light

[WM]
activeBackground=$bg_dark
activeBlend=$fg_bright
activeForeground=$fg_bright
inactiveBackground=$bg_darker
inactiveBlend=$muted
inactiveForeground=$muted
EOF

# KDEPlasmaPlatformTheme6 resolves `ColorScheme=Omarchy` by looking up a
# scheme *file*, not the inline [Colors:*] sections above -- kdeglobals alone
# is not enough, it just silently falls back to a built-in default otherwise.
mkdir -p "$SCHEME_DIR"
cp "$KDEGLOBALS" "$SCHEME_FILE"
