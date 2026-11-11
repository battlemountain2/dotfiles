--!nonstrict

local lastStats = nil

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}

  if lastStats then
    table.insert(rows, {
      id = "stats",
      title = lastStats.name or "NVIDIA GeForce RTX 4070 Super",
      subtitle = lastStats.summary or "Live Stats",
      glyph = "cpu",
    })
    table.insert(rows, {
      id = "vram",
      title = "VRAM: " .. (lastStats.vram_used or "?") .. " / " .. (lastStats.vram_total or "?") .. " (" .. (lastStats.vram_pct or "?") .. ")",
      subtitle = "Video memory allocated across games & compositors",
      glyph = "device-desktop",
    })
    table.insert(rows, {
      id = "thermal",
      title = "Thermal: " .. (lastStats.temp or "?") .. " • Fan: " .. (lastStats.fan or "?") .. " • Power: " .. (lastStats.power or "?"),
      subtitle = "GPU Core Temperature & Power Consumption",
      glyph = "temperature",
    })
  else
    table.insert(rows, {
      id = "loading",
      title = "Querying RTX 4070 Super...",
      subtitle = "Fetching live telemetry from nvidia-smi",
      glyph = "cpu",
    })
  end

  table.insert(rows, {
    id = "btop",
    title = "Open BTOP System Monitor",
    subtitle = "Launch interactive terminal hardware monitor",
    glyph = "terminal",
  })

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)
  launcher.setResults(query, renderRows(text))

  noctalia.runAsync("/home/bry/.local/bin/clip-tools gpu-stats", function(res)
    if res.exit_code == 0 and res.stdout ~= "" then
      local ok, data = pcall(noctalia.json.parse, res.stdout)
      if ok and type(data) == "table" and data.temp then
        lastStats = data
        launcher.setResults(query, renderRows(text))
      end
    end
  end)
end

function onActivate(id)
  if id == "btop" then
    noctalia.runAsync("kitty -e btop")
  elseif lastStats and lastStats.summary then
    noctalia.runAsync("notify-send -a 'NVIDIA GPU' -i video-display '" .. lastStats.name .. "' '" .. lastStats.summary .. "'")
  end
end
