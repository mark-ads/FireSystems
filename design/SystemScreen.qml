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
                property int state: viewmodel.udp.frontState
                enabled: frontMovement.state === 3
                opacity: enabled ? 1.0 : 0.5


                Image {
                    id: frontAngleIcon
                    x: 95
                    y: 10
                    source: "images/icon_0.png"
                    rotation: viewmodel.udp.frontAngle
                    fillMode: Image.PreserveAspectFit
                    opacity: frontMovement.enabled ? 1.0 : 0.5
                }

                MouseArea {
                    id: frontRightMouseArea
                    x: 186
                    y: 28
                    z: 10
                    width: 64
                    height: 64
                    property bool pressed: false
                    enabled: frontMovement.enabled
                    onPressed: frontRightMouseArea.pressed = true
                    onReleased: {
                        frontRightMouseArea.pressed = false
                        viewmodel.udp.forward_int_command("front", "turn_right", frontAngle.angle)
                    }
                    onCanceled: frontRightMouseArea.pressed = false
                }

                Image {
                    id: turnRightIcon
                    x: 186
                    y: 28
                    source: "images/turn_right.png"
                    fillMode: Image.PreserveAspectFit
                    opacity: frontMovement.enabled ? 1.0 : 0.5
                    scale: frontRightMouseArea.pressed ? 0.9 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
                }

                MouseArea {
                    id: frontLeftMouseArea
                    x: 20
                    y: 28
                    z: 10
                    width: 64
                    height: 64
                    property bool pressed: false
                    enabled: frontMovement.enabled
                    onPressed: frontLeftMouseArea.pressed = true
                    onReleased: {
                        frontLeftMouseArea.pressed = false
                        viewmodel.udp.forward_int_command("front", "turn_left", frontAngle.angle)
                    }
                    onCanceled: frontLeftMouseArea.pressed = false
                }

                Image {
                    id: turnLeftIcon
                    x: 20
                    y: 28
                    source: "images/turn_left.png"
                    fillMode: Image.PreserveAspectFit
                    opacity: frontMovement.enabled ? 1.0 : 0.5
                    scale: frontLeftMouseArea.pressed ? 0.9 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
                }

                Text {
                    id: frontAngleText
                    x: 95
                    y: 88
                    width: 80
                    height: 24
                    text: viewmodel.udp.frontAngle + "°"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    opacity: frontMovement.enabled ? 1.0 : 0.5
                }
            }


            Rectangle {
                id: frontAngle
                x: 345
                y: 118
                width: 270
                height: 80
                color: "#ffffff"
                border.width: 1

                property int angle: 45

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
                        text: "-5°"
                        font.pointSize: 16
                        font.bold: true
                        onReleased: {
                            if (frontAngle.angle > 5) {
                            frontAngle.angle = frontAngle.angle - 5
                            }
                        }
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
                        text: "+5°"
                        font.pointSize: 16
                        font.bold: true
                        onReleased: {
                            if (frontAngle.angle < 90) {
                            frontAngle.angle = frontAngle.angle + 5
                            }
                        }
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
                        text: frontAngle.angle + "°"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                        onTextChanged: {
                            if (parseInt(text) > 90) {
                                text = "90"
                            }
                            if (parseInt(text) < 5) {
                                text = "5"
                            }
                        }
                    }
                }

                Text {
                    id: frontAngleTitle
                    x: 0
                    y: 53
                    width: 270
                    height: 27
                    text: "УГОЛ ПОВОРОТА"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: false
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

                ListView {
                    id: frontLogsView
                    x: 3
                    width: 343
                    height: parent.height
                    clip: true
                    model: viewmodel.udp.frontLogs

                    delegate: Text {
                        text: modelData
                        color: "black"
                        font.pixelSize: 14
                        wrapMode: Text.Wrap
                        width: frontLogsView.width - 7
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }
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
                    enabled: (viewmodel.dvrip.frontExpo !== null
                              && viewmodel.dvrip.frontExpo !== undefined
                              && frontAutoExpoButton.checked)
                    opacity: enabled ? 1.0 : 0.5

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
                            text: "Выдержка"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            enabled: frontExposition.enabled
                            opacity: frontExposition.opacity
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
                            text: "-"
                            layer.smooth: true
                            font.bold: true
                            font.pointSize: 18
                            enabled: frontExposition.enabled
                            opacity: frontExposition.opacity
                            onReleased: {
                                frontExpositionIndicatorText.text = (parseInt(frontExpositionIndicatorText.text) || 0) - 1
                                frontExpositionIndicatorText.commitValue()
                            }
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
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                            wrapMode: Text.NoWrap
                            selectByMouse: true
                            focus: false
                            text: (viewmodel.dvrip.frontExpo !== null && viewmodel.dvrip.frontExpo !== undefined) ? viewmodel.dvrip.frontExpo : "10"
                            enabled: frontExposition.enabled
                            opacity: frontExposition.opacity

                            property int lastValue: parseInt(text) || 10

                            onTextChanged: {
                                var clean = text.replace(/[^0-9]/g, "")
                                if (clean !== text) {
                                    text = clean
                                }
                                if (text.startsWith("0")) {
                                    text = "1"
                                }
                            }

                            Keys.onReturnPressed: focus = false

                            onFocusChanged: {
                                if (!focus) {
                                    commitValue()
                                }
                            }

                            function commitValue() {
                                let val = parseInt(text.trim())
                                if (!isNaN(val)) {
                                    lastValue = val
                                    viewmodel.dvrip.forward_int_command("front", "set_exposure", val)
                                } else {
                                    text = lastValue
                                }
                            }
                        }
                        Connections {
                            target: viewmodel.dvrip
                            function onFrontExpoChanged() {
                                if (!frontExpositionIndicatorText.focus && typeof viewmodel.dvrip.frontExpo !== "undefined") {
                                    frontExpositionIndicatorText.text = viewmodel.dvrip.frontExpo.toString()
                                }
                            }
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
                            text: "+"
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                            enabled: frontExposition.enabled
                            opacity: frontExposition.opacity
                            onReleased: {
                                frontExpositionIndicatorText.text = (parseInt(frontExpositionIndicatorText.text) || 0) + 1
                                frontExpositionIndicatorText.commitValue()
                            }
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
                    enabled: (viewmodel.dvrip.frontGain !== null
                              && viewmodel.dvrip.frontGain !== undefined
                              && frontAutoISOButton.checked)
                    opacity: enabled ? 1.0 : 0.5
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
                            text: "Gain"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            enabled: frontISO.enabled
                            opacity: frontISO.opacity
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
                            text: "-"
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                            enabled: frontISO.enabled
                            opacity: frontISO.opacity
                            onReleased: {
                                frontISOIndicatorText.text = (parseInt(frontISOIndicatorText.text) || 0) - 5
                                frontISOIndicatorText.commitValue()
                            }
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
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                            wrapMode: Text.NoWrap
                            selectByMouse: true
                            focus: false
                            text: (viewmodel.dvrip.frontGain !== null && viewmodel.dvrip.frontGain !== undefined) ? viewmodel.dvrip.frontGain : "50"
                            enabled: frontISO.enabled
                            opacity: frontISO.opacity

                            property int lastValue: parseInt(text) || 50

                            onTextChanged: {
                                var clean = text.replace(/[^0-9]/g, "")
                                if (clean !== text) {
                                    text = clean
                                }
                                if (parseInt(text) > 100) {
                                    text = "100"
                                }
                                if (parseInt(text) < 0) {
                                    text = "0"
                                }
                            }

                            Keys.onReturnPressed: focus = false

                            onFocusChanged: {
                                if (!focus) {
                                    commitValue()
                                }
                            }

                            function commitValue() {
                                let val = parseInt(text.trim())
                                if (!isNaN(val)) {
                                    lastValue = val
                                    viewmodel.dvrip.forward_int_command("front", "set_gain", val)
                                } else {
                                    text = lastValue
                                }
                            }
                        }
                        Connections {
                            target: viewmodel.dvrip
                            function onFrontGainChanged() {
                                if (!frontISOIndicatorText.focus && typeof viewmodel.dvrip.frontGain !== "undefined") {
                                    frontISOIndicatorText.text = viewmodel.dvrip.frontGain.toString()
                                }
                            }
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
                            text: "+"
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                            enabled: frontISO.enabled
                            opacity: frontISO.opacity
                            onReleased: {
                                frontISOIndicatorText.text = (parseInt(frontISOIndicatorText.text) || 0) + 5
                                frontISOIndicatorText.commitValue()
                            }
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
                    enabled: viewmodel.onvif.frontBrightness !== null && viewmodel.onvif.frontBrightness !== undefined

                    Text {
                        id: frontBrightTitleText
                        x: 1
                        y: 1
                        width: 180
                        height: 30
                        text: "Яркость"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        color: (frontBright.enabled === true) ? "black" : "gray"
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
                        enabled: frontBright.enabled
                        opacity: enabled ? 1.0 : 0.5
                        onValueChanged: {
                            if (!enabled)
                                return;

                            if (value === 50 && (viewmodel.onvif.frontBrightness === null || viewmodel.onvif.frontBrightness === undefined))
                                        return;

                            viewmodel.onvif.forward_float_command("front", "set_brightness", value)
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
                        text: "Контраст"
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
                            if (!enabled)
                                return;

                            if (value === 50 && (viewmodel.onvif.frontContrast === null || viewmodel.onvif.frontContrast === undefined))
                                        return;

                            viewmodel.onvif.forward_float_command("front", "set_contrast", value)
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
                        text: "Насыщенность"
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
                            if (!enabled)
                                return;

                            if (value === 50 && (viewmodel.onvif.frontSaturation === null || viewmodel.onvif.frontSaturation === undefined))
                                        return;

                            viewmodel.onvif.forward_float_command("front", "set_saturation", value)
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
                    id: frontAutoExpo
                    x: 35
                    y: 10
                    width: 190
                    height: 30
                    color: "#ffffff"
                    Switch {
                        id: frontAutoExpoButton
                        x: 120
                        y: 0
                        width: 70
                        height: 30
                        display: AbstractButton.IconOnly
                        checked: (viewmodel.dvrip.frontAutoExpo !== null && viewmodel.dvrip.frontAutoExpo !== undefined) ? viewmodel.dvrip.frontAutoExpo : false
                        enabled: viewmodel.dvrip.frontAutoExpo !== null && viewmodel.dvrip.frontAutoExpo !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onToggled: {
                            viewmodel.dvrip.forward_bool_command("front", "set_manual_exposure", checked)
                        }
                    }

                    Text {
                        id: frontAutoExpoText
                        x: 0
                        y: 0
                        width: 115
                        height: 30
                        text: "Выдержка"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                        opacity: frontAutoExpoButton.enabled ? 1.0 : 0.5
                    }
                }

                Rectangle {
                    id: frontAutoISO
                    x: 45
                    y: 50
                    width: 180
                    height: 30
                    color: "#ffffff"
                    Switch {
                        id: frontAutoISOButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        display: AbstractButton.IconOnly
                        checked: (viewmodel.dvrip.frontAutoGain !== null && viewmodel.dvrip.frontAutoGain !== undefined) ? viewmodel.dvrip.frontAutoGain : false
                        enabled: viewmodel.dvrip.frontAutoGain !== null && viewmodel.dvrip.frontAutoGain !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onToggled: {
                            viewmodel.dvrip.forward_bool_command("front", "set_auto_gain", checked)
                        }
                    }

                    Text {
                        id: frontAutoISOText
                        width: 110
                        height: 30
                        text: "Усиление"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                        opacity: frontAutoISOButton.enabled ? 1.0 : 0.5
                    }
                }

                Rectangle {
                    id: frontMirror
                    x: 45
                    y: 90
                    width: 180
                    height: 30
                    color: "#ffffff"
                    Switch {
                        id: frontMirrorButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        display: AbstractButton.IconOnly
                        checked: (viewmodel.dvrip.frontMirror !== null && viewmodel.dvrip.frontMirror !== undefined) ? viewmodel.dvrip.frontMirror : false
                        enabled: viewmodel.dvrip.frontMirror !== null && viewmodel.dvrip.frontMirror !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onToggled: {
                            viewmodel.dvrip.forward_bool_command("front", "set_mirror", checked)
                        }
                    }

                    Text {
                        id: frontMirrorText
                        width: 110
                        height: 30
                        text: "Отзеркалить"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                        opacity: frontMirrorButton.enabled ? 1.0 : 0.5

                    }
                }


                Rectangle {
                    id: frontFlip
                    x: 45
                    y: 130
                    width: 180
                    height: 30
                    color: "#ffffff"

                    Switch {
                        id: frontFlipButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        display: AbstractButton.IconOnly
                        checked: (viewmodel.dvrip.frontFlip !== null && viewmodel.dvrip.frontFlip !== undefined) ? viewmodel.dvrip.frontFlip : false
                        enabled: viewmodel.dvrip.frontFlip !== null && viewmodel.dvrip.frontFlip !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onToggled: {
                            viewmodel.dvrip.forward_bool_command("front", "set_flip", checked)
                        }
                    }

                    Text {
                        id: frontFlipText
                        width: 110
                        height: 30
                        text: "Перевернуть"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                        opacity: frontFlipButton.enabled ? 1.0 : 0.5
                    }
                }

                Rectangle {
                    id: frontFPS
                    x: 45
                    y: 170
                    width: 180
                    height: 60
                    color: "#ffffff"
                    enabled: (viewmodel.dvrip.frontFps !== null
                              && viewmodel.dvrip.frontFps !== undefined)
                    opacity: enabled ? 1.0 : 0.5
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
                            text: "FPS"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            enabled: frontFPS.enabled
                            opacity: frontFPS.opacity
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
                            text: "-"
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                            enabled: frontFPS.enabled
                            opacity: frontFPS.opacity
                            onReleased: {
                                frontFPSIndicatorText.text = (parseInt(frontFPSIndicatorText.text) || 0) - 5
                                frontFPSIndicatorText.commitValue()
                            }
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
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                            wrapMode: Text.NoWrap
                            selectByMouse: true
                            focus: false
                            text: (viewmodel.dvrip.frontFps !== null && viewmodel.dvrip.frontFps !== undefined) ? viewmodel.dvrip.frontFps : "25"
                            enabled: frontFPS.enabled
                            opacity: frontFPS.opacity

                            property int lastValue: parseInt(text) || 25

                            onTextChanged: {
                                var clean = text.replace(/[^0-9]/g, "")
                                if (clean !== text) {
                                    text = clean
                                }
                                if (parseInt(text) > 100) {
                                    text = "100"
                                }
                                if (parseInt(text) < 1) {
                                    text = "10"
                                }
                            }

                            Keys.onReturnPressed: focus = false

                            onFocusChanged: {
                                if (!focus) {
                                    commitValue()
                                }
                            }

                            function commitValue() {
                                let val = parseInt(text.trim())
                                if (!isNaN(val)) {
                                    lastValue = val
                                    viewmodel.dvrip.forward_int_command("front", "set_fps", val)
                                } else {
                                    text = lastValue
                                }
                            }
                        }
                        Connections {
                            target: viewmodel.dvrip
                            function onFrontFpsChanged() {
                                if (!frontFPSIndicatorText.focus && typeof viewmodel.dvrip.frontFps !== "undefined") {
                                    frontFPSIndicatorText.text = viewmodel.dvrip.frontFps.toString()
                                }
                            }
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
                            text: "+"
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                            enabled: frontFPS.enabled
                            opacity: frontFPS.opacity
                            onReleased: {
                                frontFPSIndicatorText.text = (parseInt(frontFPSIndicatorText.text) || 0) + 5
                                frontFPSIndicatorText.commitValue()
                            }
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
                id: backMovement
                x: 345
                y: 0
                width: 270
                height: 120
                color: "#ffffff"
                border.width: 1
                property int state: viewmodel.udp.backState
                enabled: backMovement.state === 3
                opacity: enabled ? 1.0 : 0.5


                Image {
                    id: backAngleIcon
                    x: 95
                    y: 10
                    source: "images/icon_0.png"
                    rotation: viewmodel.udp.backAngle
                    fillMode: Image.PreserveAspectFit
                    opacity: backMovement.enabled ? 1.0 : 0.5
                }

                MouseArea {
                    id: backRightMouseArea
                    x: 186
                    y: 28
                    z: 10
                    width: 64
                    height: 64
                    property bool pressed: false
                    enabled: backMovement.enabled
                    onPressed: backRightMouseArea.pressed = true
                    onReleased: {
                        backRightMouseArea.pressed = false
                        viewmodel.udp.forward_int_command("back", "turn_right", backAngle.angle)
                    }
                    onCanceled: backRightMouseArea.pressed = false
                }

                Image {
                    id: backRightIcon
                    x: 186
                    y: 28
                    source: "images/turn_right.png"
                    fillMode: Image.PreserveAspectFit
                    opacity: backMovement.enabled ? 1.0 : 0.5
                    scale: backRightMouseArea.pressed ? 0.9 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
                }

                MouseArea {
                    id: backLeftMouseArea
                    x: 20
                    y: 28
                    z: 10
                    width: 64
                    height: 64
                    property bool pressed: false
                    enabled: backMovement.enabled
                    onPressed: backLeftMouseArea.pressed = true
                    onReleased: {
                        backLeftMouseArea.pressed = false
                        viewmodel.udp.forward_int_command("back", "turn_left", backAngle.angle)
                    }
                    onCanceled: backLeftMouseArea.pressed = false
                }

                Image {
                    id: backLeftIcon
                    x: 20
                    y: 28
                    source: "images/turn_left.png"
                    fillMode: Image.PreserveAspectFit
                    opacity: backMovement.enabled ? 1.0 : 0.5
                    scale: backLeftMouseArea.pressed ? 0.9 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.InOutQuad } }
                }

                Text {
                    id: backAngleText
                    x: 95
                    y: 88
                    width: 80
                    height: 24
                    text: viewmodel.udp.backAngle + "°"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    opacity: backMovement.enabled ? 1.0 : 0.5
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

                property int angle: 45

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
                        text: "-5°"
                        font.pointSize: 16
                        font.bold: true
                        onReleased: {
                            if (backAngle.angle > 5) {
                            backAngle.angle = backAngle.angle - 5
                            }
                        }
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
                        y: 1
                        width: 59
                        height: 43
                        text: "+5°"
                        font.pointSize: 16
                        font.bold: true
                        onReleased: {
                            if (backAngle.angle < 90) {
                            backAngle.angle = backAngle.angle + 5
                            }
                        }
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
                        id: backAngleIndicatorText
                        x: 0
                        y: 0
                        width: 90
                        height: 45
                        text: backAngle.angle + "°"
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
                    text: "УГОЛ ПОВОРОТА"
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
                z: 10
                width: 346
                height: 450
                color: "#ffffff"
                border.width: 1

                ListView {
                    id: backLogsView
                    x: 3
                    y: 0
                    width: 343
                    height: parent.height
                    clip: true
                    model: viewmodel.udp.backLogs

                    delegate: Text {
                        text: modelData
                        color: "black"
                        font.pixelSize: 14
                        wrapMode: Text.Wrap
                        width: backLogsView.width - 7
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }
                }
            }

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
                    enabled: (viewmodel.dvrip.backExpo !== null
                              && viewmodel.dvrip.backExpo !== undefined
                              && backAutoExpoButton.checked)
                    opacity: enabled ? 1.0 : 0.5
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
                            text: "Выдержка"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            opacity: backExposition.opacity
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
                            enabled: backExposition.enabled
                            opacity: backExposition.opacity
                            onReleased: {
                                backExpositionIndicatorText.text = (parseInt(backExpositionIndicatorText.text) || 0) - 1
                                backExpositionIndicatorText.commitValue()
                            }
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
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                            wrapMode: Text.NoWrap
                            selectByMouse: true
                            focus: false
                            text: (viewmodel.dvrip.backExpo !== null && viewmodel.dvrip.backExpo !== undefined) ? viewmodel.dvrip.backExpo : "10"
                            enabled: backExposition.enabled
                            opacity: backExposition.opacity

                            property int lastValue: parseInt(text) || 10

                            onTextChanged: {
                                var clean = text.replace(/[^0-9]/g, "")
                                if (clean !== text) {
                                    text = clean
                                }
                                if (text.startsWith("0")) {
                                    text = "1"
                                }
                            }

                            Keys.onReturnPressed: focus = false

                            onFocusChanged: {
                                if (!focus) {
                                    commitValue()
                                }
                            }

                            function commitValue() {
                                let val = parseInt(text.trim())
                                if (!isNaN(val)) {
                                    lastValue = val
                                    viewmodel.dvrip.forward_int_command("back", "set_exposure", val)
                                } else {
                                    text = lastValue
                                }
                            }
                        }
                        Connections {
                            target: viewmodel.dvrip
                            function onBackExpoChanged() {
                                if (!backExpositionIndicatorText.focus && typeof viewmodel.dvrip.backExpo !== "undefined") {
                                    backExpositionIndicatorText.text = viewmodel.dvrip.backExpo.toString()
                                }
                            }
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
                            enabled: backExposition.enabled
                            opacity: backExposition.opacity
                            onReleased: {
                                backExpositionIndicatorText.text = (parseInt(backExpositionIndicatorText.text) || 0) + 1
                                backExpositionIndicatorText.commitValue()
                            }
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
                    enabled: (viewmodel.dvrip.backGain !== null
                              && viewmodel.dvrip.backGain !== undefined
                              && backAutoISOButton.checked)
                    opacity: enabled ? 1.0 : 0.5
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
                            text: "Gain"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            enabled: backISO.enabled
                            opacity: backISO.opacity
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
                            text: "-"
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                            enabled: backISO.enabled
                            opacity: backISO.opacity
                            onReleased: {
                                backISOIndicatorText.text = (parseInt(backISOIndicatorText.text) || 0) - 5
                                backISOIndicatorText.commitValue()
                            }
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
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                            wrapMode: Text.NoWrap
                            selectByMouse: true
                            focus: false
                            text: (viewmodel.dvrip.backGain !== null && viewmodel.dvrip.backGain !== undefined) ? viewmodel.dvrip.backGain : "50"
                            enabled: backISO.enabled
                            opacity: backISO.opacity

                            property int lastValue: parseInt(text) || 50

                            onTextChanged: {
                                var clean = text.replace(/[^0-9]/g, "")
                                if (clean !== text) {
                                    text = clean
                                }
                                if (parseInt(text) > 100) {
                                    text = "100"
                                }
                                if (parseInt(text) < 0) {
                                    text = "0"
                                }
                            }

                            Keys.onReturnPressed: focus = false

                            onFocusChanged: {
                                if (!focus) {
                                    commitValue()
                                }
                            }

                            function commitValue() {
                                let val = parseInt(text.trim())
                                if (!isNaN(val)) {
                                    lastValue = val
                                    viewmodel.dvrip.forward_int_command("back", "set_gain", val)
                                } else {
                                    text = lastValue
                                }
                            }
                        }
                        Connections {
                            target: viewmodel.dvrip
                            function onBackGainChanged() {
                                if (!backISOIndicatorText.focus && typeof viewmodel.dvrip.backGain !== "undefined") {
                                    backISOIndicatorText.text = viewmodel.dvrip.backGain.toString()
                                }
                            }
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
                            text: "+"
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                            enabled: backISO.enabled
                            opacity: backISO.opacity
                            onReleased: {
                                backISOIndicatorText.text = (parseInt(backISOIndicatorText.text) || 0) + 5
                                backISOIndicatorText.commitValue()
                            }
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
                        text: "Яркость"
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
                            if (!enabled)
                                return;

                            if (value === 50 && (viewmodel.onvif.backBrightness === null || viewmodel.onvif.backBrightness === undefined))
                                        return;

                            viewmodel.onvif.forward_float_command("back", "set_brightness", value)
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
                            if (!enabled)
                                return;

                            if (value === 50 && (viewmodel.onvif.backContrast === null || viewmodel.onvif.backContrast === undefined))
                                        return;

                            viewmodel.onvif.forward_float_command("back", "set_contrast", value)
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
                        text: "Насыщенность"
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
                            if (!enabled)
                                return;

                            if (value === 50 && (viewmodel.onvif.backSaturation === null || viewmodel.onvif.backSaturation === undefined))
                                        return;

                            viewmodel.onvif.forward_float_command("back", "set_saturation", value)
                        }
                        enabled: viewmodel.onvif.backSaturation !== null && viewmodel.onvif.backSaturation !== undefined
                        to: 100
                        from: 0
                    }
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
                    id: backAutoExpo
                    x: 35
                    y: 10
                    width: 190
                    height: 30
                    color: "#ffffff"
                    Switch {
                        id: backAutoExpoButton
                        x: 120
                        y: 0
                        width: 70
                        height: 30
                        display: AbstractButton.IconOnly
                        checked: (viewmodel.dvrip.backAutoExpo !== null && viewmodel.dvrip.backAutoExpo !== undefined) ? viewmodel.dvrip.backAutoExpo : false
                        enabled: viewmodel.dvrip.backAutoExpo !== null && viewmodel.dvrip.backAutoExpo !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onToggled: {
                            viewmodel.dvrip.forward_bool_command("back", "set_manual_exposure", checked)
                        }
                    }

                    Text {
                        id: backAutoExpoText
                        x: 0
                        y: 0
                        width: 115
                        height: 30
                        text: "Выдержка"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                        opacity: backAutoExpoButton.enabled ? 1.0 : 0.5
                    }
                }

                Rectangle {
                    id: backAutoISO
                    x: 45
                    y: 50
                    width: 180
                    height: 30
                    color: "#ffffff"
                    Switch {
                        id: backAutoISOButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        display: AbstractButton.IconOnly
                        checked: (viewmodel.dvrip.backAutoGain !== null && viewmodel.dvrip.backAutoGain !== undefined) ? viewmodel.dvrip.backAutoGain : false
                        enabled: viewmodel.dvrip.backAutoGain !== null && viewmodel.dvrip.backAutoGain !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onToggled: {
                            viewmodel.dvrip.forward_bool_command("back", "set_auto_gain", checked)
                        }
                    }

                    Text {
                        id: backAutoISOText
                        width: 110
                        height: 30
                        text: "Усиление"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                        opacity: backAutoISOButton.enabled ? 1.0 : 0.5

                    }
                }

                Rectangle {
                    id: backMirror
                    x: 45
                    y: 90
                    width: 180
                    height: 30
                    color: "#ffffff"
                    Switch {
                        id: backMirrorButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        display: AbstractButton.IconOnly
                        checked: (viewmodel.dvrip.backMirror !== null && viewmodel.dvrip.backMirror !== undefined) ? viewmodel.dvrip.backMirror : false
                        enabled: viewmodel.dvrip.backMirror !== null && viewmodel.dvrip.backMirror !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onToggled: {
                            viewmodel.dvrip.forward_bool_command("back", "set_mirror", checked)
                        }
                    }

                    Text {
                        id: backMirrorText
                        width: 110
                        height: 30
                        text: "Отзеркалить"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                        opacity: backMirrorButton.enabled ? 1.0 : 0.5

                    }
                }

                Rectangle {
                    id: backFlip
                    x: 45
                    y: 130
                    width: 180
                    height: 30
                    color: "#ffffff"
                    Switch {
                        id: backFlipButton
                        x: 110
                        y: 0
                        width: 70
                        height: 30
                        display: AbstractButton.IconOnly
                        checked: (viewmodel.dvrip.backFlip !== null && viewmodel.dvrip.backFlip !== undefined) ? viewmodel.dvrip.backFlip : false
                        enabled: viewmodel.dvrip.backFlip !== null && viewmodel.dvrip.backFlip !== undefined
                        opacity: enabled ? 1.0 : 0.5
                        onToggled: {
                            viewmodel.dvrip.forward_bool_command("back", "set_flip", checked)
                        }
                    }

                    Text {
                        id: backFlipText
                        width: 110
                        height: 30
                        text: "Перевернуть"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                        opacity: backFlipButton.enabled ? 1.0 : 0.5

                    }
                }

                Rectangle {
                    id: backFPS
                    x: 45
                    y: 170
                    width: 180
                    height: 60
                    color: "#ffffff"
                    enabled: (viewmodel.dvrip.backFps !== null
                              && viewmodel.dvrip.backFps !== undefined)
                    opacity: enabled ? 1.0 : 0.5
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
                            text: "FPS"
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
                            text: "-"
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                            enabled: backFPS.enabled
                            opacity: backFPS.opacity
                            onReleased: {
                                backFPSIndicatorText.text = (parseInt(backFPSIndicatorText.text) || 0) - 5
                                backFPSIndicatorText.commitValue()
                            }
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
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                            wrapMode: Text.NoWrap
                            selectByMouse: true
                            focus: false
                            text: (viewmodel.dvrip.backFps !== null && viewmodel.dvrip.backFps !== undefined) ? viewmodel.dvrip.backFps : "25"
                            enabled: backFPS.enabled
                            opacity: backFPS.opacity

                            property int lastValue: parseInt(text) || 25

                            onTextChanged: {
                                var clean = text.replace(/[^0-9]/g, "")
                                if (clean !== text) {
                                    text = clean
                                }
                                if (parseInt(text) > 100) {
                                    text = "100"
                                }
                                if (parseInt(text) < 1) {
                                    text = "10"
                                }
                            }

                            Keys.onReturnPressed: focus = false

                            onFocusChanged: {
                                if (!focus) {
                                    commitValue()
                                }
                            }

                            function commitValue() {
                                let val = parseInt(text.trim())
                                if (!isNaN(val)) {
                                    lastValue = val
                                    viewmodel.dvrip.forward_int_command("back", "set_fps", val)
                                } else {
                                    text = lastValue
                                }
                            }
                        }
                        Connections {
                            target: viewmodel.dvrip
                            function onBackFpsChanged() {
                                if (!backFPSIndicatorText.focus && typeof viewmodel.dvrip.backFps !== "undefined") {
                                    backFPSIndicatorText.text = viewmodel.dvrip.backFps.toString()
                                }
                            }
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
                            text: "+"
                            layer.smooth: true
                            font.pointSize: 18
                            font.bold: true
                            enabled: backFPS.enabled
                            opacity: backFPS.opacity
                            onReleased: {
                                backFPSIndicatorText.text = (parseInt(backFPSIndicatorText.text) || 0) + 5
                                backFPSIndicatorText.commitValue()
                            }
                        }
                    }
                }


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
