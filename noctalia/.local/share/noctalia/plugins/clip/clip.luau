--!nonstrict

local cachedClips = {}

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}

  -- Quick Action 1: Save Replay Now
  if filter == "" or ("save"):find(filter, 1, true) or ("clip"):find(filter, 1, true) or ("record"):find(filter, 1, true) then
    table.insert(rows, {
      id = "action:save",
      title = "Save Last 60s Replay Now",
      subtitle = "Instant NVENC RAM dump to ~/Videos • Press Enter to Save",
      glyph = "video",
    })
  end

  -- Quick Action 2: Open Clips Folder
  if filter == "" or ("folder"):find(filter, 1, true) or ("videos"):find(filter, 1, true) or ("open"):find(filter, 1, true) then
    table.insert(rows, {
      id = "action:folder",
      title = "Open Clips Directory",
      subtitle = "Browse ~/Videos in file manager",
      glyph = "folder",
    })
  end

  -- Recent Clips List
  for _, clip in ipairs(cachedClips) do
    if filter == "" or clip.filename:lower():find(filter, 1, true) then
      local dur = clip.duration and (" • " .. clip.duration) or ""
      table.insert(rows, {
        id = "play:" .. clip.path,
        title = clip.filename,
        subtitle = clip.size .. dur .. " • " .. clip.time_ago .. " • Press Enter to Play in MPV",
        glyph = "player-play",
      })
    end
  end

  if #rows == 0 then
    table.insert(rows, {
      id = "",
      title = "No Matching Clips",
      subtitle = "Save a replay clip first using Alt+C",
      glyph = "video-off",
    })
  end

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)

  -- Render immediately with cache
  launcher.setResults(query, renderRows(text))

  -- Fetch fresh clips in background
  noctalia.runAsync("/home/bry/.local/bin/clip-tools list", function(res)
    if res.exit_code == 0 and res.stdout ~= "" then
      local ok, data = pcall(noctalia.json.parse, res.stdout)
      if ok and type(data) == "table" then
        cachedClips = data
        launcher.setResults(query, renderRows(text))
      end
    end
  end)
end

function onActivate(id)
  if id == "action:save" then
    noctalia.runAsync("gsr-ui-cli replay-save")
  elseif id == "action:folder" then
    noctalia.runAsync("xdg-open /home/bry/Videos")
  elseif id:sub(1, 5) == "play:" then
    local path = id:sub(6)
    local escaped = path:gsub("'", "'\\''")
    noctalia.runAsync("mpv --geometry=70%x70%+50%+50% --autofit=70% '" .. escaped .. "'")
  end
end
