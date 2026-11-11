import QtQuick
import qs.Commons

// A macOS-style toggle tile: icon + label + subtitle with active accent state.
// Click the whole tile to toggle. Set `compact: true` for action-only tiles
// (screenshot, lock, etc.) that don't have an on/off state.
Item {
  id: root

  property real tileWidth: Style.space(150)
  property string iconText: ""
  property string label: ""
  property string subtitle: ""
  property bool active: false
  property bool compact: false

  signal clicked()

  width: tileWidth
  height: compact ? Style.space(60) : Style.space(56)

  BorderSurface {
    id: bg
    anchors.fill: parent
    radius: Style.cornerRadius
    color: root.active
      ? Style.selectedFillFor(Color.foreground, Color.accent)
      : Style.normalFillFor(Color.foreground, Color.accent)
    borderSpec: Border.controlSpec(
      root.active ? "selected" : (mouse.containsMouse ? "hover-cursor" : "normal"),
      Color.foreground, Color.accent
    )

    Behavior on color { ColorAnimation { duration: 100 } }

    Row {
      anchors.fill: parent
      anchors.margins: Style.spacing.md
      spacing: Style.spacing.md

      Text {
        text: root.iconText
        color: root.active ? Style.selectedStateColor(Color.foreground, Color.accent) : Color.foreground
        font.family: Style.font.family
        font.pixelSize: root.compact ? Style.font.title : Style.font.icon
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color { ColorAnimation { duration: 100 } }
      }

      Column {
        visible: !root.compact || root.label !== ""
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
          text: root.label
          color: root.active ? Style.selectedStateColor(Color.foreground, Color.accent) : Color.foreground
          font.family: Style.font.family
          font.pixelSize: root.compact ? Style.font.caption : Style.font.body
          font.bold: !root.compact
          elide: Text.ElideRight
          width: root.tileWidth - Style.space(50)

          Behavior on color { ColorAnimation { duration: 100 } }
        }

        Text {
          visible: !root.compact && root.subtitle !== ""
          text: root.subtitle
          color: Qt.darker(Color.foreground, 1.5)
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          elide: Text.ElideRight
          width: root.tileWidth - Style.space(50)
        }
      }
    }

    MouseArea {
      id: mouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.clicked()
    }
  }
}
