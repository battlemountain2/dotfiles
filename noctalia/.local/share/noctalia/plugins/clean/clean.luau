--!nonstrict

local defaultActions = {
  {
    id = "clips:14",
    title = "Clean Old Gameplay Clips (>14 Days)",
    subtitle = "Removes replays/clips older than 2 weeks to free GBs",
    glyph = "video",
  },
  {
    id = "clips:7",
    title = "Clean Old Gameplay Clips (>7 Days)",
    subtitle = "Aggressive clean: keep only clips from the last week",
    glyph = "video",
  },
  {
    id = "pacman",
    title = "Clean Pacman Package Cache",
    subtitle = "Keep only 1 latest version via paccache -rk1",
    glyph = "package",
  },
  {
    id = "trash",
    title = "Empty System Trash",
    subtitle = "Permanently empty ~/.local/share/Trash",
    glyph = "trash",
  },
  {
    id = "df",
    title = "Check NVMe Storage Health",
    subtitle = "Inspect available gigabytes on root and home drives",
    glyph = "database",
  },
}

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}

  for _, act in ipairs(defaultActions) do
    if filter == "" or act.title:lower():find(filter, 1, true) or act.subtitle:lower():find(filter, 1, true) then
      table.insert(rows, act)
    end
  end

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)
  launcher.setResults(query, renderRows(text))
end

function onActivate(id)
  if id:sub(1, 6) == "clips:" then
    local days = id:sub(7)
    noctalia.runAsync("/home/bry/.local/bin/clip-tools clean " .. days)
  elseif id == "pacman" then
    noctalia.runAsync("paccache -rk1 && notify-send -a 'Storage' -i package 'Pacman Cache Cleaned' 'Removed older cached package tarballs.'")
  elseif id == "trash" then
    noctalia.runAsync("rm -rf ~/.local/share/Trash/* && notify-send -a 'Storage' -i trash 'Trash Emptied' 'All files in trash permanently deleted.'")
  elseif id == "df" then
    noctalia.runAsync("df -h / /home | awk 'NR>1 {print $6 \": \" $4 \" free of \" $2}' | paste -sd ' • ' - | xargs -I {} notify-send -a 'Storage' -i drive-harddisk 'Disk Space' '{}'")
  end
end
