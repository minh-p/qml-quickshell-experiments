import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: launcherController

    property bool launcherOpen: false
    property string query: ""
    property int selectedIndex: 0
    property var applications: []

    function lower(value) {
        return value ? String(value).toLowerCase() : "";
    }

    function listText(value) {
        if (!value)
            return "";

        if (typeof value.join === "function")
            return value.join(" ").toLowerCase();

        return String(value).toLowerCase();
    }

    function updateQuery(text) {
        query = lower(text).trim();
        selectedIndex = 0;
        refreshApplications();
    }

    function refreshApplications() {
        applications = (DesktopEntries.applications.values || [])
            .filter(function(app) {
                return app && !app.noDisplay && launcherController.lower(app.name).length > 0;
            })
            .filter(function(app) {
                return launcherController.matchesQuery(app);
            })
            .sort(function(a, b) {
                var scoreDiff = launcherController.matchScore(b) - launcherController.matchScore(a);
                if (scoreDiff !== 0)
                    return scoreDiff;

                return a.name.localeCompare(b.name);
            });

        clampSelection();
    }

    function matchesQuery(app) {
        if (query.length === 0)
            return true;

        return searchableText(app).indexOf(query) !== -1;
    }

    function searchableText(app) {
        return [
            lower(app.name),
            lower(app.genericName),
            lower(app.comment),
            lower(app.execString),
            listText(app.categories),
            listText(app.keywords)
        ].join(" ").toLowerCase();
    }

    function matchScore(app) {
        if (query.length === 0)
            return 0;

        var name = lower(app.name);
        var genericName = lower(app.genericName);
        var exec = lower(app.execString);
        var keywords = listText(app.keywords);

        if (name === query)
            return 100;
        if (name.indexOf(query) === 0)
            return 80;
        if (genericName.indexOf(query) === 0)
            return 60;
        if (name.indexOf(query) !== -1)
            return 40;
        if (keywords.indexOf(query) !== -1)
            return 30;
        if (exec.indexOf(query) !== -1)
            return 20;

        return 10;
    }

    function clampSelection() {
        if (applications.length === 0) {
            selectedIndex = -1;
            return;
        }

        if (selectedIndex < 0)
            selectedIndex = 0;
        if (selectedIndex >= applications.length)
            selectedIndex = applications.length - 1;

        results.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function launchApp(app) {
        if (!app)
            return;

        app.execute();
        hide();
    }

    function launchSelected() {
        if (selectedIndex >= 0 && selectedIndex < applications.length)
            launchApp(applications[selectedIndex]);
    }

    function show() {
        launcherOpen = true;
        Qt.callLater(function() { searchField.forceActiveFocus(); });
        clampSelection();
    }

    function hide() {
        launcherOpen = false;
        searchField.text = "";
        selectedIndex = 0;
    }

    function toggle() {
        if (launcherOpen)
            hide();
        else
            show();
    }

    Component.onCompleted: refreshApplications()

    Connections {
        target: DesktopEntries

        function onApplicationsChanged() {
            launcherController.refreshApplications();
        }
    }

    Connections {
        target: DesktopEntries.applications

        function onValuesChanged() {
            launcherController.refreshApplications();
        }
    }

    IpcHandler {
        target: "launcher"

        function show(): void { launcherController.show(); }
        function hide(): void { launcherController.hide(); }
        function toggle(): void { launcherController.toggle(); }
    }

    PanelWindow {
        id: launcherWindow

        visible: launcherController.launcherOpen
        implicitWidth: Math.min(Math.max(720, screen.width * 0.34), screen.width - 48)
        implicitHeight: Math.min(560, screen.height - 96)
        color: "transparent"
        WlrLayershell.keyboardFocus: launcherController.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        BackgroundEffect.blurRegion: Region {
            item: launcherWindow.contentItem
            topRightRadius: 15
            topLeftRadius: 15
            bottomLeftRadius: 15
            bottomRightRadius: 15
        }

        Rectangle {
            id: launcherFrame

            anchors.fill: parent
            radius: 10
            color: "#72000000"
            border.color: "#24ffffff"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                SearchField {
                    id: searchField

                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    focus: true
                    palette.text: "#ffffff"
                    font.pixelSize: 16
                    leftPadding: 38
                    rightPadding: 34

                    onTextChanged: {
                        launcherController.updateQuery(text);
                    }

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Down) {
                            launcherController.selectedIndex = Math.min(launcherController.selectedIndex + 1, launcherController.applications.length - 1);
                            launcherController.clampSelection();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            launcherController.selectedIndex = Math.max(launcherController.selectedIndex - 1, 0);
                            launcherController.clampSelection();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            launcherController.launchSelected();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            launcherController.hide();
                            event.accepted = true;
                        }
                    }

                    clearIndicator.indicator: Shape {
                        id: clearIcon

                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 18
                        implicitHeight: 18

                        property color iconColor: "#cdd6f4"
                        property real lineWidth: 2

                        ShapePath {
                            strokeColor: clearIcon.iconColor
                            strokeWidth: clearIcon.lineWidth
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap

                            PathMove { x: 4;  y: 4 }
                            PathLine { x: 14; y: 14 }

                            PathMove { x: 14; y: 4 }
                            PathLine { x: 4;  y: 14 }
                        }
                    }

                    searchIndicator.indicator: Shape {
                        id: searchIcon

                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 20
                        implicitHeight: 20

                        property color iconColor: "#cdd6f4"
                        property real lineWidth: 2

                        ShapePath {
                            strokeColor: searchIcon.iconColor
                            strokeWidth: searchIcon.lineWidth
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap

                            PathAngleArc {
                                centerX: 7
                                centerY: 8
                                radiusX: 5
                                radiusY: 5
                                startAngle: 0
                                sweepAngle: 360
                            }

                            PathMove { x: 10.5; y: 11.5 }
                            PathLine { x: 15; y: 17 }
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#22000000"
                        border.width: 1
                        border.color: searchField.activeFocus ? "#6aa6ff" : "#24ffffff"
                    }
                }

                ListView {
                    id: results

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: launcherController.applications
                    currentIndex: launcherController.selectedIndex
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: MouseArea {
                        id: rowMouse

                        required property var modelData
                        required property int index

                        width: results.width
                        height: 62
                        hoverEnabled: true
                        onEntered: launcherController.selectedIndex = index
                        onClicked: launcherController.launchApp(modelData)

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: index === launcherController.selectedIndex ? "#2f6aa6ff" : rowMouse.containsMouse ? "#18ffffff" : "transparent"
                            border.color: index === launcherController.selectedIndex ? "#806aa6ff" : "transparent"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                Item {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40

                                    IconImage {
                                        id: appIcon

                                        anchors.fill: parent
                                        source: modelData.icon.length > 0 ? Quickshell.iconPath(modelData.icon, true) : ""
                                        asynchronous: true
                                        mipmap: true
                                        visible: status === Image.Ready
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 8
                                        color: "#28ffffff"
                                        visible: appIcon.status !== Image.Ready

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.name.length > 0 ? modelData.name[0].toUpperCase() : "?"
                                            color: "#ffffff"
                                            font.pixelSize: 18
                                            font.bold: true
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        color: "#ffffff"
                                        font.pixelSize: 15
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.genericName.length > 0 ? modelData.genericName : modelData.comment
                                        color: "#b8c0d8"
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        visible: text.length > 0
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: launcherController.query.length > 0 ? "No matching applications" : "No applications found"
                        color: "#b8c0d8"
                        font.pixelSize: 15
                        visible: results.count === 0
                    }
                }
            }
        }
    }
}
