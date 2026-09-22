import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

FlexboxLayout {
    gap: 2
    Text {
	id: batteryIcon
	text: "🔌AC"
	visible: !UPower.displayDevice.ready

	color: "white"
	font.weight: Font.Medium
	font.family: "DejaVu Sans Mono"
    }
    Rectangle {
	color: "transparent"
	border.color: "white"
	border.width: 1
	radius: 3
	visible: UPower.displayDevice.ready
	
	implicitHeight: parent.implicitHeight
	implicitWidth: 10

	Rectangle {
	    implicitHeight: parent.implicitHeight * Math.round(UPower.displayDevice.percentage * 100) / 100
	    implicitWidth: 10
	    anchors.bottom: parent.bottom
	    radius: 3
	    color: {
		const level = Math.round(UPower.displayDevice.percentage * 100)
		if (level > 75) {
		    return "#f38ba8"
		}
		if (level > 50) {
		    return "#fab387"
		}
		if (level > 30) {
		    return "#f9e2af"
		}
		if (level > 15) {
		    return "#fab387"
		}
		return "#f38ba8"
	    }
	}
	Text {
	    id: batteryCharging
	    text: UPower.displayDevice.state === UPowerDeviceState.Charging ? "󱐋": "󰂭"
	    color: UPower.displayDevice.state === UPowerDeviceState.Charging ? "black": "purple"
	    anchors.centerIn: parent
	    font.pixelSize: UPower.displayDevice.state === UPowerDeviceState.Charging ? 12: 8
	    fontSizeMode: Text.Fit
	    minimumPixelSize: UPower.displayDevice.state === UPowerDeviceState.Charging ? 10: 6
	    visible: UPower.displayDevice.state !== UPowerDeviceState.Discharging
	}
    }
    Text {
	color: "white"
	font.weight: Font.Medium
	font.family: "DejaVu Sans Mono"
	visible: UPower.displayDevice.ready
	text: Math.round(UPower.displayDevice.percentage * 100) + "%"
    }
}
