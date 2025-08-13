import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    width: 1920
    height: 1080

    Rectangle {
        id: mainRectangle
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        color: "#fefefe"



        Rectangle {
            id: frontView
            x: 0
            y: 0
            width: 960
            height: 570
            color: "#ffffff"
            border.width: 1

        }

        Rectangle {
            id: backView
            x: 960
            y: 0
            width: 960
            height: 570
            color: "#ffffff"
            border.width: 1
        }
        Rectangle {
            id: navigationRect
            x: 870
            y: 570
            width: 180
            height: 450
            color: "#ffffff"
            border.width: 0
            z: 10
            rotation: 0
        }

        Rectangle {
            id: frontSettings
            x: 0
            y: 570
            width: 870
            height: 450
            color: "#ffffff"
            border.width: 1

            Rectangle {
                id: frontIpController
                x: 1
                y: 30
                width: 434
                height: 30
                color: "#ffffff"

                Rectangle {
                    id: frontIpControllerForm
                    x: 30
                    y: 0
                    width: 160
                    height: 30
                    color: "#ffffff"
                    border.width: 1

                    TextEdit {
                        id: frontIpControllerEdit
                        x: 0
                        y: 0
                        width: 160
                        height: 30
                        text: qsTr("192 . 168 . 1 . 66")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontIpControllerText
                    x: 220
                    y: 0
                    width: 210
                    height: 30
                    text: qsTr("IP-адрес контроллера")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontCameraController
                x: 435
                y: 30
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontCameraControllerForm
                    x: 30
                    y: 0
                    width: 160
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontIpControllerEdit1
                        x: 0
                        y: 0
                        width: 160
                        height: 30
                        text: qsTr("192 . 168 . 1 . 66")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontCameraControllerText
                    x: 220
                    y: 0
                    width: 210
                    height: 30
                    text: qsTr("IP-адрес камеры")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontWaterPressLimit
                x: 1
                y: 90
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontWaterPressLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontWaterPressLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("2.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontWaterPressLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел давления воды (кгс/см²)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontAirPressLimit
                x: 434
                y: 90
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontAirPressLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontAirPressLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("2.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontAirPressLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел давления воздуха (кгс/см²)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontAirTempLimit
                x: 1
                y: 150
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontAirTempLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontAirTempLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("50.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontAirTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел температуры воздуха (°С)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontWaterTempLimit
                x: 1
                y: 210
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontWaterTempLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontWaterTempLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("50.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontWaterTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел температуры воды (°С)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontOutTempLimit
                x: 1
                y: 270
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontOutTempLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontOutTempLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("70.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontOutTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел температуры сброса (°С)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontWpTempLimit
                x: 1
                y: 330
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontWpTempLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontWpTempLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("70.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontWpTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел температуры платы (°С)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontMotorDir
                x: 434
                y: 150
                width: 434
                height: 30
                color: "#ffffff"

                Text {
                    id: frontMotorDirText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Поменять направление к 0°")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchDelegate {
                    id: frontMotorDirSwitch
                    x: 39
                    y: 0
                    width: 71
                    height: 30
                    display: AbstractButton.IconOnly
                }

            }
        }

        Rectangle {
            id: backSettings
            x: 1050
            y: 570
            width: 870
            height: 450
            color: "#ffffff"
            border.width: 1












            Rectangle {
                id: frontCameraController1
                x: 435
                y: 30
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontCameraControllerForm1
                    x: 30
                    y: 0
                    width: 160
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontIpControllerEdit3
                        x: 0
                        y: 0
                        width: 160
                        height: 30
                        text: qsTr("192 . 168 . 1 . 66")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontCameraControllerText1
                    x: 220
                    y: 0
                    width: 210
                    height: 30
                    text: qsTr("IP-адрес камеры")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontWaterPressLimit1
                x: 1
                y: 90
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontWaterPressLimitForm1
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontWaterPressLimitEdit1
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("2.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontWaterPressLimitText1
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел давления воды (кгс/см²)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontAirPressLimit1
                x: 434
                y: 90
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontAirPressLimitForm1
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontAirPressLimitEdit1
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("2.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontAirPressLimitText1
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел давления воздуха (кгс/см²)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontAirTempLimit1
                x: 1
                y: 150
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontAirTempLimitForm1
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontAirTempLimitEdit1
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("50.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontAirTempLimitText1
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел температуры воздуха (°С)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontWaterTempLimit1
                x: 1
                y: 210
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontWaterTempLimitForm1
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontWaterTempLimitEdit1
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("50.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontWaterTempLimitText1
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел температуры воды (°С)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontOutTempLimit1
                x: 1
                y: 270
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontOutTempLimitForm1
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontOutTempLimitEdit1
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("70.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontOutTempLimitText1
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел температуры сброса (°С)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: systemName
                x: 570
                y: 235
                width: 270
                height: 60
                color: "#ffffff"
                Rectangle {
                    id: systemNameForm
                    x: 0
                    y: 0
                    width: 270
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: systemNameEdit
                        x: 0
                        y: 0
                        width: 270
                        height: 30
                        text: qsTr("Система 1")
                        font.pixelSize: 22
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: systemNameText
                    x: 0
                    y: 30
                    width: 270
                    height: 30
                    text: qsTr("Название системы")
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontWpTempLimit1
                x: 1
                y: 330
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontWpTempLimitForm1
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontWpTempLimitEdit1
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: qsTr("70.0")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontWpTempLimitText1
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Предел температуры платы (°С)")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }


            Rectangle {
                id: frontMotorDir1
                x: 434
                y: 150
                width: 434
                height: 30
                color: "#ffffff"
                Text {
                    id: frontMotorDirText1
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: qsTr("Поменять направление к 0°")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchDelegate {
                    id: frontMotorDirSwitch1
                    x: 39
                    y: 0
                    width: 71
                    height: 30
                    display: AbstractButton.IconOnly
                }
            }
            Button {
                id: deleteSystemButton
                x: 570
                y: 375
                width: 270
                height: 45
                text: qsTr("УДАЛИТЬ СИСТЕМУ")
                font.pointSize: 14

                background: Rectangle {
                    radius: 6
                    color: deleteSystemButton.pressed
                           ? "#cc0000"    // цвет при нажатии
                           : deleteSystemButton.hovered
                             ? "#ff4d4d"  // цвет при наведении
                             : "#ff6666"  // обычный цвет
                    border.color: "#990000"
                    border.width: 1
                }

                contentItem: Text {
                    text: deleteSystemButton.text
                    font.pixelSize: 20
                    color: "white"
                    font.bold: true
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                hoverEnabled: true
            }
            Rectangle {
                id: systemIpAdress
                x: 570
                y: 305
                width: 270
                height: 60
                color: "#ffffff"
                Rectangle {
                    id: systemIpAdressForm
                    x: 0
                    y: 0
                    width: 270
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: systemIpAdressEdit
                        x: 0
                        y: 0
                        width: 270
                        height: 30
                        text: qsTr("192 . 168 . 1 .13")
                        font.pixelSize: 22
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: systemIpAdressText
                    x: 0
                    y: 30
                    width: 270
                    height: 30
                    text: qsTr("IP-адрес компьютера")
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Rectangle {
                id: frontIpController1
                x: 1
                y: 30
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: frontIpControllerForm1
                    x: 30
                    y: 0
                    width: 160
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: frontIpControllerEdit2
                        x: 0
                        y: 0
                        width: 160
                        height: 30
                        text: qsTr("192 . 168 . 1 . 66")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Text {
                    id: frontIpControllerText1
                    x: 220
                    y: 0
                    width: 210
                    height: 30
                    text: qsTr("IP-адрес контроллера")
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

    }
}
