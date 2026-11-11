--!nonstrict

local lastState = {
  current_sink = "fiio",
  volume = 100,
  sink_mute = false,
  mic_mute = false,
  ee_bypassed = false,
}

local function renderRows(filter)
  filter = filter:lower()
  local rows = {}
  local isFiio = lastState.current_sink == "fiio"
  local isSpeaker = lastState.current_sink == "speaker"

  -- 1. FiiO K11 R2R Headphones
  local fiioSub = isFiio and "● Active Output (USB DAC • ATH-R50x)" or "Press Enter to switch output to Headphones"
  local fiioTitle = isFiio and "FiiO K11 R2R (Headphones) [Active]" or "FiiO K11 R2R (Headphones)"
  if filter == "" or fiioTitle:lower():find(filter, 1, true) or ("headphones"):find(filter, 1, true) or ("dac"):find(filter, 1, true) or ("k11"):find(filter, 1, true) or ("fiio"):find(filter, 1, true) then
    table.insert(rows, {
      id = "fiio",
      title = fiioTitle,
      subtitle = fiioSub,
      glyph = "headphones",
    })
  end

  -- 2. Redragon Desk Speakers
  local spkSub = isSpeaker and "● Active Output (Ryzen HD Audio ALC897)" or "Press Enter to switch output to Speakers"
  local spkTitle = isSpeaker and "Redragon Speakers [Active]" or "Redragon Speakers"
  if filter == "" or spkTitle:lower():find(filter, 1, true) or ("speakers"):find(filter, 1, true) or ("desktop"):find(filter, 1, true) or ("speaker"):find(filter, 1, true) then
    table.insert(rows, {
      id = "speaker",
      title = spkTitle,
      subtitle = spkSub,
      glyph = "device-speaker",
    })
  end

  -- 3. EasyEffects DSP Toggle
  local eeActive = not lastState.ee_bypassed
  local eeTitle = eeActive and "EasyEffects: Enabled [Active]" or "EasyEffects: Bypassed [Raw Audio]"
  local eeSub = eeActive and "Processing active (Crossfeed ON) • Press Enter to bypass" or "Bypassed (Bit-perfect direct) • Press Enter to enable"
  if filter == "" or ("easyeffects"):find(filter, 1, true) or ("crossfeed"):find(filter, 1, true) or ("dsp"):find(filter, 1, true) or ("effects"):find(filter, 1, true) or ("ee"):find(filter, 1, true) then
    table.insert(rows, {
      id = "ee-toggle",
      title = eeTitle,
      subtitle = eeSub,
      glyph = eeActive and "adjustments" or "adjustments-off",
    })
  end

  -- 4. Microphone Mute Toggle (Blue Yeti X)
  local micMuted = lastState.mic_mute
  local micTitle = micMuted and "Yeti X Microphone: MUTED" or "Yeti X Microphone: LIVE"
  local micSub = micMuted and "Press Enter to unmute microphone" or "Press Enter to mute microphone"
  if filter == "" or ("mic"):find(filter, 1, true) or ("mute"):find(filter, 1, true) or ("yeti"):find(filter, 1, true) or ("microphone"):find(filter, 1, true) then
    table.insert(rows, {
      id = "mic-toggle",
      title = micTitle,
      subtitle = micSub,
      glyph = micMuted and "microphone-off" or "microphone",
    })
  end

  -- 5. Volume Mute Toggle
  local outMuted = lastState.sink_mute
  local outMuteTitle = outMuted and "Audio Output: MUTED" or string.format("Audio Volume: %d%%", lastState.volume or 100)
  local outMuteSub = outMuted and "Press Enter to unmute sound" or "Press Enter to toggle mute"
  if filter == "" or ("mute"):find(filter, 1, true) or ("volume"):find(filter, 1, true) or ("vol"):find(filter, 1, true) then
    table.insert(rows, {
      id = "mute-toggle",
      title = outMuteTitle,
      subtitle = outMuteSub,
      glyph = outMuted and "volume-off" or "volume",
    })
  end

  -- 6. Quick Numeric Volume (e.g. user typed '50', '80', '100', '25')
  local num = tonumber(filter)
  if num ~= nil and num >= 0 and num <= 150 then
    table.insert(rows, 1, {
      id = "volume:" .. tostring(num),
      title = string.format("Set Volume to %d%%", num),
      subtitle = "Press Enter to adjust output volume",
      glyph = "volume-2",
    })
  elseif filter == "vol" or filter == "volume" then
    table.insert(rows, { id = "volume:50", title = "Set Volume to 50%", subtitle = "Quick preset", glyph = "volume-2" })
    table.insert(rows, { id = "volume:75", title = "Set Volume to 75%", subtitle = "Quick preset", glyph = "volume-2" })
    table.insert(rows, { id = "volume:100", title = "Set Volume to 100%", subtitle = "Quick preset", glyph = "volume-2" })
  end

  -- 7. Launch EasyEffects GUI
  if filter == "" or ("gui"):find(filter, 1, true) or ("easyeffects"):find(filter, 1, true) or ("app"):find(filter, 1, true) then
    table.insert(rows, {
      id = "gui",
      title = "Open EasyEffects GUI",
      subtitle = "Launch full Equalizer, Crossfeed & Effects window",
      glyph = "external-link",
    })
  end

  -- 8. Launch Pavucontrol / Audio Mixer
  if filter == "" or ("mixer"):find(filter, 1, true) or ("pavucontrol"):find(filter, 1, true) or ("pavu"):find(filter, 1, true) then
    table.insert(rows, {
      id = "pavucontrol",
      title = "Open Volume Mixer (Pavucontrol)",
      subtitle = "Per-app stream routing & levels",
      glyph = "adjustments-horizontal",
    })
  end

  return rows
end

function onQuery(query)
  local text = noctalia.string.trim(query)

  -- First, immediately render with cached/current state so there is zero UI lag
  launcher.setResults(query, renderRows(text))

  -- Then refresh state in the background and update the results if the query is still active
  noctalia.runAsync("/home/bry/.local/bin/audio-launcher-control status", function(res)
    if res.exitCode == 0 and type(res.stdout) == "string" and res.stdout ~= "" then
      local parsed = noctalia.json.decode(res.stdout)
      if type(parsed) == "table" then
        lastState.current_sink = parsed.current_sink or lastState.current_sink
        lastState.volume = parsed.volume or lastState.volume
        lastState.sink_mute = parsed.sink_mute == true
        lastState.mic_mute = parsed.mic_mute == true
        lastState.ee_bypassed = parsed.ee_bypassed == true

        launcher.setResults(query, renderRows(text))
      end
    end
  end)
end

function onActivate(id)
  if id == "" then return end

  local vol = id:match("^volume:(%d+)$")
  if vol ~= nil then
    noctalia.runAsync("/home/bry/.local/bin/audio-launcher-control volume " .. vol)
  else
    noctalia.runAsync("/home/bry/.local/bin/audio-launcher-control " .. id)
  end
end
