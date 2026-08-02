pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property string time: {
        Qt.formatDateTime(clock.date, "MMM dd hh:mm AP")
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
