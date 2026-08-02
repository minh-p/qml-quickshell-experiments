import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: root

    property bool launcherOpen: true
    property string query: searchField.text.trim().toLowerCase()
    property int selectedIndex: 0
    property var applications: DesktopEntries.applications.values
        .filter(function(app) {
            return app && !app.noDisplay && app.name.length > 0;
        })
        .filter(function(app) {
            return root.matchesQuery(app);
        })
        .sort(function(a, b) {
            var scoreDiff = root.matchScore(b) - root.matchScore(a);
            if (scoreDiff !== 0)
                return scoreDiff;

            return a.name.localeCompare(b.name);
        })

    function matchesQuery(app) {
        if (query.length === 0)
            return true;

        return searchableText(app).indexOf(query) !== -1;
    }

    function searchableText(app) {
        return [
            app.name,
            app.genericName,
            app.comment,
            app.execString,
            app.categories.join(" "),
            app.keywords.join(" ")
        ].join(" ").toLowerCase();
    }

    function matchScore(app) {
        if (query.length === 0)
            return 0;

        var name = app.name.toLowerCase();
        var genericName = app.genericName.toLowerCase();
        var exec = app.execString.toLowerCase();

        if (name === query)
            return 100;
        if (name.indexOf(query) === 0)
            return 80;
        if (genericName.indexOf(query) === 0)
            return 60;
        if (name.indexOf(query) !== -1)
            return 40;
        if (app.keywords.join(" ").toLowerCase().indexOf(query) !== -1)
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
        searchField.forceActiveFocus();
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

    onApplicationsChanged: clampSelection()

    IpcHandler {
        target: "launcher"

        function show(): void { root.show(); }
        function hide(): void { root.hide(); }
        function toggle(): void { root.toggle(); }
    }

    PanelWindow {
        id: launcher

        visible: root.launcherOpen
        implicitWidth: Math.min(Math.max(720, screen.width * 0.34), screen.width - 48)
        implicitHeight: Math.min(560, screen.height - 96)
        color: "transparent"

        BackgroundEffect.blurRegion: Region {
            item: launcher.contentItem
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
                        root.selectedIndex = 0;
                        root.clampSelection();
                    }

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Down) {
                            root.selectedIndex = Math.min(root.selectedIndex + 1, root.applications.length - 1);
                            root.clampSelection();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                            root.clampSelection();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launchSelected();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            root.hide();
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
                    model: root.applications
                    currentIndex: root.selectedIndex
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
                        onEntered: root.selectedIndex = index
                        onClicked: root.launchApp(modelData)

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: index === root.selectedIndex ? "#2f6aa6ff" : rowMouse.containsMouse ? "#18ffffff" : "transparent"
                            border.color: index === root.selectedIndex ? "#806aa6ff" : "transparent"
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
                        text: root.query.length > 0 ? "No matching applications" : "No applications found"
                        color: "#b8c0d8"
                        font.pixelSize: 15
                        visible: results.count === 0
                    }
                }
            }
        }
    }
}
