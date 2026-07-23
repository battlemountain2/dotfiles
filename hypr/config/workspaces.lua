-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Workspace 1 is your default primary workspace
hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true })

-- Workspaces 2 & 3 stay persistent without stealing default focus
hl.workspace_rule({ workspace = "2", monitor = MONITOR1, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = MONITOR1, persistent = true })

-- Extra named or numbered workspaces
hl.workspace_rule({ workspace = "name:gaming", monitor = PRIMARY_MONITOR })

-- hl.workspace_rule({ workspace = "4", monitor = MONITOR2, persistent = true })
-- hl.workspace_rule({ workspace = "5", monitor = MONITOR2, persistent = true })
-- hl.workspace_rule({ workspace = "6", monitor = MONITOR2, persistent = true })
