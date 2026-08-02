import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

import "clock"

Scope {
    Variants {
        model: Quickshell.screens;
        PanelWindow {
            id: bar
            color: "transparent"
            BackgroundEffect.blurRegion: Region { item: bar.contentItem }
            visible: true
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
}
