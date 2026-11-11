--!nonstrict

local function loadSnippets()
  local path = noctalia.expandPath("~/.config/noctalia/snippets.json")
  local raw = noctalia.readFile(path)
  if raw ~= nil then
    local decoded = noctalia.json.decode(raw)
    if type(decoded) == "table" then
      return decoded
    end
  end
  return {}
end

local activeSnippets = {}

function onQuery(query)
  local text = noctalia.string.trim(query):lower()
  local all = loadSnippets()
  activeSnippets = {}
  local rows = {}

  for i, item in ipairs(all) do
    local title = item.title or "Snippet"
    local desc = item.description or ""
    local content = item.content or ""
    
    if text == "" or title:lower():find(text, 1, true) or desc:lower():find(text, 1, true) then
      activeSnippets[tostring(i)] = { title = title, content = content }
      table.insert(rows, {
        id = tostring(i),
        title = title,
        subtitle = desc ~= "" and desc or content,
        glyph = "clipboard-text",
      })
    end
  end

  if #rows == 0 then
    table.insert(rows, {
      id = "none",
      title = "No snippets matched",
      subtitle = "Edit ~/.config/noctalia/snippets.json to add snippets",
      glyph = "help",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  local item = activeSnippets[id]
  if item ~= nil then
    local content = item.content or ""
    local title = item.title or "Snippet"
    local escaped = content:gsub("'", "'\\''")
    local escapedTitle = title:gsub("'", "'\\''")
    noctalia.runAsync("printf '%s' '" .. escaped .. "' | wl-copy && notify-send -i clipboard 'Copied!' '" .. escapedTitle .. "'")
  end
end
