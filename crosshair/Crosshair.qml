import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Required to appear above fullscreen windows.
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "crosshair"

    focusable: false
    exclusionMode: ExclusionMode.Ignore

    // Make the overlay click-through.
    mask: Region {
        width: 0
        height: 0
    }

    Item {
        anchors.centerIn: parent

        property int size: 24
        property int thickness: 2
        property int gap: 5
        property color crosshairColor: "white"

        // Left arm
        Rectangle {
            width: parent.size / 2 - parent.gap
            height: parent.thickness
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: parent.gap
            anchors.verticalCenter: parent.verticalCenter
            color: parent.crosshairColor
        }

        // Right arm
        Rectangle {
            width: parent.size / 2 - parent.gap
            height: parent.thickness
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: parent.gap
            anchors.verticalCenter: parent.verticalCenter
            color: parent.crosshairColor
        }

        // Top arm
        Rectangle {
            width: parent.thickness
            height: parent.size / 2 - parent.gap
            anchors.bottom: parent.verticalCenter
            anchors.bottomMargin: parent.gap
            anchors.horizontalCenter: parent.horizontalCenter
            color: parent.crosshairColor
        }

        // Bottom arm
        Rectangle {
            width: parent.thickness
            height: parent.size / 2 - parent.gap
            anchors.top: parent.verticalCenter
            anchors.topMargin: parent.gap
            anchors.horizontalCenter: parent.horizontalCenter
            color: parent.crosshairColor
        }

        // Optional center dot
        Rectangle {
            width: 2
            height: 2
            radius: 1
            anchors.centerIn: parent
            color: parent.crosshairColor
        }
    }
}
