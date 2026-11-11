#!/usr/bin/env bash
set -euo pipefail

URL="${1:-}"
if [[ -z "$URL" ]]; then
    exit 0
fi

# 1. Open the URL in the browser
if command -v zen-browser >/dev/null 2>&1; then
    zen-browser "$URL" >/dev/null 2>&1 &
else
    xdg-open "$URL" >/dev/null 2>&1 &
fi

# 2. Focus the browser window and switch to its workspace in Hyprland
focus_browser() {
    hyprctl repl 'for _, w in ipairs(hl.get_windows()) do
        if w.class == "zen" or (w.class and w.class:lower():match("zen")) then
            if w.workspace and w.workspace.monitor then
                hl.dispatch(hl.dsp.focus({ monitor = w.workspace.monitor.name }))
            end
            if w.workspace then
                hl.dispatch(hl.dsp.focus({ workspace = tostring(w.workspace.id) }))
            end
            hl.dispatch(hl.dsp.focus({ window = w }))
            if w.at and w.size then
                local cx = math.floor(w.at.x + w.size.x / 2)
                local cy = math.floor(w.at.y + w.size.y / 2)
                hl.dispatch(hl.dsp.cursor.move({ x = cx, y = cy }))
            end
            break
        end
    end' >/dev/null 2>&1 || true
}

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    focus_browser
    # Also trigger after a brief delay so Noctalia closing the launcher doesn't steal focus back
    (sleep 0.15 && focus_browser) &
fi
