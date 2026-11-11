--!nonstrict

local defaultActions = {
  { id = "on", title = "TV Power On", subtitle = "Wake Onn streamer & LG Display (HDMI-CEC)", glyph = "power" },
  { id = "off", title = "TV Power Off", subtitle = "Put TV to sleep", glyph = "power" },
  { id = "toggle", title = "Play / Pause", subtitle = "Toggle media playback on TV", glyph = "player-play" },
  { id = "vol_up", title = "Volume Up", subtitle = "Increase TV volume (+2)", glyph = "volume" },
  { id = "vol_down", title = "Volume Down", subtitle = "Decrease TV volume (-2)", glyph = "volume-2" },
  { id = "mute", title = "Toggle Mute", subtitle = "Mute/Unmute TV sound", glyph = "volume-3" },
  { id = "app:stremio", title = "Open Stremio", subtitle = "Launch Stremio on TV", glyph = "movie" },
  { id = "app:yt", title = "Open SmartTube", subtitle = "Launch SmartTube (YouTube ad-free) on TV", glyph = "brand-youtube" },
  { id = "app:netflix", title = "Open Netflix", subtitle = "Launch Netflix on TV", glyph = "player-play" },
  { id = "app:max", title = "Open Max (HBO)", subtitle = "Launch Max on TV", glyph = "player-play" },
}

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}

  -- If user types a title like "tv matrix" or "tv dune", offer Stremio search first!
  if filter ~= "" and not ("on"):find(filter, 1, true) and not ("off"):find(filter, 1, true) and not ("volume"):find(filter, 1, true) and not ("vol"):find(filter, 1, true) then
    table.insert(rows, {
      id = "search:" .. filter,
      title = "Play on Stremio: " .. filter,
      subtitle = "Search & stream movie or show on living room TV",
      glyph = "movie",
    })
  end

  for _, act in ipairs(defaultActions) do
    if filter == "" or act.title:lower():find(filter, 1, true) or act.subtitle:lower():find(filter, 1, true) then
      table.insert(rows, act)
    end
  end

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)
  launcher.setResults(query, renderRows(text))
end

function onActivate(id)
  if id == "on" then
    noctalia.runAsync("/home/bry/.local/bin/tv on")
  elseif id == "off" then
    noctalia.runAsync("/home/bry/.local/bin/tv off")
  elseif id == "toggle" then
    noctalia.runAsync("/home/bry/.local/bin/tv toggle")
  elseif id == "vol_up" then
    noctalia.runAsync("/home/bry/.local/bin/tv volume up 2")
  elseif id == "vol_down" then
    noctalia.runAsync("/home/bry/.local/bin/tv volume down 2")
  elseif id == "mute" then
    noctalia.runAsync("/home/bry/.local/bin/tv mute")
  elseif id:sub(1, 4) == "app:" then
    local app = id:sub(5)
    noctalia.runAsync("/home/bry/.local/bin/tv launch " .. app)
  elseif id:sub(1, 7) == "search:" then
    local title = id:sub(8)
    local escaped = title:gsub("'", "'\\''")
    noctalia.runAsync("/home/bry/.local/bin/tv play '" .. escaped .. "'")
  end
end
