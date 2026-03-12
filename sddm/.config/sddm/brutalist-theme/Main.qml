import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    color: bg

    property string wallpaper: config.background || ""
    property color bg: "#1b1b1d"
    property color fg: config.foreground || "#d0cbc4"
    property color accent: config.accent || "#cc9b6a"
    property color surface: config.surface || "#272729"
    property color muted: config.muted || "#6e6a65"
    property color success: config.success || "#6a9955"
    property color failure: config.failure || "#a04040"
    property color warning: config.warning || "#bf7845"

    property color glass: Qt.rgba(0.106, 0.106, 0.114, 0.82)
    property color glassBorder: Qt.rgba(0.8, 0.608, 0.416, 0.15)
    property color fieldBg: Qt.rgba(0.15, 0.15, 0.16, 0.6)
    property color fieldBorder: Qt.rgba(1, 1, 1, 0.08)

    property string fontFamily: config.font || "JetBrainsMono Nerd Font"
    property int baseFontSize: config.fontSize ? Number(config.fontSize) : 13

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() {
            statusMsg.color = success
            statusMsg.text = textConstants.loginSucceeded
        }
        function onLoginFailed() {
            statusMsg.color = failure
            statusMsg.text = textConstants.loginFailed
            password.text = ""
            password.focus = true
            failAnim.start()
        }
        function onInformationMessage(message) {
            statusMsg.color = failure
            statusMsg.text = message
        }
    }

    // Wallpaper
    Image {
        id: wallpaperImg
        anchors.fill: parent
        source: wallpaper
        fillMode: Image.PreserveAspectCrop
        visible: wallpaper != ""
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.3)
        visible: wallpaper != ""
    }

    // ── Glass panel ──
    Item {
        id: panelContainer
        anchors.centerIn: parent
        width: 360
        height: panelContent.height + 64

        Rectangle {
            anchors.fill: parent
            radius: 2
            color: glass
            border.color: glassBorder
            border.width: 1
        }

        Column {
            id: panelContent
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 64
            spacing: 0

            // Clock
            Text {
                id: clock
                width: parent.width
                horizontalAlignment: Text.AlignLeft
                color: fg
                font.family: fontFamily
                font.pixelSize: baseFontSize + 10
                font.weight: Font.Light

                function updateTime() {
                    var d = new Date()
                    var h = ("0" + d.getHours()).slice(-2)
                    var m = ("0" + d.getMinutes()).slice(-2)
                    text = h + ":" + m
                }
            }

            // Date
            Text {
                id: dateText
                width: parent.width
                horizontalAlignment: Text.AlignLeft
                color: muted
                font.family: fontFamily
                font.pixelSize: baseFontSize - 1

                function updateDate() {
                    var d = new Date()
                    var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                    text = days[d.getDay()] + " " + months[d.getMonth()] + " " + d.getDate()
                }
            }

            Timer {
                interval: 30000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: { clock.updateTime(); dateText.updateDate() }
            }

            // Divider
            Item { width: 1; height: 20 }
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }
            Item { width: 1; height: 20 }

            // Username label
            Text {
                text: "user"
                color: muted
                font.family: fontFamily
                font.pixelSize: baseFontSize - 2
                font.weight: Font.DemiBold
                height: implicitHeight + 8
            }

            // Username field
            Rectangle {
                width: parent.width
                height: 38
                radius: 2
                color: fieldBg
                border.color: username.activeFocus ? accent : fieldBorder
                border.width: 1

                TextInput {
                    id: username
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    color: fg
                    font.family: fontFamily
                    font.pixelSize: baseFontSize
                    clip: true
                    selectionColor: accent
                    selectedTextColor: bg

                    KeyNavigation.tab: password
                    Keys.onPressed: function(event) {
                        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                            password.focus = true
                            event.accepted = true
                        }
                    }
                }
            }

            Item { width: 1; height: 16 }

            // Password label
            Text {
                text: "password"
                color: muted
                font.family: fontFamily
                font.pixelSize: baseFontSize - 2
                font.weight: Font.DemiBold
                height: implicitHeight + 8
            }

            // Password field
            Rectangle {
                width: parent.width
                height: 38
                radius: 2
                color: fieldBg
                border.color: password.activeFocus ? accent : fieldBorder
                border.width: 1

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: Text.AlignVCenter
                    color: fg
                    font.family: fontFamily
                    font.pixelSize: baseFontSize
                    echoMode: TextInput.Password
                    clip: true
                    selectionColor: accent
                    selectedTextColor: bg

                    KeyNavigation.tab: loginBtn
                    Keys.onPressed: function(event) {
                        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                            sddm.login(username.text, password.text, sessionSelect.index)
                            event.accepted = true
                        }
                    }
                }
            }

            Item { width: 1; height: 20 }

            // Login button
            FocusScope {
                id: loginBtn
                width: parent.width
                height: 38

                KeyNavigation.tab: username

                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: loginArea.containsMouse || loginBtn.activeFocus
                           ? accent : Qt.rgba(0.8, 0.608, 0.416, 0.12)
                    border.color: loginArea.containsMouse || loginBtn.activeFocus
                                  ? accent : Qt.rgba(0.8, 0.608, 0.416, 0.3)
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "login"
                        color: loginArea.containsMouse || loginBtn.activeFocus ? bg : fg
                        font.family: fontFamily
                        font.pixelSize: baseFontSize
                        font.weight: Font.DemiBold

                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: loginArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.login(username.text, password.text, sessionSelect.index)
                    }
                }

                Keys.onPressed: function(event) {
                    if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
                        sddm.login(username.text, password.text, sessionSelect.index)
                        event.accepted = true
                    }
                }
            }

            Item { width: 1; height: 10 }

            // Status message
            Text {
                id: statusMsg
                width: parent.width
                height: 18
                text: ""
                color: failure
                font.family: fontFamily
                font.pixelSize: baseFontSize - 2
                horizontalAlignment: Text.AlignHCenter

                SequentialAnimation on opacity {
                    id: failAnim
                    running: false
                    NumberAnimation { to: 1; duration: 100 }
                    PauseAnimation { duration: 2000 }
                    NumberAnimation { to: 0; duration: 500 }
                }
            }
        }
    }

    // ── Top bar — centered: session | reboot | shutdown ──
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 36
        color: Qt.rgba(0, 0, 0, 0.45)

        Row {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "session"
                color: muted
                font.family: fontFamily
                font.pixelSize: baseFontSize - 2
                anchors.verticalCenter: parent.verticalCenter
            }

            ComboBox {
                id: sessionSelect
                model: sessionModel
                index: sessionModel.lastIndex
                width: 160
                height: 24
                color: "transparent"
                borderColor: Qt.rgba(1, 1, 1, 0.1)
                focusColor: accent
                hoverColor: accent
                textColor: fg
                menuColor: surface
                arrowColor: surface
                font.family: fontFamily
                font.pixelSize: baseFontSize - 2
            }

            Rectangle {
                width: 1; height: 12
                color: Qt.rgba(1, 1, 1, 0.1)
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "reboot"
                color: rebootArea.containsMouse ? warning : muted
                font.family: fontFamily
                font.pixelSize: baseFontSize - 2
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                    id: rebootArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.reboot()
                }
            }

            Rectangle {
                width: 1; height: 12
                color: Qt.rgba(1, 1, 1, 0.1)
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "shutdown"
                color: shutdownArea.containsMouse ? failure : muted
                font.family: fontFamily
                font.pixelSize: baseFontSize - 2
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                    id: shutdownArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.powerOff()
                }
            }
        }
    }

    Component.onCompleted: {
        if (username.text == "")
            username.focus = true
        else
            password.focus = true
    }
}
