import QtQuick

Rectangle {
    color: "transparent"
    border.color: "white"
    border.width: 1
    radius: 4

    implicitWidth: clockLabel.implicitWidth + 16
    implicitHeight: clockLabel.implicitHeight + 8

    Text {
	id: clockLabel
	text: Time.time
	color: "white"
	font.weight: Font.Medium
	font.family: "DejaVu Sans Mono"
	anchors.centerIn: parent
    }
}
