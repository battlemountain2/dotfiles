--!nonstrict

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text ~= "" then
    if not text:find("%s") then
      table.insert(rows, {
        id = "channel:" .. text,
        title = "Open Twitch Channel: " .. text,
        subtitle = "Jump straight to twitch.tv/" .. text,
        glyph = "brand-twitch",
      })
    end
    table.insert(rows, {
      id = "search:" .. text,
      title = "Search Twitch: " .. text,
      subtitle = "Search streams, categories & clips",
      glyph = "brand-twitch",
    })
  else
    table.insert(rows, {
      id = "home",
      title = "Open Twitch",
      subtitle = "Type a streamer or game name",
      glyph = "brand-twitch",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  local channel = id:match("^channel:(.+)$")
  local search = id:match("^search:(.+)$")

  if channel ~= nil then
    local escaped = channel:gsub("'", "'\\''")
    noctalia.runAsync("python3 -c \"import sys, urllib.parse, subprocess; subprocess.run(['/home/bry/.config/hypr/scripts/open_and_focus.sh', 'https://www.twitch.tv/' + urllib.parse.quote(sys.argv[1])])\" '" .. escaped .. "'")
  elseif search ~= nil then
    local escaped = search:gsub("'", "'\\''")
    noctalia.runAsync("python3 -c \"import sys, urllib.parse, subprocess; subprocess.run(['/home/bry/.config/hypr/scripts/open_and_focus.sh', 'https://www.twitch.tv/search?term=' + urllib.parse.quote(sys.argv[1])])\" '" .. escaped .. "'")
  elseif id == "home" then
    noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://www.twitch.tv'")
  end
end
