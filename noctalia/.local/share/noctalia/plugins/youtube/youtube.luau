--!nonstrict

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text ~= "" then
    table.insert(rows, {
      id = text,
      title = "Search YouTube: " .. text,
      subtitle = "Press Enter to open in browser",
      glyph = "brand-youtube",
    })
  else
    table.insert(rows, {
      id = "home",
      title = "Open YouTube",
      subtitle = "Type a video title or search term",
      glyph = "brand-youtube",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  if id == "home" then
    noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://www.youtube.com'")
  elseif id ~= "" then
    local escaped = id:gsub("'", "'\\''")
    noctalia.runAsync("python3 -c \"import sys, urllib.parse, subprocess; subprocess.run(['/home/bry/.config/hypr/scripts/open_and_focus.sh', 'https://www.youtube.com/results?search_query=' + urllib.parse.quote(sys.argv[1])])\" '" .. escaped .. "'")
  end
end

