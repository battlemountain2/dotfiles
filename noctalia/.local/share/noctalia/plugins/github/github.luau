--!nonstrict

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text ~= "" then
    table.insert(rows, {
      id = text,
      title = "Search GitHub: " .. text,
      subtitle = "Press Enter to open in browser",
      glyph = "brand-github",
    })
  else
    table.insert(rows, {
      id = "home",
      title = "Open GitHub",
      subtitle = "Type a repository, user, or topic",
      glyph = "brand-github",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  if id == "home" then
    noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://github.com'")
  elseif id ~= "" then
    local escaped = id:gsub("'", "'\\''")
    noctalia.runAsync("python3 -c \"import sys, urllib.parse, subprocess; subprocess.run(['/home/bry/.config/hypr/scripts/open_and_focus.sh', 'https://github.com/search?q=' + urllib.parse.quote(sys.argv[1])])\" '" .. escaped .. "'")
  end
end

