-- Only workspace 1 is persistent (the landing spot). Every other workspace
-- appears on the bar once it has a window. A single trailing empty workspace
-- is kept alive by scripts/dynamic-workspaces.sh so Noctalia always shows
-- "(highest used workspace) + 1" as a mouse target for a fresh workspace --
-- without pinning all 9.
hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true })
