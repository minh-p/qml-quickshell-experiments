import QtQuick
import Quickshell.Services.Pipewire

Text {
    PwObjectTracker {
	objects: [Pipewire.defaultAudioSink]
    }
    text: {
	if (!Pipewire.ready) {
	    return "Pipewiring..."
	}
	if (!Pipewire.defaultAudioSink.ready) {
	    return "Binding Default..."
        }

	return "🔊" + Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%"
    }
    color: "white"
    font.family: "DejaVu Sans Mono"
    font.weight: Font.Medium
}
