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
            id: frontControls
            x: 0
            y: 570
            width: 960
            height: 450
            color: "#ffffff"
            border.width: 1

            Rectangle {
                id: frontMovement
                x: 345
                y: 0
                width: 270
                height: 120
                color: "#ffffff"
                border.width: 1

                Image {
                    id: icon_0
                    x: 95
                    y: 10
                    source: "images/icon_0.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id: turn_right
                    x: 186
                    y: 28
                    source: "images/turn_right.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id: turn_left
                    x: 20
                    y: 28
                    source: "images/turn_left.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    id: frontAngleText
                    x: 95
                    y: 88
                    width: 80
                    height: 24
                    text: qsTr("0*")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }

            Rectangle {
                id: frontLogs
                x: 0
                y: 0
                width: 346
                height: 450
                color: "#ffffff"
                border.width: 1
            }

            Rectangle {
                id: frontAngle
                x: 345
                y: 118
                width: 270
                height: 80
                color: "#ffffff"
                border.width: 1

                Rectangle {
                    id: frontM5
                    x: 30
                    y: 8
                    width: 60
                    height: 45
                    color: "#ffffff"
                    border.width: 1

                    Button {
                        id: frontM5Button
                        x: 1
                        y: 1
                        width: 59
                        height: 43
                        text: qsTr("-5*")
                        font.pointSize: 16
                        font.bold: true
                    }
                }

                Rectangle {
                    id: frontP5
                    x: 180
                    y: 8
                    width: 60
                    height: 45
                    color: "#ffffff"
                    border.width: 1

                    Button {
                        id: frontP5Button
                        y: 1
                        width: 59
                        height: 43
                        text: qsTr("+5*")
                        font.pointSize: 16
                        font.bold: true
                    }
                }

                Rectangle {
                    id: frontAngleIndicator
                    x: 90
                    y: 8
                    width: 90
                    height: 45
                    color: "#ffffff"
                    border.width: 1

                    Text {
                        id: frontAngleIndicatorText
                        x: 0
                        y: 0
                        width: 90
                        height: 45
                        text: qsTr("45*")
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Text {
                    id: frontAngleTitle
                    x: 0
                    y: 53
                    width: 270
                    height: 27
                    text: qsTr("УГОЛ ПОВОРОТА")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                }
            }

            Rectangle {
                id: frontSettings
                x: 615
                y: 1
                width: 255
                height: 448
                color: "#ffffff"

                Rectangle {
                    id: frontExposition
                    x: 38
                    y: 25
                    width: 180
                    height: 60
                    color: "#ffffff"
                    border.width: 0

                    Rectangle {
                        id: frontExpositionTitle
                        x: 1
                        y: 1
                        width: 179
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: frontExpositionTitleText
                            x: 0
                            y: 0
                            width: 180
                            height: 30
                            text: qsTr("Выдержка")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: frontExpositionMinus
                        x: 1
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1

                        Button {
                            id: frontExpositionMinusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("-")
                            layer.smooth: true
                            font.bold: true
                            font.pointSize: 18
                        }
                    }

                    Rectangle {
                        id: frontExpositionIndicator
                        x: 30
                        y: 30
                        width: 120
                        height: 30
                        color: "#ffffff"
                        border.width: 1

                        TextEdit {
                            id: frontExpositionIndicatorText
                            width: 120
                            height: 30
                            text: qsTr("35.0")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: frontExpositionPlus
                        x: 149
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1

                        Button {
                            id: frontExpositionPlusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("+")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }

                }

                Rectangle {
                    id: frontISO
                    x: 38
                    y: 110
                    width: 180
                    height: 60
                    color: "#ffffff"
                    Rectangle {
                        id: frontISOTitle
                        x: 1
                        y: 1
                        width: 179
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: frontISOTitleText
                            x: 0
                            y: 0
                            width: 180
                            height: 30
                            text: qsTr("ISO")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: frontISOMinus
                        x: 1
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1

                        Button {
                            id: frontISOMinusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("-")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: frontISOIndicator
                        x: 30
                        y: 30
                        width: 120
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        TextEdit {
                            id: frontISOIndicatorText
                            width: 120
                            height: 30
                            text: qsTr("35.0")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: frontISOPlus
                        x: 149
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1

                        Button {
                            id: frontISOPlusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("+")

                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }
                }

                Rectangle {
                    id: frontBright
                    x: 38
                    y: 195
                    width: 180
                    height: 60
                    color: "#ffffff"

                    Text {
                        id: frontBrightTitleText
                        x: 1
                        y: 1
                        width: 180
                        height: 30
                        text: qsTr("Яркость")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        color: (viewmodel.onvif.frontBrightness !== null && viewmodel.onvif.frontBrightness !== undefined) ? "black" : "gray"
                    }

                    Slider {
                        id: frontBrightSlider
                        x: 0
                        y: 30
                        width: 180
                        height: 30
                        stepSize: 2
                        to: 100
                        from: 0
                        value: (viewmodel.onvif.frontBrightness !== null && viewmodel.onvif.frontBrightness !== undefined) ? viewmodel.onvif.frontBrightness : 50
                        enabled: viewmodel.onvif.frontBrightness !== null && viewmodel.onvif.frontBrightness !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onValueChanged: {
                            if (enabled) {
                                viewmodel.onvif.forward_float_command("front", "set_brightness", value)
                            }
                        }
                    }
                }

                Rectangle {
                    id: frontContrast
                    x: 38
                    y: 280
                    width: 180
                    height: 60
                    color: "#ffffff"

                    Text {
                        id: frontContrastTitleText
                        x: 1
                        y: 1
                        width: 180
                        height: 30
                        text: qsTr("Контраст")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        color: (viewmodel.onvif.frontContrast !== null && viewmodel.onvif.frontContrast !== undefined) ? "black" : "gray"
                    }

                    Slider {
                        id: frontContrastSlider
                        y: 30
                        width: 180
                        height: 30
                        stepSize: 2
                        to: 100
                        from: 0
                        value: (viewmodel.onvif.frontContrast !== null && viewmodel.onvif.frontContrast !== undefined) ? viewmodel.onvif.frontContrast : 50
                        enabled: viewmodel.onvif.frontContrast !== null && viewmodel.onvif.frontContrast !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onValueChanged: {
                            if (enabled) {
                                viewmodel.onvif.forward_float_command("front", "set_contrast", value)
                            }
                        }
                    }
                }

                Rectangle {
                    id: frontSaturation
                    x: 38
                    y: 365
                    width: 180
                    height: 60
                    color: "#ffffff"

                    Text {
                        id: frontSaturationTitleText
                        x: 1
                        y: 1
                        width: 180
                        height: 30
                        text: qsTr("Насыщенность")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        color: (viewmodel.onvif.frontSaturation !== null && viewmodel.onvif.frontSaturation !== undefined) ? "black" : "gray"
                    }

                    Slider {
                        id: frontSaturationSlider
                        x: 0
                        y: 30
                        width: 180
                        height: 30
                        stepSize: 2
                        to: 100
                        from: 0
                        value: (viewmodel.onvif.frontSaturation !== null && viewmodel.onvif.frontSaturation !== undefined) ? viewmodel.onvif.frontSaturation : 50
                        enabled: viewmodel.onvif.frontSaturation !== null && viewmodel.onvif.frontSaturation !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onValueChanged: {
                            if (enabled) {
                                viewmodel.onvif.forward_float_command("front", "set_saturation", value)
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: frontVeiwSettings
                x: 346
                y: 198
                width: 269
                height: 251
                color: "#ffffff"


                Rectangle {
                    id: frontAutoISO
                    x: 45
                    y: 20
                    width: 180
                    height: 30
                    color: "#ffffff"
                    SwitchDelegate {
                        id: frontAutoISOButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        text: qsTr("Перевернуть")
                        display: AbstractButton.IconOnly
                    }

                    Text {
                        id: frontAutoISOText
                        width: 110
                        height: 30
                        text: qsTr("Авто ISO")
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Rectangle {
                    id: frontFlip
                    x: 45
                    y: 60
                    width: 180
                    height: 30
                    color: "#ffffff"

                    SwitchDelegate {
                        id: frontFlipButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        text: qsTr("Перевернуть")
                        display: AbstractButton.IconOnly
                    }

                    Text {
                        id: frontFlipText
                        width: 110
                        height: 30
                        text: qsTr("Перевернуть")
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }



                Rectangle {
                    id: frontMirror
                    x: 45
                    y: 100
                    width: 180
                    height: 30
                    color: "#ffffff"
                    SwitchDelegate {
                        id: frontMirrorButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        text: qsTr("Перевернуть")
                        display: AbstractButton.IconOnly
                    }

                    Text {
                        id: frontMirrorText
                        width: 110
                        height: 30
                        text: qsTr("Отзеркалить")
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Rectangle {
                    id: frontFPS
                    x: 45
                    y: 140
                    width: 180
                    height: 60
                    color: "#ffffff"
                    Rectangle {
                        id: frontFPSTitle
                        x: 1
                        y: 1
                        width: 179
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: frontFPSTitleText
                            x: 0
                            y: 0
                            width: 180
                            height: 30
                            text: qsTr("FPS")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: frontFPSMinus
                        x: 1
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1

                        Button {
                            id: frontFPSMinusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("-")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: frontFPSIndicator
                        x: 30
                        y: 30
                        width: 120
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        TextEdit {
                            id: frontFPSIndicatorText
                            width: 120
                            height: 30
                            text: qsTr("25")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: frontFPSPlus
                        x: 149
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1

                        Button {
                            id: frontFPSPlusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("+")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }
                }

            }
        }

        Rectangle {
            id: backControls
            x: 960
            y: 570
            width: 960
            height: 450
            color: "#ffffff"
            border.width: 1

            Rectangle {
                id: backSettings
                x: 90
                y: 1
                width: 255
                height: 448
                color: "#ffffff"
                Rectangle {
                    id: backExposition
                    x: 38
                    y: 25
                    width: 180
                    height: 60
                    color: "#ffffff"
                    border.width: 0
                    Rectangle {
                        id: backExpositionTitle
                        x: 1
                        y: 1
                        width: 179
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: backExpositionTitleText
                            x: 0
                            y: 0
                            width: 180
                            height: 30
                            text: qsTr("Выдержка")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backExpositionMinus
                        x: 1
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Button {
                            id: backExpositionMinusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("-")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backExpositionIndicator
                        x: 30
                        y: 30
                        width: 120
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        TextEdit {
                            id: backExpositionIndicatorText
                            width: 120
                            height: 30
                            text: qsTr("35.0")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: backExpositionPlus
                        x: 149
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Button {
                            id: backExpositionPlusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("+")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }
                }

                Rectangle {
                    id: backISO
                    x: 38
                    y: 110
                    width: 180
                    height: 60
                    color: "#ffffff"
                    Rectangle {
                        id: backISOTitle
                        x: 1
                        y: 1
                        width: 179
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: backISOTitleText
                            x: 0
                            y: 0
                            width: 180
                            height: 30
                            text: qsTr("ISO")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backISOMinus
                        x: 1
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Button {
                            id: backISOMinusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("-")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backISOIndicator
                        x: 30
                        y: 30
                        width: 120
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        TextEdit {
                            id: backISOIndicatorText
                            width: 120
                            height: 30
                            text: qsTr("35.0")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: backISOPlus
                        x: 149
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Button {
                            id: backISOPlusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("+")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }
                }

                Rectangle {
                    id: backBright
                    x: 38
                    y: 195
                    width: 180
                    height: 60
                    color: "#ffffff"

                    Text {
                        id: backBrightTitleText
                        x: 1
                        y: 1
                        width: 180
                        height: 30
                        color: (viewmodel.onvif.backBrightness !== null && viewmodel.onvif.backBrightness !== undefined) ? "black" : "gray"
                        text: qsTr("Яркость")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                    }

                    Slider {
                        id: backBrightSlider
                        x: 0
                        y: 30
                        width: 180
                        height: 30
                        opacity: enabled ? 1.0 : 0.5
                        value: (viewmodel.onvif.backBrightness !== null && viewmodel.onvif.backBrightness !== undefined) ? viewmodel.onvif.backBrightness : 50
                        stepSize: 2
                        onValueChanged: {
                                                if (enabled) {
                                                    viewmodel.onvif.forward_float_command("back", "set_brightness", value)
                                                }
                        }
                        enabled: viewmodel.onvif.backBrightness !== null && viewmodel.onvif.backBrightness !== undefined
                        to: 100
                        from: 0
                    }
                }

                Rectangle {
                    id: backContrast
                    x: 38
                    y: 280
                    width: 180
                    height: 60
                    color: "#ffffff"

                    Text {
                        id: backContrastTitleText
                        x: 1
                        y: 1
                        width: 180
                        height: 30
                        color: (viewmodel.onvif.backContrast !== null && viewmodel.onvif.backContrast !== undefined) ? "black" : "gray"
                        text: qsTr("Контраст")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                    }

                    Slider {
                        id: backContrastSlider
                        y: 30
                        width: 180
                        height: 30
                        opacity: enabled ? 1.0 : 0.5
                        value: (viewmodel.onvif.backContrast !== null && viewmodel.onvif.backContrast !== undefined) ? viewmodel.onvif.backContrast : 50
                        stepSize: 2
                        onValueChanged: {
                                                if (enabled) {
                                                    viewmodel.onvif.forward_float_command("back", "set_contrast", value)
                                                }
                        }
                        enabled: viewmodel.onvif.backContrast !== null && viewmodel.onvif.backContrast !== undefined
                        to: 100
                        from: 0
                    }
                }

                Rectangle {
                    id: backSaturation
                    x: 38
                    y: 365
                    width: 180
                    height: 60
                    color: "#ffffff"

                    Text {
                        id: backSaturationTitleText
                        x: 1
                        y: 1
                        width: 180
                        height: 30
                        color: (viewmodel.onvif.backSaturation !== null && viewmodel.onvif.backSaturation !== undefined) ? "black" : "gray"
                        text: qsTr("Насыщенность")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                    }

                    Slider {
                        id: backSaturationSlider
                        x: 0
                        y: 30
                        width: 180
                        height: 30
                        opacity: enabled ? 1.0 : 0.5
                        value: (viewmodel.onvif.backSaturation !== null && viewmodel.onvif.backSaturation !== undefined) ? viewmodel.onvif.backSaturation : 50
                        stepSize: 2
                        onValueChanged: {
                                                if (enabled) {
                                                    viewmodel.onvif.forward_float_command("back", "set_saturation", value)
                                                }
                                            }
                        enabled: viewmodel.onvif.backSaturation !== null && viewmodel.onvif.backSaturation !== undefined
                        to: 100
                        from: 0
                    }
                }
            }

            Rectangle {
                id: backMovement
                x: 345
                y: 0
                width: 270
                height: 120
                color: "#ffffff"
                border.width: 1
                Image {
                    id: icon_1
                    x: 95
                    y: 10
                    source: "images/icon_0.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id: turn_right1
                    x: 186
                    y: 28
                    source: "images/turn_right.png"
                    fillMode: Image.PreserveAspectFit
                }

                Image {
                    id: turn_left1
                    x: 20
                    y: 28
                    source: "images/turn_left.png"
                    fillMode: Image.PreserveAspectFit
                }

                Text {
                    id: backAngleText
                    x: 95
                    y: 88
                    width: 80
                    height: 24
                    text: qsTr("0*")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }

            Rectangle {
                id: backVeiwSettings
                x: 346
                y: 198
                width: 269
                height: 251
                color: "#ffffff"
                Rectangle {
                    id: backFlip
                    x: 45
                    y: 25
                    width: 180
                    height: 30
                    color: "#ffffff"
                    SwitchDelegate {
                        id: backFlipButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        text: qsTr("Перевернуть")
                        display: AbstractButton.IconOnly
                    }

                    Text {
                        id: backFlipText
                        width: 110
                        height: 30
                        text: qsTr("Перевернуть")
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Rectangle {
                    id: backMirror
                    x: 45
                    y: 85
                    width: 180
                    height: 30
                    color: "#ffffff"
                    SwitchDelegate {
                        id: backMirrorButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        text: qsTr("Перевернуть")
                        display: AbstractButton.IconOnly
                    }

                    Text {
                        id: backMirrorText
                        width: 110
                        height: 30
                        text: qsTr("Отзеркалить")
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Rectangle {
                    id: backFPS
                    x: 45
                    y: 140
                    width: 180
                    height: 60
                    color: "#ffffff"
                    Rectangle {
                        id: backFPSTitle
                        x: 1
                        y: 1
                        width: 179
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: backFPSTitleText
                            x: 0
                            y: 0
                            width: 180
                            height: 30
                            text: qsTr("FPS")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backFPSMinus
                        x: 1
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Button {
                            id: backFPSMinusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("-")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backFPSIndicator
                        x: 30
                        y: 30
                        width: 120
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        TextEdit {
                            id: backFPSIndicatorText
                            width: 120
                            height: 30
                            text: qsTr("25")
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: backFPSPlus
                        x: 149
                        y: 30
                        width: 31
                        height: 30
                        color: "#ffffff"
                        border.width: 1
                        Button {
                            id: backFPSPlusButton
                            x: 1
                            y: 1
                            width: 29
                            height: 28
                            text: qsTr("+")
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                        }
                    }
                }
            }

            Rectangle {
                id: backAngle
                x: 345
                y: 118
                width: 270
                height: 80
                color: "#ffffff"
                border.width: 1
                Rectangle {
                    id: backM5
                    x: 30
                    y: 8
                    width: 60
                    height: 45
                    color: "#ffffff"
                    border.width: 1

                    Button {
                        id: backM5Button
                        x: 1
                        y: 1
                        width: 59
                        height: 43
                        text: qsTr("-5*")
                        font.pointSize: 16
                        font.bold: true
                    }
                }

                Rectangle {
                    id: backP5
                    x: 180
                    y: 8
                    width: 60
                    height: 45
                    color: "#ffffff"
                    border.width: 1

                    Button {
                        id: backP5Button
                        x: 0
                        y: 1
                        width: 59
                        height: 43
                        text: qsTr("+5*")
                        font.bold: true
                        font.pointSize: 16
                    }
                }

                Rectangle {
                    id: backAngleIndicator
                    x: 90
                    y: 8
                    width: 90
                    height: 45
                    color: "#ffffff"
                    border.width: 1
                    Text {
                        id: frontAngleIndicatorText1
                        x: 0
                        y: 0
                        width: 90
                        height: 45
                        text: qsTr("45*")
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Text {
                    id: backAngleTitle
                    x: 0
                    y: 53
                    width: 270
                    height: 27
                    text: qsTr("УГОЛ ПОВОРОТА")
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
                }
            }

            Rectangle {
                id: backLogs
                x: 614
                y: 0
                width: 346
                height: 450
                color: "#ffffff"
                border.width: 1
            }
        }

        Rectangle {
            id: navigationRect
            x: 870
            y: 570
            width: 180
            height: 450
            color: "#ffffff"
            border.width: 1
            rotation: 0
        }

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
    }
}
