import QtQuick
import QtQuick.Controls
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

    // Background image with dimming overlay
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
            opacity: 0.4
        }
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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 50
            width: 400
            height: 350

            property int selectedUserIndex: userModel.lastIndex
            property string selectedUsername: userModel.data(userModel.index(selectedUserIndex, 0), 257) // DisplayRole = 257

            // User selector container
            Rectangle {
                id: userSelector
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: passwordContainer.top
                anchors.bottomMargin: 30
                width: 300
                height: 50
                radius: 10
                color: Qt.rgba(0.086, 0.129, 0.153, 0.8)
                border.width: 2
                border.color: usernameInput.activeFocus ? accentOrange : primaryBlue

                Row {
                    anchors.fill: parent
                    anchors.margins: 5

                    // Previous user button
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 5
                        color: prevUserArea.containsMouse ? Qt.rgba(0.337, 0.624, 0.776, 0.3) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "◀"
                            font.pixelSize: 20
                            color: userModel.count > 1 ? lightText : Qt.rgba(0.902, 0.969, 0.965, 0.3)
                        }

                        MouseArea {
                            id: prevUserArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: userModel.count > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (userModel.count > 1) {
                                    loginContainer.selectedUserIndex = (loginContainer.selectedUserIndex - 1 + userModel.count) % userModel.count
                                    loginContainer.selectedUsername = userModel.data(userModel.index(loginContainer.selectedUserIndex, 0), 257)
                                    usernameInput.text = loginContainer.selectedUsername
                                    passwordInput.text = ""
                                    passwordInput.forceActiveFocus()
                                }
                            }
                        }
                    }

                    // Username input field (editable)
                    Item {
                        width: parent.width - 80
                        height: 40

                        TextField {
                            id: usernameInput
                            anchors.fill: parent
                            anchors.margins: 2
                            text: loginContainer.selectedUsername
                            font.pixelSize: 20
                            font.family: "Nunito"
                            font.bold: true
                            color: lightText
                            horizontalAlignment: Text.AlignHCenter
                            placeholderText: "Username"
                            placeholderTextColor: Qt.rgba(0.902, 0.969, 0.965, 0.5)
                            background: Rectangle {
                                color: "transparent"
                            }

                            onTextChanged: {
                                loginContainer.selectedUsername = text
                            }

                            Keys.onPressed: {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    passwordInput.forceActiveFocus()
                                } else if (event.key === Qt.Key_Tab) {
                                    passwordInput.forceActiveFocus()
                                    event.accepted = true
                                }
                            }
                        }
                    }

                    // Next user button
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 5
                        color: nextUserArea.containsMouse ? Qt.rgba(0.337, 0.624, 0.776, 0.3) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            font.pixelSize: 20
                            color: userModel.count > 1 ? lightText : Qt.rgba(0.902, 0.969, 0.965, 0.3)
                        }

                        MouseArea {
                            id: nextUserArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: userModel.count > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (userModel.count > 1) {
                                    loginContainer.selectedUserIndex = (loginContainer.selectedUserIndex + 1) % userModel.count
                                    loginContainer.selectedUsername = userModel.data(userModel.index(loginContainer.selectedUserIndex, 0), 257)
                                    usernameInput.text = loginContainer.selectedUsername
                                    passwordInput.text = ""
                                    passwordInput.forceActiveFocus()
                                }
                            }
                        }
                    }
                }
            }

            // User count indicator (shows dots for multiple users)
            Row {
                id: userIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: userSelector.top
                anchors.bottomMargin: 10
                spacing: 8
                visible: userModel.count > 1

                Repeater {
                    model: userModel.count
                    Rectangle {
                        width: index === loginContainer.selectedUserIndex ? 12 : 8
                        height: index === loginContainer.selectedUserIndex ? 12 : 8
                        radius: width / 2
                        color: index === loginContainer.selectedUserIndex ? accentOrange : Qt.rgba(0.902, 0.969, 0.965, 0.5)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
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
                    sddm.login(loginContainer.selectedUsername, passwordInput.text, sessionSelect.currentIndex)
                }
            }

        }

        // Bottom center: Keyboard layout indicator and Caps Lock status
        Row {
            id: bottomIndicators
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            spacing: 20

            // Caps Lock indicator
            Rectangle {
                id: capsLockIndicator
                width: 100
                height: 40
                radius: 5
                color: keyboard.capsLock ? Qt.rgba(0.875, 0.620, 0.184, 0.9) : Qt.rgba(0.086, 0.129, 0.153, 0.8)
                border.color: keyboard.capsLock ? accentOrange : primaryBlue
                border.width: 2

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "⇪"
                        font.pixelSize: 16
                        color: keyboard.capsLock ? darkBg : lightText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "CAPS"
                        font.pixelSize: 14
                        font.family: "Nunito"
                        font.bold: keyboard.capsLock
                        color: keyboard.capsLock ? darkBg : lightText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Keyboard layout selector
            Rectangle {
                id: layoutSelector
                width: 80
                height: 40
                radius: 5
                color: layoutMouseArea.containsMouse ? Qt.rgba(0.337, 0.624, 0.776, 0.5) : Qt.rgba(0.086, 0.129, 0.153, 0.8)
                border.color: primaryBlue
                border.width: 2

                // Function to get display name for layout
                function getLayoutDisplayName(layout) {
                    if (!layout) return "??"
                    var l = layout.toString().toLowerCase()
                    // Common layout mappings
                    if (l === "us" || l.indexOf("english") !== -1) return "EN"
                    if (l === "pt" || l.indexOf("portuguese") !== -1) return "PT"
                    if (l === "de" || l.indexOf("german") !== -1) return "DE"
                    if (l === "fr" || l.indexOf("french") !== -1) return "FR"
                    if (l === "es" || l.indexOf("spanish") !== -1) return "ES"
                    if (l === "it" || l.indexOf("italian") !== -1) return "IT"
                    if (l === "ru" || l.indexOf("russian") !== -1) return "RU"
                    if (l === "uk" || l.indexOf("ukrainian") !== -1) return "UA"
                    if (l === "gb" || l === "en-gb") return "GB"
                    // Return uppercase first 2 chars as fallback
                    return layout.toString().substring(0, 2).toUpperCase()
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "⌨"
                        font.pixelSize: 16
                        color: lightText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: keyboard.layouts.length > 0 ? layoutSelector.getLayoutDisplayName(keyboard.layouts[keyboard.currentLayout]) : "??"
                        font.pixelSize: 14
                        font.family: "Nunito"
                        font.bold: true
                        color: lightText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: layoutMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: keyboard.layouts.length > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (keyboard.layouts.length > 1) {
                            keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
                        }
                    }
                }

                // Tooltip showing all available layouts
                ToolTip {
                    visible: layoutMouseArea.containsMouse && keyboard.layouts.length > 1
                    text: "Click to switch layout\nAvailable: " + keyboard.layouts.join(", ")
                    delay: 500
                }
            }
        }

        // Session selector (bottom left) - simple cycling button
        Rectangle {
            id: sessionSelect
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 30
            width: 200
            height: 40
            color: Qt.rgba(0.086, 0.129, 0.153, 0.8)
            radius: 5
            border.color: primaryBlue
            border.width: 2

            property int currentIndex: sessionModel.lastIndex

            // Function to get a clean session display name
            function getSessionDisplayName(fullName) {
                if (!fullName) return "Unknown"
                // Extract just the session type name from paths like "/nix/store/xxx-wayland-sessions/share/wayland-sessions"
                // or simple names like "Hyprland" or "hyprland.desktop"
                var name = fullName.toString()

                // Check for common session types in the path/name
                var lowerName = name.toLowerCase()
                if (lowerName.indexOf("hyprland") !== -1) return "Hyprland"
                if (lowerName.indexOf("sway") !== -1) return "Sway"
                if (lowerName.indexOf("plasma") !== -1) return "Plasma"
                if (lowerName.indexOf("gnome") !== -1) return "GNOME"
                if (lowerName.indexOf("kde") !== -1) return "KDE"
                if (lowerName.indexOf("xfce") !== -1) return "XFCE"
                if (lowerName.indexOf("wayland") !== -1) return "Wayland"
                if (lowerName.indexOf("x11") !== -1) return "X11"

                // If it's a path, try to extract just the filename
                if (name.indexOf("/") !== -1) {
                    var parts = name.split("/")
                    name = parts[parts.length - 1]
                }
                // Remove .desktop extension if present
                if (name.endsWith(".desktop")) {
                    name = name.slice(0, -8)
                }
                // Capitalize first letter
                if (name.length > 0) {
                    return name.charAt(0).toUpperCase() + name.slice(1)
                }
                return name
            }

            Text {
                anchors.centerIn: parent
                text: sessionSelect.getSessionDisplayName(sessionModel.data(sessionModel.index(sessionSelect.currentIndex, 0), 257))
                font.pixelSize: 14
                font.family: "Nunito"
                color: lightText
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // Cycle to next session
                    sessionSelect.currentIndex = (sessionSelect.currentIndex + 1) % sessionModel.rowCount()
                }
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
