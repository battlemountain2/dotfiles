--!nonstrict

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text ~= "" then
    table.insert(rows, {
      id = text,
      title = "Force Kill: " .. text,
      subtitle = "Press Enter to execute: pkill -9 -if " .. text,
      glyph = "skull",
    })
  else
    table.insert(rows, {
      id = "",
      title = "Force Kill Process",
      subtitle = "Type process or app name (e.g. steam, discord, zen)",
      glyph = "skull",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  if id ~= "" then
    local escaped = id:gsub("'", "'\\''")
    noctalia.runAsync("pkill -9 -if '" .. escaped .. "' && notify-send -u critical -i process-stop 'Process Terminated' 'Force killed processes matching: " .. escaped .. "'")
  end
end
