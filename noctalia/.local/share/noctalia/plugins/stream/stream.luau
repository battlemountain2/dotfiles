--!nonstrict

local scenes = {
  { name = "Starting Soon", glyph = "hourglass", sub = "Countdown Card" },
  { name = "Full Cam", glyph = "video", sub = "1080p Yeti Cam" },
  { name = "Idle", glyph = "coffee", sub = "Chat + Cider Music" },
  { name = "Browser / Reacts", glyph = "browser", sub = "Desktop Window & Pip" },
  { name = "Game scene", glyph = "device-gamepad-2", sub = "Direct GPU Game Capture" },
  { name = "Be Right Back", glyph = "player-pause", sub = "Intermission Card" },
  { name = "Stream Ending", glyph = "flag", sub = "Outro Card" },
}

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}

  -- 1. Stream Mode (DND)
  if filter == "" or ("privacy"):find(filter, 1, true) or ("dnd"):find(filter, 1, true) or ("mode"):find(filter, 1, true) then
    table.insert(rows, {
      id = "action:dnd",
      title = "Toggle Stream Privacy (DND)",
      subtitle = "Mute/Unmute desktop notifications while streaming",
      glyph = "bell-off",
    })
  end

  -- 2. Mic Mute Toggle
  if filter == "" or ("mic"):find(filter, 1, true) or ("mute"):find(filter, 1, true) or ("yeti"):find(filter, 1, true) then
    table.insert(rows, {
      id = "action:mute_mic",
      title = "Toggle Mic Mute (Yeti X)",
      subtitle = "Mute/Unmute microphone input in OBS",
      glyph = "microphone-off",
    })
  end

  -- 3. OBS Scenes
  for _, s in ipairs(scenes) do
    if filter == "" or s.name:lower():find(filter, 1, true) or s.sub:lower():find(filter, 1, true) then
      table.insert(rows, {
        id = "scene:" .. s.name,
        title = "Switch Scene: " .. s.name,
        subtitle = s.sub .. " • Press Enter to switch in OBS",
        glyph = s.glyph,
      })
    end
  end

  -- 4. Launch OBS Studio if not running
  if filter == "" or ("obs"):find(filter, 1, true) or ("launch"):find(filter, 1, true) then
    table.insert(rows, {
      id = "action:launch_obs",
      title = "Launch OBS Studio",
      subtitle = "Start OBS Studio Flatpak",
      glyph = "external-link",
    })
  end

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)
  launcher.setResults(query, renderRows(text))
end

function onActivate(id)
  if id == "action:dnd" then
    noctalia.runAsync("/home/bry/.local/bin/obs-control stream-mode")
  elseif id == "action:mute_mic" then
    noctalia.runAsync("/home/bry/.local/bin/obs-control mute Mic/Aux")
  elseif id == "action:launch_obs" then
    noctalia.runAsync("flatpak run com.obsproject.Studio")
  elseif id:sub(1, 6) == "scene:" then
    local sceneName = id:sub(7)
    local escaped = sceneName:gsub("'", "'\\''")
    noctalia.runAsync("/home/bry/.local/bin/obs-control scene '" .. escaped .. "'")
  end
end
