import QtQuick
import qs.Commons
import qs.Ui

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
  height: compact ? Style.space(48) : Style.space(56)

  BorderSurface {
    id: bg
    anchors.fill: parent
    radius: Style.cornerRadius
    color: root.active
      ? Util.alpha(Color.accent, 0.16)
      : (mouse.containsMouse ? Util.alpha(Color.foreground, 0.08) : Util.alpha(Color.foreground, 0.04))
    borderSpec: Border.surfaceSpec(
      "control",
      root.active ? "selected" : (mouse.containsMouse ? "hover" : "normal"),
      root.active ? Color.accent : Util.alpha(Color.foreground, mouse.containsMouse ? 0.22 : 0.12),
      1
    )

    Behavior on color { ColorAnimation { duration: 150 } }

    Item {
      anchors.fill: parent
      anchors.margins: root.compact ? Style.space(6) : Style.space(8)

      // Icon Badge
      Rectangle {
        id: iconBadge
        width: root.compact ? Style.space(26) : Style.space(34)
        height: width
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        color: root.active
          ? Color.accent
          : Util.alpha(Color.foreground, mouse.containsMouse ? 0.10 : 0.06)

        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
          anchors.centerIn: parent
          text: root.iconText
          color: root.active ? Color.background : Color.foreground
          font.family: Style.font.family
          font.pixelSize: root.compact ? Style.font.body : Style.font.title

          Behavior on color { ColorAnimation { duration: 150 } }
        }
      }

      // Labels
      Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: iconBadge.right
        anchors.leftMargin: root.compact ? Style.space(6) : Style.space(8)
        anchors.right: parent.right
        spacing: 1

        Text {
          text: root.label
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: root.compact ? Style.font.caption : Style.font.body
          font.bold: !root.compact
          elide: Text.ElideRight
          width: parent.width
        }

        Text {
          visible: !root.compact && root.subtitle !== ""
          text: root.subtitle
          color: root.active ? Color.accent : Qt.darker(Color.foreground, 1.4)
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: root.active
          elide: Text.ElideRight
          width: parent.width
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
