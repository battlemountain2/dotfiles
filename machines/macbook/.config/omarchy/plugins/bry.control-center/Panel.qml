import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
import qs.Ui
import qs.Commons
import "."

Panel {
  id: root
  moduleName: "bry.control-center"
  ipcTarget: ""
  manageIpc: false

  IpcHandler {
    target: "bry.control-center"

    function open(): void {
      root.customAnchorX = -1
      root.open()
    }
    function close(): void {
      root.close()
    }
    function show(): void {
      root.customAnchorX = -1
      root.open()
    }
    function hide(): void {
      root.close()
    }
    function toggle(): void {
      root.customAnchorX = -1
      root.toggle()
    }
    function openAt(x: real): void {
      root.openAtCursor(x)
    }
    function toggleAt(x: real): void {
      root.toggleAtCursor(x)
    }
  }

  property real customAnchorX: -1

  function openAtCursor(xCoord) {
    customAnchorX = xCoord
    root.open()
  }

  function toggleAtCursor(xCoord) {
    if (root.opened) {
      if (customAnchorX >= 0 && Math.abs(customAnchorX - xCoord) < 40) {
        root.close()
        customAnchorX = -1
      } else {
        customAnchorX = xCoord
      }
    } else {
      openAtCursor(xCoord)
    }
  }

  onOpenedChanged: {
    if (opened) {
      refresh()
    } else {
      Qt.callLater(function() {
        if (!root.opened) customAnchorX = -1
      })
    }
  }

  // ── State providers ──────────────────────────────────────────────────────
  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource
  readonly property bool micMuted: source && source.audio ? source.audio.muted : true
  readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
  readonly property bool muted: sink && sink.audio ? sink.audio.muted : true
  readonly property var batteryDevice: UPower.displayDevice
  readonly property bool batteryPresent: !!(batteryDevice && batteryDevice.isPresent)
  readonly property real batteryPercent: batteryDevice ? batteryDevice.percentage : 0
  readonly property bool onBattery: UPower.onBattery

  property real displayBrightness: 0
  property real kbdBrightness: 0
  property real displayBrightnessMax: 500
  property real kbdBrightnessMax: 255
  property bool nightLightOn: false
  property bool stayAwakeOn: false
  property bool dndOn: false
  property int displayRefreshRate: 120
  property real lastPromptedPercent: 0
  property bool phoneConnected: false
  property string phoneName: "iPhone"
  property int phoneBattery: 0

  property var batteryInfo: ({})

  // ── MPRIS Media State ───────────────────────────────────────────────────
  readonly property var mprisPlayers: (Mpris && Mpris.players) ? Mpris.players.values : []
  property int playerUpdateCounter: 0

  Instantiator {
    model: root.mprisPlayers
    delegate: Connections {
      required property var modelData
      target: modelData
      function onIsPlayingChanged() { root.playerUpdateCounter++ }
      function onPlaybackStateChanged() { root.playerUpdateCounter++ }
      function onTrackTitleChanged() { root.playerUpdateCounter++ }
      function onTrackArtistChanged() { root.playerUpdateCounter++ }
      function onTrackArtUrlChanged() { root.playerUpdateCounter++ }
    }
  }

  readonly property var activePlayer: {
    var dummy = root.playerUpdateCounter
    var list = root.mprisPlayers
    if (!list || list.length === 0) return null
    for (var i = 0; i < list.length; i++) {
      var p = list[i]
      if (p && p.isPlaying) return p
    }
    for (var j = 0; j < list.length; j++) {
      var p2 = list[j]
      if (p2 && (p2.trackTitle || p2.trackArtist)) return p2
    }
    return list[0] || null
  }

  readonly property bool hasMedia: activePlayer !== null && ((activePlayer.trackTitle && activePlayer.trackTitle !== "") || (activePlayer.trackArtist && activePlayer.trackArtist !== ""))
  readonly property string trackTitle: activePlayer ? (activePlayer.trackTitle || "Not Playing") : "Not Playing"
  readonly property string trackArtist: activePlayer ? (activePlayer.trackArtist || (activePlayer.trackAlbum || "No active media")) : "No active media"
  readonly property string trackArt: (activePlayer && activePlayer.trackArtUrl) ? activePlayer.trackArtUrl : ""
  readonly property string playerIdentity: activePlayer ? (activePlayer.identity || activePlayer.desktopEntry || "") : ""
  readonly property bool isPlaying: activePlayer ? !!activePlayer.isPlaying : false

  function parseBatteryInfo(raw) {
    var result = {}
    var lines = raw.split("\n")
    for (var i = 0; i < lines.length; i++) {
      var parts = lines[i].split("\t")
      if (parts.length >= 2) result[parts[0].trim()] = parts[1].trim()
    }
    batteryInfo = result
  }

  function checkBatteryStatus() {
    if (batteryPresent && onBattery && batteryPercent > 0 && batteryPercent <= 20) {
      if (Math.abs(batteryPercent - lastPromptedPercent) >= 2) {
        lastPromptedPercent = batteryPercent
        if (!lowBatteryPromptProc.running) lowBatteryPromptProc.running = true
      }
    } else if (!onBattery && batteryPresent) {
      lastPromptedPercent = 0
      if (!restoreAcProc.running) restoreAcProc.running = true
    }
  }

  onBatteryPercentChanged: checkBatteryStatus()
  onOnBatteryChanged: checkBatteryStatus()

  function refresh() {
    if (!brightnessProc.running) brightnessProc.running = true
    if (!kbdBrightnessProc.running) kbdBrightnessProc.running = true
    if (!nightLightProc.running) nightLightProc.running = true
    if (!stayAwakeProc.running) stayAwakeProc.running = true
    if (!dndProc.running) dndProc.running = true
    if (!refreshRateProc.running) refreshRateProc.running = true
    if (batteryPresent && !batteryProc.running) batteryProc.running = true
    if (!phoneStatusProc.running) phoneStatusProc.running = true
  }

  Process {
    id: brightnessProc
    command: ["brightnessctl", "-d", "apple-panel-bl", "get"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: { root.displayBrightness = parseInt(text.trim()) || 0 } }
  }

  Process {
    id: kbdBrightnessProc
    command: ["brightnessctl", "-d", "kbd_backlight", "get"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: { root.kbdBrightness = parseInt(text.trim()) || 0 } }
  }

  Process {
    id: nightLightProc
    command: ["omarchy-toggle-nightlight", "--status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var obj = JSON.parse(text.trim())
          root.nightLightOn = !!obj.enabled
        } catch(e) { root.nightLightOn = false }
      }
    }
    onExited: function(code) { if (code !== 0) root.nightLightOn = false }
  }

  Process {
    id: stayAwakeProc
    command: ["omarchy-toggle-idle", "--status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var obj = JSON.parse(text.trim())
          root.stayAwakeOn = !!obj.enabled
        } catch(e) { root.stayAwakeOn = false }
      }
    }
  }

  Process {
    id: dndProc
    command: ["omarchy-shell", "notifications", "dndState"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.dndOn = (text.trim() === "on")
      }
    }
    onExited: function(code) { if (code !== 0) root.dndOn = false }
  }

  Process {
    id: batteryProc
    command: ["omarchy-battery-status", "--shell"]
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.parseBatteryInfo(text) }
  }

  Process {
    id: refreshRateProc
    command: ["omarchy-display-rate", "get"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var r = parseInt(text.trim())
        if (!isNaN(r) && r > 0) root.displayRefreshRate = r
      }
    }
  }

  Process {
    id: lowBatteryPromptProc
    command: ["omarchy-display-rate", "prompt-low-battery", String(Math.round(root.batteryPercent))]
  }

  Process {
    id: restoreAcProc
    command: ["omarchy-display-rate", "restore-ac"]
    onExited: refreshRateProc.running = true
  }

  Process {
    id: phoneStatusProc
    command: ["omarchy-phone-status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var obj = JSON.parse(text.trim())
          root.phoneConnected = !!obj.connected
          root.phoneName = obj.name || "iPhone"
          root.phoneBattery = parseInt(obj.battery) || 0
        } catch (e) {
          root.phoneConnected = false
        }
      }
    }
  }

  Process {
    id: actMessages
    command: ["omarchy-messages"]
  }

  Process {
    id: actAirDrop
    command: ["omarchy-airdrop"]
  }

  Process {
    id: actNightlight
    command: ["omarchy-toggle-nightlight"]
    onExited: nightLightProc.running = true
  }

  Process {
    id: actStayAwake
    command: ["omarchy-toggle-idle"]
    onExited: stayAwakeProc.running = true
  }

  Process {
    id: actDnd
    command: ["omarchy-shell", "notifications", "toggleDnd"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: { root.dndOn = (text.trim() === "on") }
    }
    onExited: dndProc.running = true
  }

  Process {
    id: actToggleHz
    command: ["omarchy-display-rate", "toggle"]
    onExited: refreshRateProc.running = true
  }

  Process {
    id: actToggleBar
    command: ["omarchy-toggle-bar"]
  }

  Process {
    id: actMediaPrev
    command: ["omarchy-shell", "shell", "call", "media", "previous", ""]
  }

  Process {
    id: actMediaPlayPause
    command: ["omarchy-shell", "shell", "call", "media", "playPause", ""]
  }

  Process {
    id: actMediaNext
    command: ["omarchy-shell", "shell", "call", "media", "next", ""]
  }

  property int pendingBrightness: -1
  Process {
    id: setLiveBrightnessProc
    onExited: {
      if (root.pendingBrightness >= 0 && root.pendingBrightness !== Math.round(root.displayBrightness)) {
        var nextVal = root.pendingBrightness
        root.pendingBrightness = -1
        setLiveBrightnessProc.command = ["brightnessctl", "-q", "-d", "apple-panel-bl", "set", String(nextVal)]
        setLiveBrightnessProc.running = true
      }
    }
  }

  function setLiveBrightness(val) {
    var rounded = Math.max(1, Math.min(root.displayBrightnessMax, Math.round(val)))
    root.displayBrightness = rounded
    if (!setLiveBrightnessProc.running) {
      root.pendingBrightness = -1
      setLiveBrightnessProc.command = ["brightnessctl", "-q", "-d", "apple-panel-bl", "set", String(rounded)]
      setLiveBrightnessProc.running = true
    } else {
      root.pendingBrightness = rounded
    }
  }

  property int pendingKbdBrightness: -1
  Process {
    id: setLiveKbdBrightnessProc
    onExited: {
      if (root.pendingKbdBrightness >= 0 && root.pendingKbdBrightness !== Math.round(root.kbdBrightness)) {
        var nextVal = root.pendingKbdBrightness
        root.pendingKbdBrightness = -1
        setLiveKbdBrightnessProc.command = ["brightnessctl", "-q", "-d", "kbd_backlight", "set", String(nextVal)]
        setLiveKbdBrightnessProc.running = true
      }
    }
  }

  function setLiveKbdBrightness(val) {
    var rounded = Math.max(0, Math.min(root.kbdBrightnessMax, Math.round(val)))
    root.kbdBrightness = rounded
    if (!setLiveKbdBrightnessProc.running) {
      root.pendingKbdBrightness = -1
      setLiveKbdBrightnessProc.command = ["brightnessctl", "-q", "-d", "kbd_backlight", "set", String(rounded)]
      setLiveKbdBrightnessProc.running = true
    } else {
      root.pendingKbdBrightness = rounded
    }
  }

  Timer { interval: 5000; running: root.opened; repeat: true; onTriggered: root.refresh() }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Item {
    id: cursorAnchorProxy
    width: 0
    height: button.height
    x: {
      if (root.customAnchorX < 0) return button.width / 2
      var win = root.QsWindow.window || button.QsWindow.window
      if (!win || !win.contentItem) return button.width / 2
      var pos = root.mapToItem(win.contentItem, 0, 0)
      return root.customAnchorX - pos.x
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󱖚"
    tooltipText: "Control Center"
    onPressed: function(b) {
      root.customAnchorX = -1
      root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: cursorAnchorProxy
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(350))
    contentHeight: panel.fittedContentHeight(mainColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
          id: mainColumn
          width: parent.width
          spacing: Style.space(10)

          // ── Header Row ────────────────────────────────────────────────────
          Item {
            width: parent.width
            height: Style.space(26)

            Row {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(8)

              Text {
                text: "󱖚"
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                color: Color.accent
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: "Control Center"
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
                color: Color.foreground
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            // Quick Power Menu button (summons Omarchy power menu)
            Rectangle {
              id: powerBtn
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              width: Style.space(26)
              height: Style.space(26)
              radius: width / 2
              color: powerMouse.containsMouse ? Util.alpha(Color.urgent, 0.20) : Util.alpha(Color.foreground, 0.06)

              Behavior on color { ColorAnimation { duration: 150 } }

              Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.family: Style.font.family
                font.pixelSize: Style.space(13)
                color: powerMouse.containsMouse ? Color.urgent : Qt.darker(Color.foreground, 1.3)
                Behavior on color { ColorAnimation { duration: 150 } }
              }

              Process {
                id: actOpenPowerMenu
                command: ["omarchy", "menu", "summon", "system"]
              }

              MouseArea {
                id: powerMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.close()
                  actOpenPowerMenu.running = true
                }
              }
            }
          }

          // ── Now Playing Card ──────────────────────────────────────────────
          BorderSurface {
            id: mediaCard
            width: parent.width
            height: Style.space(76)
            radius: Style.cornerRadius
            color: root.hasMedia ? Util.alpha(Color.foreground, 0.06) : Util.alpha(Color.foreground, 0.03)
            borderSpec: Border.surfaceSpec(
              "card",
              root.hasMedia ? "selected" : "normal",
              root.hasMedia ? Util.alpha(Color.accent, 0.35) : Util.alpha(Color.foreground, 0.12),
              1
            )

            Item {
              anchors.fill: parent
              anchors.margins: Style.space(10)

              // Album Art
              Item {
                id: artBox
                width: Style.space(54)
                height: Style.space(54)
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                  id: artMask
                  anchors.fill: parent
                  radius: Style.space(12)
                  visible: false
                  layer.enabled: true
                }

                Rectangle {
                  anchors.fill: parent
                  radius: Style.space(12)
                  color: Util.alpha(Color.foreground, 0.08)

                  Text {
                    anchors.centerIn: parent
                    text: root.hasMedia ? "󰝚" : "󰎆"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.title
                    color: Color.accent
                    visible: artImage.status !== Image.Ready
                  }
                }

                Image {
                  id: artImage
                  anchors.fill: parent
                  source: root.trackArt
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                  visible: status === Image.Ready
                  layer.enabled: true
                  layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: artMask
                  }
                }
              }

              // Track Info
              Column {
                anchors.left: artBox.right
                anchors.leftMargin: Style.space(10)
                anchors.right: mediaButtons.left
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                  text: root.trackTitle
                  color: Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  font.bold: true
                  elide: Text.ElideRight
                  width: parent.width
                }

                Text {
                  text: root.trackArtist
                  color: Qt.darker(Color.foreground, 1.4)
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideRight
                  width: parent.width
                }

                Rectangle {
                  visible: root.playerIdentity !== ""
                  height: Style.space(16)
                  width: Math.min(parent.width, playerBadgeText.implicitWidth + Style.space(10))
                  radius: Style.space(4)
                  color: Util.alpha(Color.accent, 0.16)

                  Text {
                    id: playerBadgeText
                    anchors.centerIn: parent
                    text: root.playerIdentity
                    color: Color.accent
                    font.family: Style.font.family
                    font.pixelSize: Style.space(9)
                    font.bold: true
                    elide: Text.ElideRight
                  }
                }
              }

              // Playback Controls
              Row {
                id: mediaButtons
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(4)

                // Previous
                Item {
                  width: Style.space(30)
                  height: Style.space(30)
                  anchors.verticalCenter: parent.verticalCenter

                  Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: prevMouse.containsMouse ? Util.alpha(Color.foreground, 0.12) : "transparent"
                  }

                  Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: Color.foreground
                    font.family: Style.font.family
                    font.pixelSize: Style.font.icon
                  }

                  MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (root.activePlayer && root.activePlayer.canGoPrevious) {
                        root.activePlayer.previous()
                      } else {
                        actMediaPrev.running = true
                      }
                    }
                  }
                }

                // Play / Pause
                Item {
                  width: Style.space(36)
                  height: Style.space(36)
                  anchors.verticalCenter: parent.verticalCenter

                  Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: root.isPlaying
                      ? Color.accent
                      : (playMouse.containsMouse ? Util.alpha(Color.foreground, 0.18) : Util.alpha(Color.foreground, 0.10))

                    Behavior on color { ColorAnimation { duration: 150 } }
                  }

                  Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    color: root.isPlaying ? Color.background : Color.foreground
                    font.family: Style.font.family
                    font.pixelSize: Style.font.title
                  }

                  MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (root.activePlayer) {
                        if (root.activePlayer.canTogglePlaying) {
                          root.activePlayer.togglePlaying()
                        } else if (root.isPlaying && root.activePlayer.canPause) {
                          root.activePlayer.pause()
                        } else if (!root.isPlaying && root.activePlayer.canPlay) {
                          root.activePlayer.play()
                        }
                      } else {
                        actMediaPlayPause.running = true
                      }
                    }
                  }
                }

                // Next
                Item {
                  width: Style.space(30)
                  height: Style.space(30)
                  anchors.verticalCenter: parent.verticalCenter

                  Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: nextMouse.containsMouse ? Util.alpha(Color.foreground, 0.12) : "transparent"
                  }

                  Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: Color.foreground
                    font.family: Style.font.family
                    font.pixelSize: Style.font.icon
                  }

                  MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (root.activePlayer && root.activePlayer.canGoNext) {
                        root.activePlayer.next()
                      } else {
                        actMediaNext.running = true
                      }
                    }
                  }
                }
              }
            }
          }

          // ── Sliders Group Card ───────────────────────────────────────────
          BorderSurface {
            width: parent.width
            height: slidersCol.implicitHeight + Style.space(16)
            radius: Style.cornerRadius
            color: Util.alpha(Color.foreground, 0.04)
            borderSpec: Border.surfaceSpec("card", "normal", Util.alpha(Color.foreground, 0.10), 1)

            Column {
              id: slidersCol
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.top: parent.top
              anchors.margins: Style.space(8)
              spacing: Style.space(8)

              // Display Brightness
              Row {
                width: parent.width
                spacing: Style.spacing.md

                Text {
                  text: "󰃠"
                  color: Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.icon
                  anchors.verticalCenter: parent.verticalCenter
                }

                PanelSlider {
                  bar: root.bar
                  width: parent.width - Style.space(36)
                  minimum: 0
                  maximum: root.displayBrightnessMax
                  value: root.displayBrightness
                  integer: true

                  onMoved: function(val) { root.setLiveBrightness(val) }
                  onReleased: function(val) {
                    root.setLiveBrightness(val)
                    Qt.callLater(root.refresh)
                  }
                }
              }

              // Keyboard Backlight
              Row {
                width: parent.width
                spacing: Style.spacing.md

                Text {
                  text: "󰌌"
                  color: Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.icon
                  anchors.verticalCenter: parent.verticalCenter
                }

                PanelSlider {
                  bar: root.bar
                  width: parent.width - Style.space(36)
                  minimum: 0
                  maximum: root.kbdBrightnessMax
                  value: root.kbdBrightness
                  integer: true

                  onMoved: function(val) { root.setLiveKbdBrightness(val) }
                  onReleased: function(val) {
                    root.setLiveKbdBrightness(val)
                    Qt.callLater(root.refresh)
                  }
                }
              }

              // Volume Slider
              Row {
                width: parent.width
                spacing: Style.spacing.md

                Text {
                  text: root.muted ? "󰖁" : (root.volume > 0.5 ? "󰕾" : "󰖀")
                  color: root.muted ? Color.urgent : Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.icon
                  anchors.verticalCenter: parent.verticalCenter

                  MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (root.sink && root.sink.audio) root.sink.audio.muted = !root.sink.audio.muted
                    }
                  }
                }

                PanelSlider {
                  bar: root.bar
                  width: parent.width - Style.space(36)
                  minimum: 0
                  maximum: 1
                  value: root.volume
                  step: 0.05
                  onMoved: function(val) {
                    if (root.sink && root.sink.audio) root.sink.audio.volume = val
                  }
                  onReleased: function(val) {
                    if (root.sink && root.sink.audio) root.sink.audio.volume = val
                  }
                }
              }
            }
          }

          // ── Quick Toggles Grid (8 Tiles) ──────────────────────────────────
          Grid {
            width: parent.width
            columns: 2
            spacing: Style.space(8)

            ControlTile {
              tileWidth: (parent.width - parent.spacing) / 2
              iconText: Networking.wifiEnabled ? "󰖩" : "󰖪"
              label: "Wi-Fi"
              subtitle: Networking.wifiEnabled ? "On" : "Off"
              active: Networking.wifiEnabled
              onClicked: { Networking.wifiEnabled = !Networking.wifiEnabled }
            }

            ControlTile {
              tileWidth: (parent.width - parent.spacing) / 2
              iconText: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled ? "󰂯" : "󰂲"
              label: "Bluetooth"
              subtitle: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled ? "On" : "Off"
              active: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled

              Process { id: actBt; onExited: root.refresh() }
              onClicked: {
                if (!Bluetooth.defaultAdapter) return
                actBt.command = ["omarchy-bluetooth-power", Bluetooth.defaultAdapter.enabled ? "off" : "on"]
                actBt.running = true
              }
            }

            ControlTile {
              tileWidth: (parent.width - parent.spacing) / 2
              iconText: "󰌵"
              label: "Night Light"
              subtitle: root.nightLightOn ? "On" : "Off"
              active: root.nightLightOn
              
              onClicked: {
                root.nightLightOn = !root.nightLightOn
                actNightlight.running = true
              }
            }

            ControlTile {
              tileWidth: (parent.width - parent.spacing) / 2
              iconText: "󰍹"
              label: "Stay Awake"
              subtitle: root.stayAwakeOn ? "On" : "Off"
              active: root.stayAwakeOn

              onClicked: {
                root.stayAwakeOn = !root.stayAwakeOn
                actStayAwake.running = true
              }
            }

            ControlTile {
              tileWidth: (parent.width - parent.spacing) / 2
              iconText: "󰂛"
              label: "Do Not Disturb"
              subtitle: root.dndOn ? "On" : "Off"
              active: root.dndOn

              onClicked: {
                root.dndOn = !root.dndOn
                actDnd.running = true
              }
            }

            ControlTile {
              tileWidth: (parent.width - parent.spacing) / 2
              iconText: root.micMuted ? "󰍭" : "󰍬"
              label: "Microphone"
              subtitle: root.micMuted ? "Muted" : "Live"
              active: !root.micMuted
              onClicked: {
                if (root.source && root.source.audio) root.source.audio.muted = !root.source.audio.muted
              }
            }

            ControlTile {
              tileWidth: (parent.width - parent.spacing) / 2
              iconText: root.displayRefreshRate >= 100 ? "󰍹" : "󰂃"
              label: root.displayRefreshRate >= 100 ? "ProMotion" : "Battery Saver"
              subtitle: root.displayRefreshRate >= 100 ? "120Hz" : "60Hz"
              active: root.displayRefreshRate >= 100
              onClicked: {
                root.displayRefreshRate = (root.displayRefreshRate >= 100 ? 60 : 120)
                actToggleHz.running = true
              }
            }

            ControlTile {
              tileWidth: (parent.width - parent.spacing) / 2
              iconText: "󱂬"
              label: "Top Bar"
              subtitle: "Toggle"
              active: true
              onClicked: actToggleBar.running = true
            }
          }

          // ── Phone Bridge Card (iPhone / LocalSend / BlueFerry) ────────────
          BorderSurface {
            id: phoneCard
            width: parent.width
            height: Style.space(64)
            radius: Style.cornerRadius
            color: root.phoneConnected ? Util.alpha(Color.foreground, 0.05) : Util.alpha(Color.foreground, 0.03)
            borderSpec: Border.surfaceSpec(
              "card",
              root.phoneConnected ? "selected" : "normal",
              root.phoneConnected ? Util.alpha(Color.accent, 0.30) : Util.alpha(Color.foreground, 0.10),
              1
            )

            Item {
              anchors.fill: parent
              anchors.margins: Style.space(8)

              // Left: Phone Icon + Device Name + Battery Pill
              Row {
                anchors.left: parent.left
                anchors.right: phoneActionsRow.left
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(8)

                Rectangle {
                  width: Style.space(36)
                  height: Style.space(36)
                  radius: width / 2
                  color: root.phoneConnected ? Util.alpha(Color.accent, 0.15) : Util.alpha(Color.foreground, 0.06)
                  anchors.verticalCenter: parent.verticalCenter

                  Text {
                    anchors.centerIn: parent
                    text: "󰄡"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.icon
                    color: root.phoneConnected ? Color.accent : Qt.darker(Color.foreground, 1.5)
                  }
                }

                Column {
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 2
                  width: parent.width - Style.space(44)

                  Row {
                    spacing: Style.space(6)
                    Text {
                      text: root.phoneName !== "" ? root.phoneName : "iPhone"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.body
                      font.bold: true
                      color: Color.foreground
                      elide: Text.ElideRight
                      maximumLineCount: 1
                    }

                    Rectangle {
                      visible: root.phoneConnected && root.phoneBattery > 0
                      height: Style.space(16)
                      width: phoneBatteryText.implicitWidth + Style.space(10)
                      radius: Style.space(4)
                      color: root.phoneBattery <= 20 ? Util.alpha(Color.urgent, 0.20) : Util.alpha(Color.accent, 0.16)
                      anchors.verticalCenter: parent.verticalCenter

                      Text {
                        id: phoneBatteryText
                        anchors.centerIn: parent
                        text: (root.phoneBattery <= 20 ? "󰂃 " : "󰁹 ") + root.phoneBattery + "%"
                        color: root.phoneBattery <= 20 ? Color.urgent : Color.accent
                        font.family: Style.font.family
                        font.pixelSize: Style.space(9)
                        font.bold: true
                      }
                    }
                  }

                  Text {
                    text: root.phoneConnected ? "Connected" : "Disconnected"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    color: root.phoneConnected ? Qt.darker(Color.foreground, 1.4) : Qt.darker(Color.foreground, 1.8)
                  }
                }
              }

              // Right: Action Buttons (Messages & AirDrop)
              Row {
                id: phoneActionsRow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Style.space(6)

                Rectangle {
                  width: Style.space(72)
                  height: Style.space(34)
                  radius: Style.space(6)
                  color: msgMouse.containsMouse ? Util.alpha(Color.accent, 0.25) : Util.alpha(Color.foreground, 0.08)

                  Behavior on color { ColorAnimation { duration: 120 } }

                  Row {
                    anchors.centerIn: parent
                    spacing: Style.space(4)
                    Text {
                      text: "󰭹"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      color: Color.accent
                    }
                    Text {
                      text: "Messages"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      font.bold: true
                      color: Color.foreground
                    }
                  }

                  MouseArea {
                    id: msgMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      root.close()
                      actMessages.running = true
                    }
                  }
                }

                Rectangle {
                  width: Style.space(66)
                  height: Style.space(34)
                  radius: Style.space(6)
                  color: airdropMouse.containsMouse ? Util.alpha(Color.accent, 0.25) : Util.alpha(Color.foreground, 0.08)

                  Behavior on color { ColorAnimation { duration: 120 } }

                  Row {
                    anchors.centerIn: parent
                    spacing: Style.space(4)
                    Text {
                      text: "󰀝"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      color: Color.accent
                    }
                    Text {
                      text: "AirDrop"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      font.bold: true
                      color: Color.foreground
                    }
                  }

                  MouseArea {
                    id: airdropMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      root.close()
                      actAirDrop.running = true
                    }
                  }
                }
              }
            }
          }

          // ── Screen Capture Card ───────────────────────────────────────────
          BorderSurface {
            width: parent.width
            height: Style.space(62)
            radius: Style.cornerRadius
            color: Util.alpha(Color.foreground, 0.04)
            borderSpec: Border.surfaceSpec("card", "normal", Util.alpha(Color.foreground, 0.10), 1)

            Row {
              id: captureRow
              anchors.fill: parent
              anchors.margins: Style.space(7)
              spacing: Style.space(6)

              ControlTile {
                tileWidth: (parent.width - Style.space(12)) / 3
                iconText: "󰹑"
                label: "Screen"
                compact: true

                Process { id: actScreen; command: ["omarchy-capture-screenshot", "fullscreen"] }
                onClicked: {
                  root.close()
                  actScreen.running = true
                }
              }

              ControlTile {
                tileWidth: (parent.width - Style.space(12)) / 3
                iconText: "󰩭"
                label: "Region"
                compact: true

                Process { id: actRegion; command: ["omarchy-capture-screenshot"] }
                onClicked: {
                  root.close()
                  actRegion.running = true
                }
              }

              ControlTile {
                tileWidth: (parent.width - Style.space(12)) / 3
                iconText: "󰊓"
                label: "OCR"
                compact: true

                Process { id: actOcr; command: ["omarchy-capture-text"] }
                onClicked: {
                  root.close()
                  actOcr.running = true
                }
              }
            }
          }
        }
      }
    }
  }
}
