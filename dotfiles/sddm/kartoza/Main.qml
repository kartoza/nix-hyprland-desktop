import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property string usernamePlaceholder: "Username"
    property string passwordPlaceholder: "Password"

    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Login failed! Please try again."
            errorMessage.visible = true
        }
    }

    // Background
    Rectangle {
        id: background
        anchors.fill: parent
        color: "#1a1a1a"

        Image {
            id: backgroundImage
            anchors.fill: parent
            source: "file:///etc/kartoza-wallpaper.png"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            
            // Add subtle overlay for better text visibility
            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.3
            }
        }
    }

    // Kartoza logo
    Image {
        id: logo
        source: "file:///etc/xdg/waybar/kartoza-logo-neon-bright.png"
        width: 200
        height: 80
        fillMode: Image.PreserveAspectFit
        smooth: true
        anchors {
            top: parent.top
            topMargin: 60
            horizontalCenter: parent.horizontalCenter
        }
    }

    // Login container
    Rectangle {
        id: loginContainer
        width: 400
        height: 350
        anchors.centerIn: parent
        color: "#2d2d2d"
        opacity: 0.9
        radius: 20

        // Drop shadow effect
        DropShadow {
            anchors.fill: loginContainer
            radius: 20
            samples: 41
            color: "#80000000"
            source: loginContainer
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            width: parent.width - 60

            Text {
                text: "Welcome to Kartoza"
                color: "#DF9E2F"
                font.pointSize: 18
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // Username field
            TextField {
                id: usernameField
                Layout.fillWidth: true
                placeholderText: usernamePlaceholder
                font.pointSize: 12
                color: "#ffffff"
                background: Rectangle {
                    color: "#404040"
                    radius: 8
                    border.color: usernameField.focus ? "#DF9E2F" : "#606060"
                    border.width: 2
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        passwordField.focus = true
                    }
                }
            }

            // Password field
            TextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: passwordPlaceholder
                echoMode: TextInput.Password
                font.pointSize: 12
                color: "#ffffff"
                background: Rectangle {
                    color: "#404040"
                    radius: 8
                    border.color: passwordField.focus ? "#DF9E2F" : "#606060"
                    border.width: 2
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        loginButton.clicked()
                    }
                }
            }

            // Session selector
            ComboBox {
                id: sessionComboBox
                Layout.fillWidth: true
                model: sessionModel
                currentIndex: sessionModel.lastIndex
                textRole: "name"
                font.pointSize: 10
                
                background: Rectangle {
                    color: "#404040"
                    radius: 8
                    border.color: "#606060"
                    border.width: 1
                }

                contentItem: Text {
                    text: sessionComboBox.displayText
                    font: sessionComboBox.font
                    color: "#ffffff"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }
            }

            // Error message
            Text {
                id: errorMessage
                Layout.fillWidth: true
                color: "#ff6b6b"
                font.pointSize: 10
                visible: false
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
            }

            // Login button
            Button {
                id: loginButton
                Layout.fillWidth: true
                text: "Login"
                font.pointSize: 12
                font.bold: true
                height: 50

                background: Rectangle {
                    color: loginButton.pressed ? "#bf8025" : "#DF9E2F"
                    radius: 8
                }

                contentItem: Text {
                    text: loginButton.text
                    font: loginButton.font
                    color: "#000000"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    errorMessage.visible = false
                    sddm.login(usernameField.text, passwordField.text, sessionComboBox.currentIndex)
                }
            }
        }
    }

    // Power options
    Row {
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 30
        }
        spacing: 15

        Button {
            text: "Reboot"
            width: 80
            height: 40
            background: Rectangle {
                color: parent.pressed ? "#404040" : "#2d2d2d"
                radius: 6
                opacity: 0.8
            }
            contentItem: Text {
                text: parent.text
                color: "#ffffff"
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: sddm.reboot()
        }

        Button {
            text: "Shutdown"
            width: 80
            height: 40
            background: Rectangle {
                color: parent.pressed ? "#404040" : "#2d2d2d"
                radius: 6
                opacity: 0.8
            }
            contentItem: Text {
                text: parent.text
                color: "#ffffff"
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: sddm.powerOff()
        }
    }

    // Clock
    Text {
        id: timeText
        anchors {
            bottom: parent.bottom
            left: parent.left
            margins: 30
        }
        color: "#ffffff"
        font.pointSize: 14
        font.bold: true

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                timeText.text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
            }
        }

        Component.onCompleted: {
            timeText.text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
        }
    }

    Text {
        id: dateText
        anchors {
            bottom: timeText.top
            left: parent.left
            margins: 30
            bottomMargin: 5
        }
        color: "#cccccc"
        font.pointSize: 12
        text: new Date().toLocaleDateString(Qt.locale(), "dddd, MMMM d, yyyy")
    }

    Component.onCompleted: {
        usernameField.focus = true
    }
}