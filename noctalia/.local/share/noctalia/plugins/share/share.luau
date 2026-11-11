--!nonstrict

local latestClip = nil

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}

  local targetName = latestClip and latestClip.filename or "Latest Video"
  local targetSize = latestClip and (" (" .. latestClip.size .. ")") or ""

  table.insert(rows, {
    id = "compress",
    title = "Compress for Discord: " .. targetName,
    subtitle = "Crush to <23.5MB via NVENC & copy to clipboard" .. targetSize,
    glyph = "brand-discord",
  })

  table.insert(rows, {
    id = "open",
    title = "Play in MPV: " .. targetName,
    subtitle = "Preview before sharing",
    glyph = "player-play",
  })

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)
  launcher.setResults(query, renderRows(text))

  noctalia.runAsync("/home/bry/.local/bin/clip-tools latest", function(res)
    if res.exit_code == 0 and res.stdout ~= "" then
      local ok, data = pcall(noctalia.json.parse, res.stdout)
      if ok and type(data) == "table" and data.filename then
        latestClip = data
        launcher.setResults(query, renderRows(text))
      end
    end
  end)
end

function onActivate(id)
  if id == "compress" then
    noctalia.runAsync("/home/bry/.local/bin/clip-tools compress-latest")
  elseif id == "open" and latestClip and latestClip.path then
    local escaped = latestClip.path:gsub("'", "'\\''")
    noctalia.runAsync("mpv --geometry=70%x70%+50%+50% --autofit=70% '" .. escaped .. "'")
  end
end
