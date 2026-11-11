--!nonstrict

local cachedClips = {}

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}

  for _, item in ipairs(cachedClips) do
    if filter == "" or item.filename:lower():find(filter, 1, true) then
      local dur = item.duration and (" • " .. item.duration) or ""
      -- Action 1: Play in MPV
      table.insert(rows, {
        id = "play:" .. item.path,
        title = item.filename,
        subtitle = item.size .. dur .. " • " .. item.time_ago .. " • Press Enter to Play in MPV",
        glyph = "player-play",
      })

      -- Action 2: Copy Path
      if filter == "" or ("copy"):find(filter, 1, true) or ("path"):find(filter, 1, true) then
        table.insert(rows, {
          id = "copy:" .. item.path,
          title = "Copy Path: " .. item.filename,
          subtitle = item.path,
          glyph = "clipboard",
        })
      end
    end
  end

  if #rows == 0 then
    table.insert(rows, {
      id = "",
      title = "No Gameplay Clips Found",
      subtitle = "Clips saved with Alt+C will appear here",
      glyph = "video-off",
    })
  end

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)
  launcher.setResults(query, renderRows(text))

  noctalia.runAsync("/home/bry/.local/bin/recent-files clips", function(res)
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
  if id:sub(1, 5) == "play:" then
    local path = id:sub(6)
    local escaped = path:gsub("'", "'\\''")
    noctalia.runAsync("mpv --geometry=70%x70%+50%+50% --autofit=70% '" .. escaped .. "'")
  elseif id:sub(1, 5) == "copy:" then
    local path = id:sub(6)
    noctalia.runAsync("/home/bry/.local/bin/recent-files copy-path '" .. path:gsub("'", "'\\''") .. "'")
  end
end
