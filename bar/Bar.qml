import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

import "clock"

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
            ClockWidget {
                anchors.centerIn: parent
            }
        }
    }
    IpcHandler {
        target: "bar"
        function toggleBar(): void {bar.barOn = !bar.barOn}
    }
}
