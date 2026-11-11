--!nonstrict

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text ~= "" then
    table.insert(rows, {
      id = text,
      title = "Search Twitch: " .. text,
      subtitle = "Press Enter to search streams & channels",
      glyph = "brand-twitch",
    })
  else
    table.insert(rows, {
      id = "",
      title = "Search Twitch",
      subtitle = "Type a streamer, game, or channel",
      glyph = "brand-twitch",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  if id ~= "" then
    local escaped = id:gsub("'", "'\\''")
    noctalia.runAsync("python3 -c \"import sys, urllib.parse, subprocess; subprocess.run(['/home/bry/.config/hypr/scripts/open_and_focus.sh', 'https://www.twitch.tv/search?term=' + urllib.parse.quote(sys.argv[1])])\" '" .. escaped .. "'")
  end
end

