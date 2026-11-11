--!nonstrict

local cachedPlayers = {}

local defaultActions = {
  { id = "next", title = "Next Track", subtitle = "Skip to next song or video", glyph = "player-track-next" },
  { id = "previous", title = "Previous Track", subtitle = "Go back to previous song or video", glyph = "player-track-prev" },
}

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}

  -- 1. Insert live players and actions (Play/Pause, Copy Song Info, Lyrics, Copy URL)
  for _, p in ipairs(cachedPlayers) do
    local isPlaying = p.status == "Playing"
    local statusText = isPlaying and "Playing • Press Enter to Pause" or "Paused • Press Enter to Play"
    local title = (p.title and p.title ~= "") and p.title or (p.name .. " (" .. p.status .. ")")
    local subtitle = (p.artist and p.artist ~= "" and (p.artist .. " • ") or "") .. p.name .. " • " .. statusText
    local songInfo = (p.formatted and p.formatted ~= "") and p.formatted or title

    local match = filter == ""
      or title:lower():find(filter, 1, true)
      or (p.artist and p.artist:lower():find(filter, 1, true))
      or p.name:lower():find(filter, 1, true)

    if match then
      local glyph = "player-play"
      if isPlaying then
        glyph = "player-pause"
      elseif p.name:find("Zen") or p.name:find("YouTube") then
        glyph = "brand-youtube"
      elseif p.name:find("Cider") or p.name:find("Music") or p.name:find("Spotify") then
        glyph = "music"
      end

      -- Action 1: Play/Pause Toggle
      table.insert(rows, {
        id = "toggle:" .. p.id,
        title = title,
        subtitle = subtitle,
        glyph = glyph,
      })

      -- Action 2: Copy Song Title & Artist Name
      if p.formatted and p.formatted ~= "" and (filter == "" or ("copy"):find(filter, 1, true) or ("song"):find(filter, 1, true) or ("artist"):find(filter, 1, true)) then
        table.insert(rows, {
          id = "copy-info:" .. p.id,
          title = "Copy: " .. p.formatted,
          subtitle = "Press Enter to copy \"Artist - Song Title\" to clipboard",
          glyph = "clipboard-text",
        })
        table.insert(rows, {
          id = "share-discord:" .. p.id,
          title = "Share to Discord: 🎧 " .. p.formatted,
          subtitle = "Copy formatted status message ready for Discord or chat",
          glyph = "brand-discord",
        })
      end

      -- Action 3: Look up Lyrics in Zen Browser
      if filter == "" or ("lyrics"):find(filter, 1, true) or ("search"):find(filter, 1, true) then
        table.insert(rows, {
          id = "lyrics:" .. p.id,
          title = "Look Up Lyrics: " .. songInfo,
          subtitle = "Open Genius / Google in Zen Browser",
          glyph = "book",
        })
      end

      -- Action 4: Copy Video/Track URL (only if a direct link exists, e.g. YouTube)
      if p.url and p.url ~= "" and (filter == "" or ("link"):find(filter, 1, true) or ("url"):find(filter, 1, true) or ("copy"):find(filter, 1, true)) then
        table.insert(rows, {
          id = "copy-url:" .. p.id,
          title = "Copy Link: " .. p.url,
          subtitle = "Press Enter to copy video URL to clipboard",
          glyph = "link",
        })
      end
    end
  end

  -- If no live players found, provide a fallback Play/Pause
  if #cachedPlayers == 0 then
    table.insert(rows, {
      id = "toggle",
      title = "Play / Pause",
      subtitle = "Toggle playback on active player",
      glyph = "player-play",
    })
  end

  -- 2. Standard next / previous track controls
  for _, act in ipairs(defaultActions) do
    if filter == "" or act.title:lower():find(filter, 1, true) or act.id:find(filter, 1, true) then
      table.insert(rows, {
        id = act.id,
        title = act.title,
        subtitle = act.subtitle,
        glyph = act.glyph,
      })
    end
  end

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)

  -- Render immediately with cached state so there is zero UI delay
  launcher.setResults(query, renderRows(text))

  -- Refresh live status in background
  noctalia.runAsync("/home/bry/.local/bin/noctalia-mpris status", function(res)
    if res.exitCode == 0 and type(res.stdout) == "string" and res.stdout ~= "" then
      local parsed = noctalia.json.decode(res.stdout)
      if type(parsed) == "table" then
        cachedPlayers = parsed
        launcher.setResults(query, renderRows(text))
      end
    end
  end)
end

function onActivate(id)
  if id == "" then return end

  local action, pid = id:match("^([^:]+):(.+)$")
  if action ~= nil and pid ~= nil then
    noctalia.runAsync("/home/bry/.local/bin/noctalia-mpris " .. action .. " '" .. pid .. "'")
  else
    noctalia.runAsync("/home/bry/.local/bin/noctalia-mpris " .. id)
  end
end
