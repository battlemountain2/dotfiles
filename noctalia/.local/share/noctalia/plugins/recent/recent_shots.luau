--!nonstrict

local cachedShots = {}

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}

  for _, item in ipairs(cachedShots) do
    if filter == "" or item.filename:lower():find(filter, 1, true) then
      -- Action 1: Copy Image to Clipboard (Default / Top action)
      table.insert(rows, {
        id = "copy:" .. item.path,
        title = item.filename,
        subtitle = item.size .. " • " .. item.time_ago .. " • Press Enter to Copy Image",
        glyph = "clipboard",
      })

      -- Action 2: Open Image Viewer
      if filter == "" or ("open"):find(filter, 1, true) or ("view"):find(filter, 1, true) then
        table.insert(rows, {
          id = "open:" .. item.path,
          title = "Open: " .. item.filename,
          subtitle = "View in default image viewer",
          glyph = "external-link",
        })
      end
    end
  end

  if #rows == 0 then
    table.insert(rows, {
      id = "",
      title = "No Screenshots Found",
      subtitle = "Screenshots will appear here after taking one",
      glyph = "photo-off",
    })
  end

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)

  -- Render immediately with cache
  launcher.setResults(query, renderRows(text))

  -- Refresh list in background
  noctalia.runAsync("/home/bry/.local/bin/recent-files shots", function(res)
    if res.exitCode == 0 and type(res.stdout) == "string" and res.stdout ~= "" then
      local parsed = noctalia.json.decode(res.stdout)
      if type(parsed) == "table" then
        cachedShots = parsed
        launcher.setResults(query, renderRows(text))
      end
    end
  end)
end

function onActivate(id)
  if id == "" then return end

  local action, path = id:match("^([^:]+):(.+)$")
  if action == "copy" then
    local escaped = path:gsub("'", "'\\''")
    noctalia.runAsync("/home/bry/.local/bin/recent-files copy-image '" .. escaped .. "'")
  elseif action == "open" then
    local escaped = path:gsub("'", "'\\''")
    noctalia.runAsync("/home/bry/.local/bin/recent-files open '" .. escaped .. "'")
  end
end
