import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root

    width: 1920
    height: 1080
    property var dvrip: viewmodel.dvrip
    property var onvif: viewmodel.onvif
    property var udp: viewmodel.udp

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
            property var settings: viewmodel.udp.frontSettings

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

                    TextInput {
                        id: frontIpControllerEdit
                        width: 160
                        height: 30
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        inputMask: "000.000.0.000"
                        focus: false
                        text: frontSettings.settings && frontSettings.settings["ip"] ? frontSettings.settings["ip"] : "192.168.1."

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            viewmodel.udp.forward_str_command("front", "set_arduino_ip", frontIpControllerEdit.text)
                            controller.update_settings()
                        }
                    }
                    Connections {
                        target: viewmodel.udp
                        function onFrontSettingsChanged() {
                            if (!frontIpControllerEdit.focus) {
                                frontIpControllerEdit.text = viewmodel.udp.frontSettings.ip.toString()
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            frontIpControllerEdit.forceActiveFocus()
                            frontIpControllerEdit.cursorPosition = frontIpControllerEdit.text.length
                        }
                    }
                }

                Text {
                    id: frontIpControllerText
                    x: 220
                    y: 0
                    width: 210
                    height: 30
                    text: "IP-адрес контроллера"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: frontCameraIp
                x: 435
                y: 30
                width: 434
                height: 30
                color: "#ffffff"

                Rectangle {
                    id: frontCameraIpForm
                    x: 30
                    y: 0
                    width: 160
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextInput {
                        id: frontCameraIpEdit
                        width: 160
                        height: 30
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        inputMask: "000.000.0.000"
                        focus: false
                        text: root.onvif && root.onvif["frontIp"] ? root.onvif["frontIp"] : "192.168.1."

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            viewmodel.onvif.forward_str_command("front", "set_ip", frontCameraIpEdit.text)
                            viewmodel.dvrip.forward_str_command("front", "set_ip", frontCameraIpEdit.text)
                        }
                    }
                    Connections {
                        target: viewmodel.onvif
                        function onFrontIpChanged() {
                            if (!frontCameraIpEdit.focus) {
                                frontCameraIpEdit.text = viewmodel.onvif.frontIp.toString()
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            frontCameraIpEdit.forceActiveFocus()
                            frontCameraIpEdit.cursorPosition = frontCameraIpEdit.text.length
                        }
                    }
                }

                Text {
                    id: frontCameraIpText
                    x: 220
                    y: 0
                    width: 210
                    height: 30
                    text: "IP-адрес камеры"
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
                        text: root.udp && root.udp.frontSettings["water_pressure"] ? root.udp.frontSettings["water_pressure"] : "2.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 10

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("front", "set_water_pressure", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onFrontSettingsChanged() {
                                if (!frontWaterPressLimitEdit.focus) {
                                    frontWaterPressLimitEdit.text = viewmodel.udp.frontSettings.water_pressure.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: frontWaterPressLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел давления воды (кгс/см²)"
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
                        text: root.udp && root.udp.frontSettings["air_pressure"] ? root.udp.frontSettings["air_pressure"] : "2.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 10

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("front", "set_air_pressure", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onFrontSettingsChanged() {
                                if (!frontAirPressLimitEdit.focus) {
                                    frontAirPressLimitEdit.text = viewmodel.udp.frontSettings.air_pressure.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: frontAirPressLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел давления воздуха (кгс/см²)"
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
                        text: root.udp && root.udp.frontSettings["air_temp"] ? root.udp.frontSettings["air_temp"] : "60.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 50

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("front", "set_air_temp", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onFrontSettingsChanged() {
                                if (!frontAirTempLimitEdit.focus) {
                                    frontAirTempLimitEdit.text = viewmodel.udp.frontSettings.air_temp.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: frontAirTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел температуры воздуха (°С)"
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
                        text: root.udp && root.udp.frontSettings["water_temp"] ? root.udp.frontSettings["water_temp"] : "50.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 50

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("front", "set_water_temp", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onFrontSettingsChanged() {
                                if (!frontWaterTempLimitEdit.focus) {
                                    frontWaterTempLimitEdit.text = viewmodel.udp.frontSettings.water_temp.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: frontWaterTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел температуры воды (°С)"
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
                        text: root.udp && root.udp.frontSettings["out_temp"] ? root.udp.frontSettings["out_temp"] : "70.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 50

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("front", "set_out_temp", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onFrontSettingsChanged() {
                                if (!frontOutTempLimitEdit.focus) {
                                    frontOutTempLimitEdit.text = viewmodel.udp.frontSettings.out_temp.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: frontOutTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел температуры сброса (°С)"
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
                        text: root.udp && root.udp.frontSettings["wp_temp"] ? root.udp.frontSettings["wp_temp"] : "70.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 50

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("front", "set_wp_temp", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onFrontSettingsChanged() {
                                if (!frontWpTempLimitEdit.focus) {
                                    frontWpTempLimitEdit.text = viewmodel.udp.frontSettings.wp_temp.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: frontWpTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел температуры рабочей части (°С)"
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
                    text: "Поменять направление к 0°"
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
                    onToggled: viewmodel.udp.forward_command("front", "change_motor_dir")
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
            property var settings: viewmodel.udp.backSettings

            Rectangle {
                id: backIpController
                x: 1
                y: 30
                width: 434
                height: 30
                color: "#ffffff"
                border.width: 0
                Rectangle {
                    id: backIpControllerForm
                    x: 30
                    y: 0
                    width: 160
                    height: 30
                    color: "#ffffff"
                    border.width: 1

                    TextInput {
                        id: backIpControllerEdit
                        width: 160
                        height: 30
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        inputMask: "000.000.0.000"
                        focus: false
                        text: backSettings.settings && backSettings.settings["ip"] ? backSettings.settings["ip"] : "192.168.1."

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            viewmodel.udp.forward_str_command("back", "set_arduino_ip", backIpControllerEdit.text)
                            controller.update_settings()
                        }
                    }
                    Connections {
                        target: viewmodel.udp
                        function onBackSettingsChanged() {
                            if (!backIpControllerEdit.focus) {
                                backIpControllerEdit.text = viewmodel.udp.backSettings.ip.toString()
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            backIpControllerEdit.forceActiveFocus()
                            backIpControllerEdit.cursorPosition = backIpControllerEdit.text.length
                        }
                    }
                }

                Text {
                    id: backIpControllerText
                    x: 220
                    y: 0
                    width: 210
                    height: 30
                    text: "IP-адрес контроллера"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: backCameraIp
                x: 435
                y: 30
                width: 434
                height: 30
                color: "#ffffff"

                Rectangle {
                    id: backCameraIpForm
                    x: 30
                    y: 0
                    width: 160
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    enabled: backCameraIp.enabled
                    opacity: backCameraIp.opacity
                    TextInput {
                        id: backCameraIpEdit
                        width: 160
                        height: 30
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        inputMask: "000.000.0.000"
                        focus: false
                        enabled: backCameraIp.enabled
                        opacity: backCameraIp.opacity
                        text: root.onvif && root.onvif["backIp"] ? root.onvif["backIp"] : "192.168.1."

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            viewmodel.onvif.forward_str_command("back", "set_ip", backCameraIpEdit.text)
                            viewmodel.dvrip.forward_str_command("back", "set_ip", backCameraIpEdit.text)
                        }
                    }
                    Connections {
                        target: viewmodel.onvif
                        function onBackIpChanged() {
                            if (!backCameraIpEdit.focus) {
                                backCameraIpEdit.text = viewmodel.onvif.backIp.toString()
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            backCameraIpEdit.forceActiveFocus()
                            backCameraIpEdit.cursorPosition = backCameraIpEdit.text.length
                        }
                    }
                }


                Text {
                    id: backCameraIpText
                    x: 220
                    y: 0
                    width: 210
                    height: 30
                    text: "IP-адрес камеры"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }


            Rectangle {
                id: backWaterPressLimit
                x: 1
                y: 90
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: backWaterPressLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: backWaterPressLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: root.udp && root.udp.backSettings["water_pressure"] ? root.udp.backSettings["water_pressure"] : "2.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 10

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("back", "set_water_pressure", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onBackSettingsChanged() {
                                if (!backWaterPressLimitEdit.focus) {
                                    backWaterPressLimitEdit.text = viewmodel.udp.backSettings.water_pressure.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: backWaterPressLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел давления воды (кгс/см²)"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }


            Rectangle {
                id: backAirPressLimit
                x: 434
                y: 90
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: backAirPressLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: backAirPressLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: root.udp && root.udp.backSettings["air_pressure"] ? root.udp.backSettings["air_pressure"] : "2.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 10

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("back", "set_air_pressure", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onBackSettingsChanged() {
                                if (!backAirPressLimitEdit.focus) {
                                    backAirPressLimitEdit.text = viewmodel.udp.backSettings.air_pressure.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: frontAirPressLimitText1
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел давления воздуха (кгс/см²)"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }


            Rectangle {
                id: backAirTempLimit
                x: 1
                y: 150
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: backAirTempLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: backAirTempLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: root.udp && root.udp.backSettings["air_temp"] ? root.udp.backSettings["air_temp"] : "60.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 50

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("back", "set_air_temp", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onBackSettingsChanged() {
                                if (!backAirTempLimitEdit.focus) {
                                    backAirTempLimitEdit.text = viewmodel.udp.backSettings.air_temp.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: backAirTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел температуры воздуха (°С)"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }


            Rectangle {
                id: backWaterTempLimit
                x: 1
                y: 210
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: backWaterTempLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: backWaterTempLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: root.udp && root.udp.backSettings["water_temp"] ? root.udp.backSettings["water_temp"] : "50.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 50

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("back", "set_water_temp", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onBackSettingsChanged() {
                                if (!backWaterTempLimitEdit.focus) {
                                    backWaterTempLimitEdit.text = viewmodel.udp.backSettings.water_temp.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: backWaterTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел температуры воды (°С)"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }


            Rectangle {
                id: backOutTempLimit
                x: 1
                y: 270
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: backOutTempLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: backOutTempLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: root.udp && root.udp.backSettings["out_temp"] ? root.udp.backSettings["out_temp"] : "70.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 50

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("back", "set_out_temp", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onBackSettingsChanged() {
                                if (!backOutTempLimitEdit.focus) {
                                    backOutTempLimitEdit.text = viewmodel.udp.backSettings.out_temp.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: backOutTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел температуры сброса (°С)"
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
                        text: viewmodel && viewmodel.currentName ? viewmodel.currentName : "Система 1"
                        font.pixelSize: 22
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                viewmodel.rename_system(systemNameEdit.text)
                            }
                        }
                        Connections {
                            target: viewmodel
                            function onCurrentNameChanged() {
                                if (!systemNameEdit.focus) {
                                    systemNameEdit.text = viewmodel.currentName.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: systemNameText
                    x: 0
                    y: 30
                    width: 270
                    height: 30
                    text: "Название системы"
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }


            Rectangle {
                id: backWpTempLimit
                x: 1
                y: 330
                width: 434
                height: 30
                color: "#ffffff"
                Rectangle {
                    id: backWpTempLimitForm
                    x: 30
                    y: 0
                    width: 90
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    TextEdit {
                        id: backWpTempLimitEdit
                        x: 0
                        y: 0
                        width: 90
                        height: 30
                        text: root.udp && root.udp.backSettings["wp_temp"] ? root.udp.backSettings["wp_temp"] : "70.0"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        focus: false

                        property real lastValue: parseFloat(text) || 50

                        onTextChanged: {
                            var clean = text
                            clean = clean.replace(",", ".")
                            clean = clean.replace(/[^0-9.]/g, "")
                            var firstDot = clean.indexOf(".")
                            if (firstDot !== -1) {
                                var before = clean.substring(0, firstDot + 1)
                                var after = clean.substring(firstDot + 1).replace(/\./g, "")
                                clean = before + after
                            }

                            if (clean !== text) {
                                text = clean
                            }
                        }

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            let val = parseFloat(text.trim())
                            if (!isNaN(val)) {
                                lastValue = val
                                viewmodel.udp.forward_float_command("back", "set_wp_temp", val)
                            } else {
                                text = lastValue
                            }
                        }
                        Connections {
                            target: viewmodel.udp
                            function onBackSettingsChanged() {
                                if (!backWpTempLimitEdit.focus) {
                                    backWpTempLimitEdit.text = viewmodel.udp.backSettings.wp_temp.toString()
                                }
                            }
                        }
                    }
                }

                Text {
                    id: backWpTempLimitText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Предел температуры рабочей части (°С)"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
            }



            Rectangle {
                id: backMotorDir
                x: 434
                y: 150
                width: 434
                height: 30
                color: "#ffffff"
                Text {
                    id: backMotorDirText
                    x: 135
                    y: 0
                    width: 299
                    height: 30
                    text: "Поменять направление к 0°"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }

                SwitchDelegate {
                    id: backMotorDirSwitch
                    x: 39
                    y: 0
                    width: 71
                    height: 30
                    display: AbstractButton.IconOnly
                    onToggled: viewmodel.udp.forward_command("back", "change_motor_dir")
                }
            }

            Button {
                id: deleteSystemButton
                x: 570
                y: 375
                width: 270
                height: 45
                text: "УДАЛИТЬ СИСТЕМУ"
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
                    TextInput {
                        id: systemIpAdressEdit
                        width: 270
                        height: 30
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        inputMask: "000.000.0.000"
                        focus: false
                        text: backSettings.settings && backSettings.settings["sys_ip"] ? backSettings.settings["sys_ip"] : "192.168.1."

                        Keys.onReturnPressed: focus = false

                        onFocusChanged: {
                            if (!focus) {
                                commitValue()
                            }
                        }

                        function commitValue() {
                            viewmodel.udp.forward_str_command("front", "set_system_ip", systemIpAdressEdit.text)
                            viewmodel.udp.forward_str_command("back", "set_system_ip", systemIpAdressEdit.text)
                        }
                    }
                    Connections {
                        target: viewmodel.udp
                        function onBackSettingsChanged() {
                            if (!backIpControllerEdit.focus) {
                                backIpControllerEdit.text = viewmodel.udp.backSettings.ip.toString()
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            systemIpAdressEdit.forceActiveFocus()
                            systemIpAdressEdit.cursorPosition = systemIpAdressEdit.text.length
                        }
                    }
                }



                Text {
                    id: systemIpAdressText
                    x: 0
                    y: 30
                    width: 270
                    height: 30
                    text: "IP-адрес компьютера"
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

            }
        }
    }
}
