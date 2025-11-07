import QtQuick 2.15
import QtQuick.Controls 2.15

Popup {
    id: infoPopup
    width: 900
    height: 1050
    modal: true
    focus: true
    anchors.centerIn: parent
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: "white"
        border.color: "black"
        border.width: 2
        radius: 10
    }

    Item {
        anchors.fill: parent

        Image {
            id: logo
            source: "images/firelogo.png"
            width: 570
            height: 570
            fillMode: Image.PreserveAspectFit
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            id: versionInfo
            width: parent.width - 40
            anchors.top: logo.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5

            Text {
                text: "Версия ПО: 2.5"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Идентификационное наименование ПО: 2023-024-VZS0421198"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Модификация: 3B-1600C"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Rectangle {
            width: parent.width - 40
            height: 1
            color: "black"
            anchors.top: versionInfo.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            id: contactInfo
            width: parent.width - 40
            anchors.top: versionInfo.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Text {
                text: "Контакты для обращения в случае необходимости обслуживания,\nремонта или наступления гарантийных обязательств:"
                font.pixelSize: 21
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid {
                columns: 2
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text { text: "Наименование:"; font.bold: true; font.pixelSize: 21 }
                Text { text: "Индивидуальный предприниматель"; font.pixelSize: 14 }

                Text { text: "Телефон:"; font.bold: true; font.pixelSize: 21 }
                Text { text: "+7 000 000 00 00"; font.pixelSize: 21 }

                Text { text: "Почта:"; font.bold: true; font.pixelSize: 21 }
                Text { text: "firesystem@internet.ru"; font.pixelSize: 21 }
            }
        }

        Rectangle {
            width: parent.width - 40
            height: 1
            color: "black"
            anchors.top: contactInfo.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            id: closeButton
            text: "Закрыть"
            width: 120
            height: 40
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: infoPopup.close()
        }
    }
}