for i = 1, 9 do
    hl.workspace_rule({ workspace = tostring(i), monitor = MONITOR1, persistent = true })
    end

    -- Workspace 1 is the default landing spot
    hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true })
