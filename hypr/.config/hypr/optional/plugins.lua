-- /home/bry/.config/optional/plugins.lua
--
-- hyprtasking only. Everything else stripped.
--
-- Compatibility note: hyprpm.toml pins go up to v0.56.1; you're on 0.56.2,
-- so there's no pin for you and hyprpm will build main HEAD against your
-- headers. That may or may not carry the workspace-state API fix. The
-- guard below means a failed load just skips this block rather than
-- throwing "Invalid dispatcher" on every startup.

local mainMod = "SUPER"

local has_hyprtasking = hl.plugin and hl.plugin.hyprtasking

if has_hyprtasking then
   -- print("[Hyprland] hyprtasking detected: loading settings and binds")

    hl.config({
        plugin = {
            hyprtasking = {
                layout = "grid",

                gap_size = 10,
                bg_color = 0xff1a1a1a,
                border_size = 2,
                exit_on_hovered = false,
                warp_on_move_window = 1,
                close_overview_on_reload = false,

                drag_button = 0x110,   -- left mouse: drag windows between workspaces
                select_button = 0x111, -- right mouse: jump to workspace

                gestures = {
                    -- Touchpad only. Off on a desktop.
                    enabled = false,
                },

                grid = {
                    rows = 3,
                    cols = 3,
                    loop = false,
                    layers = 1,          -- 3x3x1 = 9, matching your workspace count
                    loop_layers = true,
                    gaps_use_aspect_ratio = true,
                },
            }
        }
    })

    -- SUPER+Tab: this monitor. SUPER+SHIFT+Tab: everything.
    -- Deliberately avoiding the README's SUPER+Space and SUPER+X examples —
    -- those are your Noctalia launcher and control-center.
    hl.bind(mainMod .. " + Tab", function()
    hl.plugin.hyprtasking.toggle("cursor")
    end)

    hl.bind(mainMod .. " + SHIFT + Tab", function()
    hl.plugin.hyprtasking.toggle("all")
    end)

    -- Escape closes the overview only when it's open. non_consuming means
    -- Escape still reaches applications the rest of the time.
    hl.bind("escape", function()
    if hl.plugin.hyprtasking.is_active() then
        hl.plugin.hyprtasking.toggle("all")
        end
        end, { non_consuming = true })
    else
        print("[Hyprland] hyprtasking not detected: skipping plugin config")
        end
