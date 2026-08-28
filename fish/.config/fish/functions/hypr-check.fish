# Helper: coloured status line. Lives here rather than in config.fish so the
# whole check is self-contained in one autoloaded file.
function __hypr_check_line -a state message
    switch $state
        case ok
            set_color green;  echo -n '  ok   '
        case warn
            set_color yellow; echo -n '  warn '
        case bad
            set_color red;    echo -n '  FAIL '
    end
    set_color normal
    echo $message
end

function hypr-check --description 'Post-update sanity check: Hyprland, borders, plugins, shell, tray, audio'
    set -l problems 0

    echo
    set_color --bold; echo "Hyprland"; set_color normal

    # --- config parses without errors ---
    set -l errs (hyprctl configerrors 2>&1 | string trim)
    if test -z "$errs"
        __hypr_check_line ok "config loads with no errors"
    else
        __hypr_check_line bad "configerrors: $errs"
        set problems (math $problems + 1)
    end

    # --- border gradient: 2 stops + 45deg means borders.lua won over apply_theme ---
    set -l border (hyprctl getoption general:col.active_border 2>/dev/null | string match -r 'gradient data:.*')
    set -l stops (string match -ra '[0-9a-f]{8}' -- "$border" | count)
    set -l angle (string match -r '(\d+)deg' -- "$border")[2]
    if test "$stops" -ge 2 -a "$angle" != "0"
        __hypr_check_line ok "border gradient intact ($stops stops, $angle""deg)"
    else
        __hypr_check_line bad "border gradient collapsed ($stops stop(s), $angle""deg) -- Noctalia likely overwrote config/borders.lua"
        set problems (math $problems + 1)
    end

    # --- the require ordering that makes the above work ---
    set -l last (tail -1 ~/.config/hypr/hyprland.lua | string trim)
    if test "$last" = 'require("config.borders")'
        __hypr_check_line ok "hyprland.lua still ends with require(\"config.borders\")"
    else
        __hypr_check_line bad "hyprland.lua tail changed -- last line is: $last"
        set problems (math $problems + 1)
    end

    # --- plugins are rebuilt against the current Hyprland ---
    if hyprctl plugin list 2>/dev/null | string match -q -i '*hyprtasking*'
        __hypr_check_line ok "hyprtasking loaded"
    else
        __hypr_check_line warn "hyprtasking NOT loaded -- SUPER+Q is on the killactive fallback. Try: hyprpm update; and hyprpm reload"
    end

    # --- monitor came up at the configured mode ---
    if hyprctl monitors 2>/dev/null | string match -q '*2560x1440@240*'
        __hypr_check_line ok "DP-1 at 2560x1440@240"
    else
        __hypr_check_line bad "monitor not at 2560x1440@240 -- check optional/monitors-"(hostname)".lua"
        set problems (math $problems + 1)
    end

    echo
    set_color --bold; echo "Shell & portals"; set_color normal

    if pgrep -x noctalia >/dev/null
        __hypr_check_line ok "noctalia running"
    else
        __hypr_check_line bad "noctalia NOT running -- volume, media, launcher, lock binds are all dead"
        set problems (math $problems + 1)
    end

    if type -q hyprland-preview-share-picker
        __hypr_check_line ok "preview share picker present"
    else
        __hypr_check_line warn "hyprland-preview-share-picker missing -- xdph.conf points at it; screensharing may fail"
    end

    # --- the one that breaks on every KDE update ---
    if test -f /usr/lib/qt6/plugins/kf6/kded/statusnotifierwatcher.so
        __hypr_check_line warn "kded6 tray watcher is back after an update -- run: fix-tray"
    else
        __hypr_check_line ok "kded6 tray watcher still disabled"
    end

    echo
    set_color --bold; echo "Audio"; set_color normal

    if pgrep -x easyeffects >/dev/null
        __hypr_check_line ok "easyeffects running"
    else
        __hypr_check_line warn "easyeffects not running -- EQ and mic chain are bypassed"
    end

    if wpctl status 2>/dev/null | string match -q '*FiiO K11 R2R*'
        __hypr_check_line ok "FiiO K11 R2R present"
    else
        __hypr_check_line warn "K11 not found -- wireplumber rules in 51-k11-format.conf won't apply"
    end

    echo
    if test $problems -eq 0
        set_color green; echo "  All critical checks passed."; set_color normal
    else
        set_color red; echo "  $problems critical problem(s) above."; set_color normal
    end
    echo
end
