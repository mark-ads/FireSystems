import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


Rectangle {
    id: panel
    width: 180
    height: 450
    color: "#eeeeee"
    radius: 2
    border.color: "#cccccc"
    property int activeIndex: 0
    signal screenSelected(int index)

    Rectangle {
        id: switchButtons
        width: 180
        height: 120
        color: "#ffffff"

        Rectangle {
            id: frontSwitch
            width: 90; height: 120
            color: "#ffffff"
            border.width: 1

            property int state: viewmodel.udp.frontState ?? -1
            property bool pressed: false

            enabled: state !== -1
            opacity: state === -1 ? 0.5 : 1.0

            MouseArea {
                x: 13
                y: 30
                z: 10
                width: 64
                height: 64
                enabled: frontSwitch.enabled
                onPressed: frontSwitch.pressed = true
                onReleased: {
                    frontSwitch.pressed = false
                    if (frontSwitch.state === 0) {
                        viewmodel.udp.forward_command("front", "turn_on")
                    }
                    else if (frontSwitch.state === 4 || frontSwitch.state === 5) {
                        viewmodel.udp.forward_command("front", "reboot")
                    }
                    else {
                        viewmodel.udp.forward_command("front", "turn_off")
                    }
                }
                onCanceled: frontSwitch.pressed = false
            }

            Image {
                id: frontSwitchOnIcon
                x: 13
                y: 30
                width: 64
                height: 64
                source: "images/on_icon.png"
                visible: frontSwitch.state >= -1 && frontSwitch.state <= 0
                scale: frontSwitch.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: frontSwitchOffIcon
                x: 13
                y: 30
                width: 64
                height: 64
                source: "images/off_icon.png"
                visible: frontSwitch.state >= 1 && frontSwitch.state <= 3
                scale: frontSwitch.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: frontSwitchRebootIcon
                x: 13
                y: 30
                width: 64
                height: 64
                source: "images/reboot_icon.png"
                visible: frontSwitch.state >= 4 && frontSwitch.state <= 5
                scale: frontSwitch.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
            }

            Text {
                anchors.bottom: parent.bottom
                width: parent.width; height: 24
                text: frontSwitch.state === -1 ? "НЕТ СВЯЗИ" :
                      frontSwitch.state === 0 ? "ВКЛ" :
                      frontSwitch.state === 5 ? "ПЕРЕЗАГР." : "ВЫКЛ"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14; font.bold: true
            }
        }


        Rectangle {
            id: backSwitch
            x: 90
            y: 0
            width: 90
            height: 120
            color: "#ffffff"
            border.width: 1

            property int state: viewmodel.udp.backState ?? -1
            property bool pressed: false

            enabled: state !== -1
            opacity: state === -1 ? 0.5 : 1.0

            MouseArea {
                x: 13
                y: 30
                z: 10
                width: 64
                height: 64
                enabled: backSwitch.enabled
                onPressed: backSwitch.pressed = true
                onReleased: {
                    backSwitch.pressed = false
                    if (backSwitch.state === 0) {
                        viewmodel.udp.forward_command("back", "turn_on")
                    }
                    else if (backSwitch.state === 4 || backSwitch.state === 5) {
                        viewmodel.udp.forward_command("back", "reboot")
                    }
                    else {
                        viewmodel.udp.forward_command("back", "turn_off")
                    }
                }
                onCanceled: backSwitch.pressed = false
            }

            Image {
                id: backSwitchOnIcon
                x: 13
                y: 30
                width: 64
                height: 64
                source: "images/on_icon.png"
                visible: backSwitch.state >= -1 && backSwitch.state <= 0
                scale: backSwitch.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: backSwitchOffIcon
                x: 13
                y: 30
                width: 64
                height: 64
                source: "images/off_icon.png"
                visible: backSwitch.state >= 1 && backSwitch.state <= 3
                scale: backSwitch.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: backSwitchRebootIcon
                x: 13
                y: 30
                width: 64
                height: 64
                source: "images/reboot_icon.png"
                visible: backSwitch.state >= 4 && backSwitch.state <= 5
                scale: backSwitch.pressed ? 0.9 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
            }

            Text {
                anchors.bottom: parent.bottom
                width: parent.width; height: 24
                text: backSwitch.state === -1 ? "НЕТ СВЯЗИ" :
                      backSwitch.state === 0 ? "ВКЛ" :
                      backSwitch.state === 5 ? "ПЕРЕЗАГР." : "ВЫКЛ"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14; font.bold: true
            }
        }
    }

    ColumnLayout {
        id: buttonsColumn
        x: 0
        y: 120
        spacing: 0

        function updateSelection(index) {
            activeIndex = index
            screenSelected(index)
        }



        TabButton {
            id: systemButton
            checkable: true
            checked: panel.activeIndex === 0
            Layout.preferredWidth: 180
            Layout.preferredHeight: 90
            onClicked: {
                if (panel.activeIndex !== 0) {
                    panel.activeIndex = 0
                    panel.screenSelected(0)
                } else {
                    systemMenu.open()
                }
            }

            background: Rectangle {
                color: systemButton.checked ? "#cccccc" : "#ffffff"
                border.color: "#888888"
            }

            contentItem: Text {
                text: 'Система\nKA-...'
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 12
                anchors.centerIn: parent
                color: "black"
            }
        }



        TabButton {
            id: termButton
            checkable: true
            checked: false
            Layout.preferredWidth: 180
            Layout.preferredHeight: 60



            background: Rectangle {
                color: termButton.checked ? "#cccccc" : "#ffffff"
                border.color: "#888888"
            }

            contentItem: Text {
                text: 'Термография\n(разработка)'
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 12
                anchors.centerIn: parent
                color: "black"
            }
        }



        TabButton {
            id: techButton
            checkable: true
            checked: panel.activeIndex === 1
            Layout.preferredWidth: 180
            Layout.preferredHeight: 60

            onClicked: {
                panel.activeIndex = 1
                panel.screenSelected(1)
            }

            background: Rectangle {
                color: techButton.checked ? "#cccccc" : "#ffffff"
                border.color: "#888888"
            }

            contentItem: Text {
                text: 'Технический\nэкран'
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 12
                anchors.centerIn: parent
                color: "black"
            }
        }



        TabButton {
            id: settingsButton
            checkable: true
            checked: panel.activeIndex === 2
            Layout.preferredWidth: 180
            Layout.preferredHeight: 60
            onClicked: {
                panel.activeIndex = 2
                panel.screenSelected(2)
            }

            background: Rectangle {
                color: settingsButton.checked ? "#cccccc" : "#ffffff"
                border.color: "#888888"
            }

            contentItem: Text {
                text: 'Настройки\nсистемы'
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 12
                anchors.centerIn: parent
                color: "black"
            }
        }



        TabButton {
            id: infoButton
            checkable: false
            checked: panel.activeIndex === 4
            Layout.preferredWidth: 180
            Layout.preferredHeight: 60
            onClicked: panel.updateSelection(4)

            background: Rectangle {
                color: infoButton.checked ? "#cccccc" : "#ffffff"
                border.color: "#888888"
            }

            contentItem: Text {
                text: 'ИНФО'
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 12
                anchors.centerIn: parent
                color: "black"
            }
        }
    }
}

