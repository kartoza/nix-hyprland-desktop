import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080

    // Kartoza theme colors matching hyprlock
    property color primaryBlue: "#569FC6"
    property color accentOrange: "#DF9E2F"
    property color darkBg: "#162127"
    property color lightText: "#E6F7F6"
    property color errorRed: "#D32F2F"

    // Background image with blur effect
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "/etc/xdg/backgrounds/kartoza-wallpaper.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true

        // Dimming overlay to match hyprlock brightness
        Rectangle {
            anchors.fill: parent
            color: "#0D1A1F"
            opacity: 0.2
        }
    }

    // Blur effect on background
    FastBlur {
        anchors.fill: backgroundImage
        source: backgroundImage
        radius: 48
    }

    // Main content container
    Item {
        anchors.fill: parent

        // Clock display (large time)
        Text {
            id: timeLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.25
            font.pixelSize: 120
            font.family: "Nunito"
            font.bold: true
            color: lightText
            text: Qt.formatTime(timeTimer.currentTime, "hh:mm")

            Timer {
                id: timeTimer
                interval: 1000
                repeat: true
                running: true
                property var currentTime: new Date()
                onTriggered: {
                    currentTime = new Date()
                }
            }
        }

        // Date display
        Text {
            id: dateLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: timeLabel.bottom
            anchors.topMargin: 20
            font.pixelSize: 24
            font.family: "Nunito"
            color: lightText
            text: Qt.formatDate(timeTimer.currentTime, "dddd, MMMM d")
        }

        // Login container
        Item {
            id: loginContainer
            anchors.centerIn: parent
            width: 400
            height: 300

            // User label
            Text {
                id: userLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: passwordContainer.top
                anchors.bottomMargin: 40
                font.pixelSize: 28
                font.family: "Nunito"
                color: lightText
                text: userModel.lastUser
            }

            // Password input container
            Rectangle {
                id: passwordContainer
                anchors.centerIn: parent
                width: 300
                height: 60
                radius: 10
                color: Qt.rgba(0.086, 0.129, 0.153, 0.8)
                border.width: 3
                border.color: passwordInput.activeFocus ? primaryBlue : primaryBlue

                TextField {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 10
                    font.pixelSize: 16
                    font.family: "Nunito"
                    color: lightText
                    echoMode: TextInput.Password
                    placeholderText: "Enter Password..."
                    placeholderTextColor: Qt.rgba(0.902, 0.969, 0.965, 0.5)
                    background: Rectangle {
                        color: "transparent"
                    }
                    focus: true

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            loginButton.clicked()
                        }
                    }
                }
            }

            // Error message
            Text {
                id: errorMessage
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: passwordContainer.bottom
                anchors.topMargin: 20
                font.pixelSize: 14
                font.family: "Nunito"
                font.italic: true
                color: errorRed
                visible: false
            }

            // Login button (hidden, triggered by Enter key)
            Button {
                id: loginButton
                visible: false
                onClicked: {
                    sddm.login(userModel.lastUser, passwordInput.text, sessionModel.lastIndex)
                }
            }

            // Keyboard layout indicator
            Text {
                id: layoutIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: passwordContainer.bottom
                anchors.topMargin: 80
                font.pixelSize: 20
                font.family: "Nunito"
                color: lightText
                text: keyboard.layouts[keyboard.currentLayout]
            }
        }

        // Session selector (bottom left)
        ComboBox {
            id: sessionSelect
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 30
            width: 200
            model: sessionModel
            currentIndex: sessionModel.lastIndex
            textRole: "name"

            delegate: ItemDelegate {
                width: sessionSelect.width
                text: model.name
                highlighted: sessionSelect.highlightedIndex === index
            }

            background: Rectangle {
                color: Qt.rgba(0.086, 0.129, 0.153, 0.8)
                radius: 5
                border.color: primaryBlue
                border.width: 2
            }

            contentItem: Text {
                text: sessionSelect.displayText
                font.pixelSize: 14
                font.family: "Nunito"
                color: lightText
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
        }

        // Power buttons (bottom right)
        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 30
            spacing: 20

            // Suspend button
            Rectangle {
                width: 50
                height: 50
                radius: 25
                color: Qt.rgba(0.086, 0.129, 0.153, 0.8)
                border.color: primaryBlue
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "⏾"
                    font.pixelSize: 24
                    color: lightText
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.suspend()
                }
            }

            // Reboot button
            Rectangle {
                width: 50
                height: 50
                radius: 25
                color: Qt.rgba(0.086, 0.129, 0.153, 0.8)
                border.color: primaryBlue
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "⟳"
                    font.pixelSize: 24
                    color: lightText
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.reboot()
                }
            }

            // Shutdown button
            Rectangle {
                width: 50
                height: 50
                radius: 25
                color: Qt.rgba(0.086, 0.129, 0.153, 0.8)
                border.color: primaryBlue
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "⏻"
                    font.pixelSize: 24
                    color: lightText
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.powerOff()
                }
            }
        }
    }

    // Handle login failure
    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Login failed. Please try again."
            errorMessage.visible = true
            passwordInput.text = ""
            passwordInput.focus = true
            passwordContainer.border.color = errorRed

            // Reset error after 3 seconds
            errorTimer.start()
        }

        function onLoginSucceeded() {
            errorMessage.visible = false
        }
    }

    Timer {
        id: errorTimer
        interval: 3000
        onTriggered: {
            errorMessage.visible = false
            passwordContainer.border.color = primaryBlue
        }
    }

    Component.onCompleted: {
        passwordInput.forceActiveFocus()
    }
}
