--!nonstrict

local cachedResults = {}

local function renderRows(query)
  local text = noctalia.string.trim(query)
  local rows = {}

  if text == "" then
    table.insert(rows, {
      id = "web:arch",
      title = "Arch Linux Package Search",
      subtitle = "Type a package name (e.g. pac btop, pac hyprland, pac zed)",
      glyph = "package",
    })
    table.insert(rows, {
      id = "web:aur",
      title = "Open Arch User Repository (AUR)",
      subtitle = "Browse aur.archlinux.org",
      glyph = "external-link",
    })
    return rows
  end

  for _, pkg in ipairs(cachedResults) do
    local status = pkg.installed and "[Installed] • " or ""
    local title = pkg.name .. " " .. pkg.version .. (pkg.installed and " ✓" or "")
    local subtitle = status .. pkg.repo .. " — " .. (pkg.desc ~= "" and pkg.desc or "No description")

    table.insert(rows, {
      id = "open:" .. pkg.name,
      title = title,
      subtitle = subtitle,
      glyph = pkg.installed and "circle-check" or "package",
    })
  end

  -- Online search fallbacks
  table.insert(rows, {
    id = "web:search:" .. text,
    title = "Search Arch Packages online: " .. text,
    subtitle = "Open archlinux.org/packages/?q=" .. text .. " in Zen Browser",
    glyph = "world",
  })
  table.insert(rows, {
    id = "web:aur:" .. text,
    title = "Search AUR online: " .. text,
    subtitle = "Open aur.archlinux.org/packages?K=" .. text .. " in Zen Browser",
    glyph = "external-link",
  })

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)

  -- Render immediately
  launcher.setResults(query, renderRows(text))

  if text == "" then
    cachedResults = {}
    return
  end

  -- Run pacman search in background
  local escaped = text:gsub("'", "'\\''")
  noctalia.runAsync("/home/bry/.local/bin/pac-search '" .. escaped .. "'", function(res)
    if res.exitCode == 0 and type(res.stdout) == "string" and res.stdout ~= "" then
      local parsed = noctalia.json.decode(res.stdout)
      if type(parsed) == "table" then
        cachedResults = parsed
        launcher.setResults(query, renderRows(text))
      end
    end
  end)
end

function onActivate(id)
  if id == "" then return end

  local action, val = id:match("^([^:]+):(.+)$")
  if action == "open" then
    noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://archlinux.org/packages/?q=" .. val .. "'")
  elseif action == "web" then
    local subAction, term = val:match("^([^:]+):(.+)$")
    if subAction == "search" then
      noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://archlinux.org/packages/?q=" .. term .. "'")
    elseif subAction == "aur" then
      noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://aur.archlinux.org/packages?K=" .. term .. "'")
    else
      if val == "aur" then
        noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://aur.archlinux.org'")
      else
        noctalia.runAsync("/home/bry/.config/hypr/scripts/open_and_focus.sh 'https://archlinux.org/packages'")
      end
    end
  end
end
