--!nonstrict

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text ~= "" then
    local clean = text:gsub("^r/", "")
    if not clean:find("%s") then
      table.insert(rows, {
        id = "sub:" .. clean,
        title = "Open Subreddit: r/" .. clean,
        subtitle = "Jump straight to reddit.com/r/" .. clean,
        glyph = "brand-reddit",
      })
      table.insert(rows, {
        id = "search:" .. text,
        title = "Search Reddit for: " .. text,
        subtitle = "Search all of Reddit",
        glyph = "search",
      })
    else
      table.insert(rows, {
        id = "search:" .. text,
        title = "Search Reddit: " .. text,
        subtitle = "Press Enter to search all of Reddit",
        glyph = "brand-reddit",
      })
    end
  else
    table.insert(rows, {
      id = "home",
      title = "Open Reddit",
      subtitle = "Type a subreddit (e.g. unixporn) or a search phrase",
      glyph = "brand-reddit",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  local sub = id:match("^sub:(.+)$")
  local search = id:match("^search:(.+)$")

  if sub ~= nil then
    local escaped = sub:gsub("'", "'\\''")
    noctalia.runAsync("python3 -c \"import sys, urllib.parse, subprocess; subprocess.run(['/home/bry/.config/hypr/scripts/open_and_focus.sh', 'https://www.reddit.com/r/' + urllib.parse.quote(sys.argv[1])])\" '" .. escaped .. "'")
  elseif search ~= nil then
    local escaped = search:gsub("'", "'\\''")
    noctalia.runAsync("python3 -c \"import sys, urllib.parse, subprocess; subprocess.run(['/home/bry/.config/hypr/scripts/open_and_focus.sh', 'https://www.reddit.com/search/?q=' + urllib.parse.quote(sys.argv[1])])\" '" .. escaped .. "'")
  elseif id == "home" then
    noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://www.reddit.com'")
  end
end

