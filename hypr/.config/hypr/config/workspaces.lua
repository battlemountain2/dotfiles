-- Workspace 1 is the default landing spot
hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true })

-- Workspaces 2-9 bound to MONITOR1 without persistence (empty workspaces are pruned)
for i = 2, 9 do
    hl.workspace_rule({ workspace = tostring(i), monitor = MONITOR1 })
end
