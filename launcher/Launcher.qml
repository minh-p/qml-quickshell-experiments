import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

WrapperMouseArea {
    PanelWindow {
        id: launcher
        implicitWidth: Math.max(800, screen.width * 0.25)
        implicitHeight: 400
        color: "transparent"
        BackgroundEffect.blurRegion: Region {
            item: launcher.contentItem
            topRightRadius: 15
            topLeftRadius: 15
            bottomLeftRadius: 15
            bottomRightRadius: 15
        }
        Rectangle {
            id: launcher_frame
            anchors.fill: parent
            radius: 10
            color: "#60000000"
            border.color: "black"
            border.width: 0
            SearchField {
                y: 10
                implicitWidth: launcher_frame.width / 2
                implicitHeight: 35
                anchors.horizontalCenter: parent.horizontalCenter
                palette.text: "#ffffff"
                text: "Search..."
                clearIndicator.indicator: Shape {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    id: clearIcon
                    implicitWidth: 18
                    implicitHeight: 18

                    property color iconColor: "#cdd6f4"
                    property real lineWidth: 2

                    ShapePath {
                        strokeColor: clearIcon.iconColor
                        strokeWidth: clearIcon.lineWidth
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathMove { x: 4;  y: 4 }
                        PathLine { x: 14; y: 14 }

                        PathMove { x: 14; y: 4 }
                        PathLine { x: 4;  y: 14 }
                    }
                }
                searchIndicator.indicator: Shape {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    id: searchIcon

                    implicitWidth: 20
                    implicitHeight: 20

                    property color iconColor: "#cdd6f4"
                    property real lineWidth: 2

                    ShapePath {
                        strokeColor: searchIcon.iconColor
                        strokeWidth: searchIcon.lineWidth
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: 5
                            centerY: 8
                            radiusX: 5
                            radiusY: 5
                            startAngle: 0
                            sweepAngle: 360
                        }

                        PathMove {
                            x: 8.5
                            y: 11.5
                        }

                        PathLine {
                            x: 13
                            y: 17
                        }
                    }                   
                }
                background: Rectangle {
                    color: "transparent"
                    anchors.fill: parent
                }
            }
        }
    }
}
