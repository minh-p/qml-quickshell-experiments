import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu

Item {
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter

        color: "transparent"
        border.color: "white"
        border.width: 1
        radius: 4

        implicitWidth: trayRow.implicitWidth + 16
        implicitHeight: trayRow.implicitHeight + 8

        Row {
            id: trayRow
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: SystemTray.items

                delegate: Rectangle {
                    width: 24
                    height: 22
                    color: "transparent"

                    Image {
                        source: modelData.icon
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                    }

                    QsMenuOpener {
                        id: menuOpener
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton && modelData.menu) {
                                menuOpener.menu = modelData.menu
                                const pos = mapToItem(null, mouse.x, mouse.y)
                                modelData.display(bar_monitor, pos.x, pos.y)
                            } else {
                                modelData.activate()
                            }
                        }
                    }
                }
            }
        }
    }
}
