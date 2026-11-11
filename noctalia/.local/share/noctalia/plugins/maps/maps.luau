--!nonstrict

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text ~= "" then
    table.insert(rows, {
      id = text,
      title = "Search Maps: " .. text,
      subtitle = "Press Enter to view on Google Maps",
      glyph = "map-pin",
    })
  else
    table.insert(rows, {
      id = "home",
      title = "Open Google Maps",
      subtitle = "Type a location, restaurant, address, or directions",
      glyph = "map-pin",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  if id == "home" then
    noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://www.google.com/maps'")
  elseif id ~= "" then
    local escaped = id:gsub("'", "'\\''")
    noctalia.runAsync("python3 -c \"import sys, urllib.parse, subprocess; subprocess.run(['/home/bry/.config/hypr/scripts/open_and_focus.sh', 'https://www.google.com/maps/search/?api=1&query=' + urllib.parse.quote(sys.argv[1])])\" '" .. escaped .. "'")
  end
end

