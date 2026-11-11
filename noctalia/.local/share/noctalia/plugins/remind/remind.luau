--!nonstrict

function onQuery(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text ~= "" then
    table.insert(rows, {
      id = "remind:" .. text,
      title = "Set Reminder: " .. text,
      subtitle = "Press Enter to schedule",
      glyph = "alarm",
    })
  else
    table.insert(rows, {
      id = "help",
      title = "Set a Reminder",
      subtitle = "Type: 40m Pizza or 6:00pm Dinner",
      glyph = "alarm",
    })
  end

  launcher.setResults(query, rows)
end

function onActivate(id)
  local cmd = id:match("^remind:(.+)$")
  if cmd ~= nil and cmd ~= "" then
    noctalia.runAsync("/home/bry/.local/bin/remind " .. cmd)
  end
end
