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
            x: 0
            y: 0
            width: 90
            height: 120
            color: "#ffffff"
            border.width: 1
            Image {
                id: frontSwitchOnIcon
                x: 13
                y: 30
                source: "images/on_icon.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: frontSwitchText
                x: 0
                y: 96
                width: 90
                height: 24
                text: qsTr("ВКЛ")
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }

            Image {
                id: frontSwitchOffIcon
                x: 13
                y: 30
                source: "images/off_icon.png"
                fillMode: Image.PreserveAspectFit
                visible: false
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
            Image {
                id: backSwitchOnIcon
                x: 13
                y: 30
                source: "images/on_icon.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: backSwitchText
                x: 0
                y: 97
                width: 90
                height: 24
                text: qsTr("ВКЛ")
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }

            Image {
                id: backSwitchOffIcon
                x: 13
                y: 30
                source: "images/off_icon.png"
                fillMode: Image.PreserveAspectFit
                visible: false
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

