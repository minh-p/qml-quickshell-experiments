import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.DBusMenu

Item {
    anchors.fill: parent.fill
    Row {
	anchors.verticalCenter: parent.verticalCenter
	spacing: 10
	Repeater {
	    model: SystemTray.items
	    delegate: Rectangle {
		width: 24
		height: 24
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
