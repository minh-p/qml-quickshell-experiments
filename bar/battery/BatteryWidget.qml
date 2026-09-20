import QtQuick
import Quickshell.Services.UPower

Text {
    text: UPower.displayDevice.ready
	? "BAT: " + UPower.displayDevice.percentage
	: "🔌AC"
    color: "white"
    font.weight: Font.Medium
    font.family: "DejaVu Sans Mono"
}
