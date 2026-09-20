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
	const sink = Pipewire.defaultAudioSink
	if (!sink.ready) {
	    return "Binding Default..."
        }

	if (sink.audio.muted) {
	    return "🔇"
	}

	return "🔊" + Math.round(sink.audio.volume * 100) + "%"
    }
    color: "white"
    font.family: "DejaVu Sans Mono"
    font.weight: Font.Medium

    MouseArea {
	anchors.fill: parent

	onClicked: {
	    const sink = Pipewire.defaultAudioSink
	    if (sink && sink.ready) {
		sink.audio.muted = !sink.audio.muted
	    }
	}
	
        onWheel: (wheel) => {
            const sink = Pipewire.defaultAudioSink

            if (!sink || !sink.ready) {
                return
            }

            const step = 0.05

            if (wheel.angleDelta.y > 0) {
                sink.audio.volume = Math.min(
                    sink.audio.volume + step,
                    1.0
                )
            } else if (wheel.angleDelta.y < 0) {
                sink.audio.volume = Math.max(
                    sink.audio.volume - step,
                    0.0
                )
            }
        }
    }
}
