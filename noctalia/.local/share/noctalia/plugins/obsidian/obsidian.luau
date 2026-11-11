--!nonstrict

local cachedNotes = {}

local function renderRows(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  -- Quick Capture options when text is provided
  if text ~= "" then
    -- 1. Add To-Do
    local cleanTask = text:gsub("^todo%s+", "")
    table.insert(rows, {
      id = "todo:" .. cleanTask,
      title = "Add To-Do: - [ ] " .. cleanTask,
      subtitle = "Append task to Obsidian Inbox (inbox/todo.md)",
      glyph = "checkbox",
    })

    -- 2. Log to Daily Note
    table.insert(rows, {
      id = "log:" .. text,
      title = "Log to Today's Daily Note",
      subtitle = "Add timestamped entry to daily log",
      glyph = "calendar",
    })
  else
    table.insert(rows, {
      id = "open:daily/" .. os.date("%Y-%m-%d"),
      title = "Open Today's Daily Note (" .. os.date("%Y-%m-%d") .. ")",
      subtitle = "Jump straight to today's Obsidian daily note",
      glyph = "calendar",
    })
    table.insert(rows, {
      id = "open:inbox/todo",
      title = "Open Inbox Tasks (inbox/todo.md)",
      subtitle = "View all pending tasks and to-dos",
      glyph = "checkbox",
    })
  end

  -- Search results from vault
  for _, note in ipairs(cachedNotes) do
    local glyph = "notes"
    if note.folder == "daily" then
      glyph = "calendar"
    elseif note.folder:find("school") then
      glyph = "school"
    elseif note.folder:find("project") then
      glyph = "code"
    end

    table.insert(rows, {
      id = "open:" .. note.vault_file,
      title = note.title,
      subtitle = note.folder .. " • Press Enter to open in Obsidian",
      glyph = glyph,
    })
  end

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)

  -- Render immediately
  launcher.setResults(query, renderRows(text))

  -- Query vault in background
  local escaped = text:gsub("'", "'\\''")
  noctalia.runAsync("/home/bry/.local/bin/obsidian-control search '" .. escaped .. "'", function(res)
    if res.exitCode == 0 and type(res.stdout) == "string" and res.stdout ~= "" then
      local parsed = noctalia.json.decode(res.stdout)
      if type(parsed) == "table" then
        cachedNotes = parsed
        launcher.setResults(query, renderRows(text))
      end
    end
  end)
end

function onActivate(id)
  if id == "" then return end

  local action, arg = id:match("^([^:]+):(.+)$")
  if action == "todo" then
    local escaped = arg:gsub("'", "'\\''")
    noctalia.runAsync("/home/bry/.local/bin/obsidian-control todo '" .. escaped .. "'")
  elseif action == "log" then
    local escaped = arg:gsub("'", "'\\''")
    noctalia.runAsync("/home/bry/.local/bin/obsidian-control log '" .. escaped .. "'")
  elseif action == "open" then
    local escaped = arg:gsub("'", "'\\''")
    noctalia.runAsync("/home/bry/.local/bin/obsidian-control open '" .. escaped .. "'")
  else
    local escaped = id:gsub("'", "'\\''")
    noctalia.runAsync("/home/bry/.local/bin/obsidian-control open '" .. escaped .. "'")
  end
end
