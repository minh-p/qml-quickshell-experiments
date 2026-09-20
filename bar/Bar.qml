import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "clock"
import "battery"
import "tray"
import "volume"

Scope {
    id: bar
    property bool barOn: true
    Variants {
        model: Quickshell.screens;
        PanelWindow {
            id: bar_monitor
            color: "transparent"
            BackgroundEffect.blurRegion: Region { item: bar_monitor.contentItem }
            visible: bar.barOn
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 30

	    VolumeWidget {
		id: volumeWidget
		anchors.right: clockWidget.left
		anchors.verticalCenter: parent.verticalCenter
		anchors.rightMargin: 10
	    }
	    
	    ClockWidget {
		id: clockWidget
		anchors.centerIn: parent
	    }

	    BatteryWidget {
		id: batteryWidget
		anchors.left: clockWidget.right
		anchors.verticalCenter: parent.verticalCenter
		anchors.leftMargin: 10
	    }
	    SystemTray {
		anchors.left: batteryWidget.right
		anchors.verticalCenter: parent.verticalCenter
		anchors.leftMargin: 10
	    }
        }
    }
    IpcHandler {
        target: "bar"
        function toggleBar(): void {bar.barOn = !bar.barOn}
    }
}
