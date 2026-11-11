--!nonstrict

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text ~= "" then
    table.insert(rows, {
      id = text,
      title = "Search Wikipedia: " .. text,
      subtitle = "Press Enter to open article in browser",
      glyph = "book",
    })
  else
    table.insert(rows, {
      id = "",
      title = "Search Wikipedia",
      subtitle = "Type a topic, person, or historical event",
      glyph = "book",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  if id ~= "" then
    local escaped = id:gsub("'", "'\\''")
    noctalia.runAsync("python3 -c \"import sys, urllib.parse, subprocess; subprocess.run(['/home/bry/.config/hypr/scripts/open_and_focus.sh', 'https://en.wikipedia.org/wiki/Special:Search?search=' + urllib.parse.quote(sys.argv[1])])\" '" .. escaped .. "'")
  end
end

