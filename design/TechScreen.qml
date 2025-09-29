import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15

Item {
    id: root

    width: 1920
    height: 1080
    property int chunkSize: 1

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
            id: frontRectangle
            x: 0
            y: 570
            width: 871
            height: 450
            color: "#ffffff"
            border.width: 1

            ChartView {
                id: frontTempChart
                width: 435
                height: 360
                antialiasing: true
                legend.visible: false
                property var tempList: viewmodel.udp.frontTempChart
                property var tempHistory: viewmodel.udp.frontTempHistory
                property int frontTempLoadId: 0
                property int index: 0

                ValueAxis {
                    id: frontTempTimeAxis
                    min: frontTempChart.index - 360
                    max: frontTempChart.index
                    tickCount: 13
                    titleText: "Минут назад"
                    titleFont.family: "Arial"
                    titleFont.pointSize: 12
                    titleFont.bold: true
                }

                ValueAxis {
                    id: frontTempAxis
                    min: 0
                    max: 0
                    tickCount: 11
                    labelFormat: "%.1f"
                    titleText: "Температура °C"
                    titleFont.family: "Arial"
                    titleFont.pointSize: 12
                    titleFont.bold: true
                }

                SplineSeries {
                    id: frontTempAirChart
                    name: "Воздух"
                    axisX: frontTempTimeAxis
                    axisY: frontTempAxis
                    color: "orange"
                    width: 3
                }

                SplineSeries {
                    id: frontTempWaterChart
                    name: "Вода"
                    axisX: frontTempTimeAxis
                    axisY: frontTempAxis
                    color: "light blue"
                    width: 3
                }
                SplineSeries {
                    id: frontTempOutChart
                    name: "Сброс"
                    axisX: frontTempTimeAxis
                    axisY: frontTempAxis
                    color: "pink"
                    width: 3
                }
                SplineSeries {
                    id: frontTempCameraChart
                    name: "Камера"
                    axisX: frontTempTimeAxis
                    axisY: frontTempAxis
                    color: "light green"
                    width: 3
                }

                Connections {
                    target: viewmodel.udp
                    function onFrontTempChartChanged() {
                        if (frontTempAirChart.count === 0) {
                            frontTempAxis.min = Math.min(frontTempChart.tempList[0] - 1, frontTempChart.tempList[1] - 1, frontTempChart.tempList[2] - 1, frontTempChart.tempList[3] - 1)
                        }
                        console.log('INDEX ==', frontTempChart.index)
                        frontTempAirChart.append(frontTempChart.index, frontTempChart.tempList[0])
                        frontTempWaterChart.append(frontTempChart.index, frontTempChart.tempList[1])
                        frontTempOutChart.append(frontTempChart.index, frontTempChart.tempList[2])
                        frontTempCameraChart.append(frontTempChart.index, frontTempChart.tempList[3])
                        frontTempChart.index += 1
                        frontTempAxis.min = Math.min(frontTempAxis.min, frontTempChart.tempList[0] - 1, frontTempChart.tempList[1] - 1, frontTempChart.tempList[2] - 1, frontTempChart.tempList[3] - 1)
                        frontTempAxis.max = Math.max(frontTempAxis.max, frontTempChart.tempList[0] + 1, frontTempChart.tempList[1] + 1, frontTempChart.tempList[2] + 1, frontTempChart.tempList[3] + 1)
                    }
                    function onFrontTempHistoryAdded() {
                        var currentLoadId = ++frontTempChart.frontTempLoadId
                        var chunkSize = root.chunkSize
                        var idx = 0
                        var history = frontTempChart.tempHistory
                        frontTempAxis.min = Math.min(history.air[idx].y - 1, history.water[idx].y - 1, history.out[idx].y - 1, history.wp[idx].y - 1)
                        frontTempAxis.max = Math.max(history.air[idx].y + 1, history.water[idx].y + 1, history.out[idx].y + 1, history.wp[idx].y + 1)


                        function appendChunk() {
                            if (currentLoadId !== frontTempChart.frontTempLoadId) return
                            var end = Math.min(idx + chunkSize, history.air.length)
                            for (; idx < end; idx++) {
                                frontTempAirChart.append(history.air[idx].x, history.air[idx].y)
                                frontTempWaterChart.append(history.water[idx].x, history.water[idx].y)
                                frontTempOutChart.append(history.out[idx].x, history.out[idx].y)
                                frontTempCameraChart.append(history.wp[idx].x, history.wp[idx].y)
                                frontTempAxis.min = Math.min(frontTempAxis.min, history.air[idx].y - 1, history.water[idx].y - 1, history.out[idx].y - 1, history.wp[idx].y - 1)
                                frontTempAxis.max = Math.max(frontTempAxis.max, history.air[idx].y + 1, history.water[idx].y + 1, history.out[idx].y + 1, history.wp[idx].y + 1)
                                frontTempChart.index = history.air[idx].x
                            }

                            if (idx < history.air.length) {
                                Qt.callLater(appendChunk)
                            }
                        }

                        frontTempAirChart.clear()
                        frontTempWaterChart.clear()
                        frontTempOutChart.clear()
                        frontTempCameraChart.clear()
                        appendChunk()
                    }
                }

                Rectangle {
                    id: frontTempTimeAxisLabels
                    x: 75
                    y: 290
                    z: 10
                    width: 330
                    height: 20
                    color: "#ffffff"

                    Text {
                        id: t60
                        x: 8
                        y: 0
                        width: 24
                        height: 20
                        text: "60"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t55
                        x: 33
                        y: 0
                        width: 24
                        height: 20
                        text: "55"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t50
                        x: 58
                        y: 0
                        width: 24
                        height: 20
                        text: "50"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t45
                        x: 83
                        y: 0
                        width: 24
                        height: 20
                        text: "45"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t40
                        x: 108
                        y: 0
                        width: 24
                        height: 20
                        text: "40"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t35
                        x: 133
                        y: 0
                        width: 24
                        height: 20
                        text: "35"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t30
                        x: 158
                        y: 0
                        width: 24
                        height: 20
                        text: "30"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t25
                        x: 183
                        y: 0
                        width: 24
                        height: 20
                        text: "25"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t20
                        x: 208
                        y: 0
                        width: 24
                        height: 20
                        text: "20"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t15
                        x: 233
                        y: 0
                        width: 24
                        height: 20
                        text: "15"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t10
                        x: 258
                        y: 0
                        width: 24
                        height: 20
                        text: "10"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t5
                        x: 283
                        y: 0
                        width: 24
                        height: 20
                        text: " 5"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t0
                        x: 308
                        y: 0
                        width: 24
                        height: 20
                        text: " 0"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }


            ChartView {
                id: frontPressChart
                x: 435
                y: 0
                width: 435
                height: 360
                legend.visible: false
                antialiasing: true
                property var pressList: viewmodel.udp.frontPressChart
                property var pressHistory: viewmodel.udp.frontPressHistory
                property int frontPressLoadId: 0
                property int index: 0
                ValueAxis {
                    id: frontPressTimeAxis
                    titleText: "Минут назад"
                    titleFont.pointSize: 12
                    titleFont.family: "Arial"
                    titleFont.bold: true
                    tickCount: 13
                    min: frontTempChart.index - 360
                    max: frontTempChart.index
                    labelFormat: "%d"
                }

                ValueAxis {
                    id: frontPressAxis
                    titleText: "Давление кгс/см²"
                    titleFont.pointSize: 12
                    titleFont.family: "Arial"
                    titleFont.bold: true
                    tickCount: 11
                }

                SplineSeries {
                    id: frontPressAirChart
                    name: "Воздух"
                    width: 3
                    color: "#d3d3d3"
                    axisY: frontPressAxis
                    axisX: frontPressTimeAxis
                }

                SplineSeries {
                    id: frontPressWaterChart
                    name: "Вода"
                    width: 3
                    color: "#add8e6"
                    axisY: frontPressAxis
                    axisX: frontPressTimeAxis
                }

                Connections {
                    target: viewmodel.udp
                    function onFrontPressChartChanged() {
                        if (frontPressAirChart.count === 0) {
                            frontPressAxis.min = Math.min(frontPressChart.pressList[0] - 1, frontPressChart.pressList[1] - 1)
                        }
                        frontPressAirChart.append(frontTempChart.index, frontPressChart.pressList[1])
                        frontPressWaterChart.append(frontTempChart.index, frontPressChart.pressList[0])
                        frontPressChart.index += 1
                        frontPressAxis.min = Math.min(frontPressAxis.min, frontPressChart.pressList[0] - 1, frontPressChart.pressList[1] - 1)
                        frontPressAxis.max = Math.max(frontPressAxis.max, frontPressChart.pressList[0] + 1, frontPressChart.pressList[1] + 1)
                    }
                    function onFrontPressHistoryAdded() {
                        var currentLoadId = ++frontPressChart.frontPressLoadId
                        var chunkSize = root.chunkSize
                        var idx = 0
                        var history = frontPressChart.pressHistory
                        frontPressAxis.min = Math.min(history.air[idx].y - 1, history.water[idx].y - 1)
                        frontPressAxis.max = Math.max(history.air[idx].y + 1, history.water[idx].y + 1)


                        function appendChunk() {
                            if (currentLoadId !== frontPressChart.frontPressLoadId) return
                            var end = Math.min(idx + chunkSize, history.air.length)
                            for (; idx < end; idx++) {
                                frontPressAirChart.append(history.air[idx].x, history.air[idx].y)
                                frontPressWaterChart.append(history.water[idx].x, history.water[idx].y)
                                frontPressAxis.min = Math.min(frontPressAxis.min, history.air[idx].y - 1, history.water[idx].y - 1)
                                frontPressAxis.max = Math.max(frontPressAxis.max, history.air[idx].y + 1, history.water[idx].y + 1)
                                frontPressChart.index = history.air[idx].x
                            }

                            if (idx < history.air.length) {
                                Qt.callLater(appendChunk)
                            }
                        }

                        frontPressAirChart.clear()
                        frontPressWaterChart.clear()
                        appendChunk()
                    }
                }

                Rectangle {
                    id: frontPressTimeAxisLabels
                    x: 75
                    y: 290
                    width: 330
                    height: 20
                    color: "#ffffff"
                    z: 10
                    Text {
                        id: t62
                        x: 8
                        y: 0
                        width: 24
                        height: 20
                        text: "60"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t57
                        x: 33
                        y: 0
                        width: 24
                        height: 20
                        text: "55"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t52
                        x: 58
                        y: 0
                        width: 24
                        height: 20
                        text: "50"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t47
                        x: 83
                        y: 0
                        width: 24
                        height: 20
                        text: "45"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t42
                        x: 108
                        y: 0
                        width: 24
                        height: 20
                        text: "40"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t37
                        x: 133
                        y: 0
                        width: 24
                        height: 20
                        text: " 35"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t32
                        x: 158
                        y: 0
                        width: 24
                        height: 20
                        text: " 30"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t27
                        x: 183
                        y: 0
                        width: 24
                        height: 20
                        text: "  25"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t22
                        x: 208
                        y: 0
                        width: 24
                        height: 20
                        text: "  20"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t17
                        x: 233
                        y: 0
                        width: 24
                        height: 20
                        text: "  15"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t12
                        x: 258
                        y: 0
                        width: 24
                        height: 20
                        text: "  10"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t7
                        x: 283
                        y: 0
                        width: 24
                        height: 20
                        text: "   5"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t2
                        x: 308
                        y: 0
                        width: 24
                        height: 20
                        text: "    0"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }


            Rectangle {
                id: frontTemps
                x: 1
                y: 360
                width: 435
                height: 89
                color: "#ffffff"
                border.width: 0
                property var tempList: viewmodel.udp.frontTemps
                Rectangle {
                    id: frontTempsTitle
                    x: 48
                    y: 0
                    width: 357
                    height: 30
                    color: "#ffffff"
                    border.width: 1

                    Text {
                        id: frontTempsTitleText
                        x: 0
                        y: 0
                        width: 357
                        height: 30
                        text: "Текущая температура °С"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Rectangle {
                    id: frontAirTemp
                    x: 48
                    y: 29
                    width: 90
                    height: 59
                    color: "#ffffff"

                    Rectangle {
                        id: frontAirTitle
                        width: 90
                        height: 30
                        color: "orange"
                        border.width: 1

                        Text {
                            id: frontAirTitleText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: "Воздух"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: frontAirValue
                        x: 0
                        y: 29
                        width: 90
                        height: 32
                        color: "#ffffff"
                        border.width: 1

                        Text {
                            id: frontAirValueText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: frontTemps.tempList[0]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }

                Rectangle {
                    id: frontWaterTemp
                    x: 137
                    y: 29
                    width: 90
                    height: 59
                    color: "#ffffff"

                    Rectangle {
                        id: frontWaterTitle
                        width: 90
                        height: 30
                        color: "light blue"
                        border.width: 1
                        Text {
                            id: frontWaterTitleText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: "Вода"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: frontWaterValue
                        x: 0
                        y: 29
                        width: 90
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: frontWaterValueText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: frontTemps.tempList[1]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }

                Rectangle {
                    id: frontOutTemp
                    x: 226
                    y: 29
                    width: 90
                    height: 59
                    color: "#ffffff"

                    Rectangle {
                        id: frontOutTitle
                        width: 90
                        height: 30
                        color: "pink"
                        border.width: 1
                        Text {
                            id: frontOutTitleText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: "Сброс"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: frontOutValue
                        x: 0
                        y: 29
                        width: 90
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: frontOutValueText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: frontTemps.tempList[2]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }

                Rectangle {
                    id: frontCameraTemp
                    x: 315
                    y: 29
                    width: 90
                    height: 59
                    color: "#ffffff"

                    Rectangle {
                        id: frontCameraTitle
                        width: 90
                        height: 30
                        color: "light green"
                        border.width: 1
                        Text {
                            id: frontCameraTitleText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: "Камера"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: frontCameraValue
                        x: 0
                        y: 29
                        width: 90
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: frontCameraValueText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: frontTemps.tempList[3]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }


            }


            Rectangle {
                id: frontPress
                x: 435
                y: 360
                width: 435
                height: 89
                color: "#ffffff"
                border.width: 0
                property var pressList: viewmodel.udp.frontPress
                Rectangle {
                    id: frontPressTitle
                    x: 48
                    y: 0
                    width: 356
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    Text {
                        id: frontPressTitleText
                        x: 0
                        y: 0
                        width: 356
                        height: 30
                        text: "Текущее давление кгс/см²"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Rectangle {
                    id: frontAirPress
                    x: 48
                    y: 29
                    width: 179
                    height: 59
                    color: "#ffffff"
                    Rectangle {
                        id: frontAirPressTitle
                        width: 179
                        height: 30
                        color: "light grey"
                        border.width: 1
                        Text {
                            id: frontAirPressTitleText
                            x: 0
                            y: 0
                            width: 179
                            height: 30
                            text: "Воздух"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: frontAirPressValue
                        x: 0
                        y: 29
                        width: 179
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: frontAirPressValueText
                            x: 0
                            y: 0
                            width: 179
                            height: 30
                            text: frontPress.pressList[0]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }

                Rectangle {
                    id: frontWaterPress
                    x: 226
                    y: 29
                    width: 178
                    height: 59
                    color: "#ffffff"
                    Rectangle {
                        id: frontWaterPressTitle
                        width: 178
                        height: 30
                        color: "light blue"
                        border.width: 1
                        Text {
                            id: frontWaterPressTitleText
                            x: 0
                            y: 0
                            width: 178
                            height: 30
                            text: "Вода"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: frontWaterPressValue
                        x: 0
                        y: 29
                        width: 178
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: frontWaterPressValueText
                            x: 0
                            y: 0
                            width: 178
                            height: 30
                            text: frontPress.pressList[1]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
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
            z: 10
            rotation: 0
        }

        Rectangle {
            id: backRectangle
            x: 1049
            y: 570
            width: 871
            height: 450
            color: "#ffffff"
            border.width: 1
            ChartView {
                id: backTempChart
                width: 435
                height: 360
                antialiasing: true
                legend.visible: false
                property var tempList: viewmodel.udp.backTempChart
                property var tempHistory: viewmodel.udp.backTempHistory
                property int backTempLoadId: 0
                property int index: 0

                ValueAxis {
                    id: backTempTimeAxis
                    min: backTempChart.index - 360
                    max: backTempChart.index
                    titleText: "Минут назад"
                    titleFont.pointSize: 12
                    titleFont.family: "Arial"
                    titleFont.bold: true
                    tickCount: 13
                }

                ValueAxis {
                    id: backTempAxis
                    titleText: "Температура °C"
                    titleFont.pointSize: 12
                    titleFont.family: "Arial"
                    titleFont.bold: true
                    tickCount: 11
                    min: 0
                    max: 0
                    labelFormat: "%.1f"
                }

                SplineSeries {
                    id: backTempAirChart
                    name: "Воздух"
                    width: 3
                    color: "#ffa500"
                    axisY: backTempAxis
                    axisX: backTempTimeAxis
                }

                SplineSeries {
                    id: backTempWaterChart
                    name: "Вода"
                    width: 3
                    color: "#add8e6"
                    axisY: backTempAxis
                    axisX: backTempTimeAxis
                }

                SplineSeries {
                    id: backTempOutChart
                    name: "Сброс"
                    width: 3
                    color: "#ffc0cb"
                    axisY: backTempAxis
                    axisX: backTempTimeAxis
                }

                SplineSeries {
                    id: backTempCameraChart
                    name: "Камера"
                    width: 3
                    color: "#90ee90"
                    axisY: backTempAxis
                    axisX: backTempTimeAxis
                }

                Connections {
                    target: viewmodel.udp
                    function onBackTempChartChanged() {
                        if (backTempAirChart.count === 0) {
                            backTempAxis.min = Math.min(backTempChart.tempList[0] - 1, backTempChart.tempList[1] - 1, backTempChart.tempList[2] - 1, backTempChart.tempList[3] - 1)
                        }
                        backTempAirChart.append(backTempChart.index, backTempChart.tempList[0])
                        backTempWaterChart.append(backTempChart.index, backTempChart.tempList[1])
                        backTempOutChart.append(backTempChart.index, backTempChart.tempList[2])
                        backTempCameraChart.append(backTempChart.index, backTempChart.tempList[3])
                        backTempChart.index += 1
                        backTempAxis.min = Math.min(backTempAxis.min, backTempChart.tempList[0] - 1, backTempChart.tempList[1] - 1, backTempChart.tempList[2] - 1, backTempChart.tempList[3] - 1)
                        backTempAxis.max = Math.max(backTempAxis.max, backTempChart.tempList[0] + 1, backTempChart.tempList[1] + 1, backTempChart.tempList[2] + 1, backTempChart.tempList[3] + 1)
                    }
                    function onBackTempHistoryAdded() {
                        var currentLoadId = ++backTempChart.backTempLoadId
                        var chunkSize = root.chunkSize
                        var idx = 0
                        var history = backTempChart.tempHistory
                        backTempAxis.min = Math.min(history.air[idx].y - 1, history.water[idx].y - 1, history.out[idx].y - 1, history.wp[idx].y - 1)
                        backTempAxis.max = Math.max(history.air[idx].y + 1, history.water[idx].y + 1, history.out[idx].y + 1, history.wp[idx].y + 1)


                        function appendChunk() {
                            if (currentLoadId !== backTempChart.backTempLoadId) return
                            var end = Math.min(idx + chunkSize, history.air.length)
                            for (; idx < end; idx++) {
                                backTempAirChart.append(history.air[idx].x, history.air[idx].y)
                                backTempWaterChart.append(history.water[idx].x, history.water[idx].y)
                                backTempOutChart.append(history.out[idx].x, history.out[idx].y)
                                backTempCameraChart.append(history.wp[idx].x, history.wp[idx].y)
                                backTempAxis.min = Math.min(backTempAxis.min, history.air[idx].y - 1, history.water[idx].y - 1, history.out[idx].y - 1, history.wp[idx].y - 1)
                                backTempAxis.max = Math.max(backTempAxis.max, history.air[idx].y + 1, history.water[idx].y + 1, history.out[idx].y + 1, history.wp[idx].y + 1)
                                backTempChart.index = history.air[idx].x
                            }

                            if (idx < history.air.length) {
                                Qt.callLater(appendChunk)
                            }
                        }

                        backTempAirChart.clear()
                        backTempWaterChart.clear()
                        backTempOutChart.clear()
                        backTempCameraChart.clear()
                        appendChunk()
                    }
                }

                Rectangle {
                    id: backTempTimeAxisLabels
                    x: 75
                    y: 290
                    width: 330
                    height: 20
                    color: "#ffffff"
                    z: 10
                    Text {
                        id: t61
                        x: 8
                        y: 0
                        width: 24
                        height: 20
                        text: "60"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t56
                        x: 33
                        y: 0
                        width: 24
                        height: 20
                        text: "55"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t51
                        x: 58
                        y: 0
                        width: 24
                        height: 20
                        text: "50"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t46
                        x: 83
                        y: 0
                        width: 24
                        height: 20
                        text: "45"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t41
                        x: 108
                        y: 0
                        width: 24
                        height: 20
                        text: "40"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t36
                        x: 133
                        y: 0
                        width: 24
                        height: 20
                        text: "35"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t31
                        x: 158
                        y: 0
                        width: 24
                        height: 20
                        text: "30"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t26
                        x: 183
                        y: 0
                        width: 24
                        height: 20
                        text: "25"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t21
                        x: 208
                        y: 0
                        width: 24
                        height: 20
                        text: "20"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t16
                        x: 233
                        y: 0
                        width: 24
                        height: 20
                        text: "15"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t11
                        x: 258
                        y: 0
                        width: 24
                        height: 20
                        text: "10"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t6
                        x: 283
                        y: 0
                        width: 24
                        height: 20
                        text: " 5"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t1
                        x: 308
                        y: 0
                        width: 24
                        height: 20
                        text: " 0"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            ChartView {
                id: backPressChart
                x: 435
                y: 0
                width: 435
                height: 360
                legend.visible: false
                antialiasing: true
                property var pressList: viewmodel.udp.backPressChart
                property var pressHistory: viewmodel.udp.backPressHistory
                property int backPressLoadId: 0
                property int index: 0
                ValueAxis {
                    id: backPressTimeAxis
                    titleText: "Минут назад"
                    titleFont.pointSize: 12
                    titleFont.family: "Arial"
                    titleFont.bold: true
                    tickCount: 13
                    min: backTempChart.index - 360
                    max: backTempChart.index
                    labelFormat: "%d"
                }

                ValueAxis {
                    id: backPressAxis
                    titleText: "Давление кгс/см²"
                    titleFont.pointSize: 12
                    titleFont.family: "Arial"
                    titleFont.bold: true
                    tickCount: 11
                }

                SplineSeries {
                    id: backPressAirChart
                    name: "Воздух"
                    width: 3
                    color: "#d3d3d3"
                    axisY: backPressAxis
                    axisX: backPressTimeAxis
                }

                SplineSeries {
                    id: backPressWaterChart
                    name: "Вода"
                    width: 3
                    color: "#add8e6"
                    axisY: backPressAxis
                    axisX: backPressTimeAxis
                }

                Connections {
                    target: viewmodel.udp
                    function onBackPressChartChanged() {
                        if (backPressAirChart.count === 0) {
                            backPressAxis.min = Math.min(backPressChart.pressList[0] - 1, backPressChart.pressList[1] - 1)
                        }
                        backPressAirChart.append(backPressChart.index, backPressChart.pressList[1])
                        backPressWaterChart.append(backPressChart.index, backPressChart.pressList[0])
                        backPressChart.index += 1
                        backPressAxis.min = Math.min(backPressAxis.min, backPressChart.pressList[0] - 1, backPressChart.pressList[1] - 1)
                        backPressAxis.max = Math.max(backPressAxis.max, backPressChart.pressList[0] + 1, backPressChart.pressList[1] + 1)
                    }
                    function onBackPressHistoryAdded() {
                        var currentLoadId = ++backPressChart.backPressLoadId
                        var chunkSize = root.chunkSize
                        var idx = 0
                        var history = backPressChart.pressHistory
                        backPressAxis.min = Math.min(history.air[idx].y - 1, history.water[idx].y - 1)
                        backPressAxis.max = Math.max(history.air[idx].y + 1, history.water[idx].y + 1)


                        function appendChunk() {
                            if (currentLoadId !== backPressChart.backPressLoadId) return
                            var end = Math.min(idx + chunkSize, history.air.length)
                            for (; idx < end; idx++) {
                                backPressAirChart.append(history.air[idx].x, history.air[idx].y)
                                backPressWaterChart.append(history.water[idx].x, history.water[idx].y)
                                backPressAxis.min = Math.min(backPressAxis.min, history.air[idx].y - 1, history.water[idx].y - 1)
                                backPressAxis.max = Math.max(backPressAxis.max, history.air[idx].y + 1, history.water[idx].y + 1)
                                backPressChart.index = history.air[idx].x
                            }

                            if (idx < history.air.length) {
                                Qt.callLater(appendChunk)
                            }
                        }
                        backPressAirChart.clear()
                        backPressWaterChart.clear()
                        appendChunk()
                    }
                }

                Rectangle {
                    id: backPressTimeAxisLabels
                    x: 75
                    y: 290
                    width: 330
                    height: 20
                    color: "#ffffff"
                    z: 10
                    Text {
                        id: t63
                        x: 8
                        y: 0
                        width: 24
                        height: 20
                        text: "60"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t58
                        x: 33
                        y: 0
                        width: 24
                        height: 20
                        text: "55"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t53
                        x: 58
                        y: 0
                        width: 24
                        height: 20
                        text: "50"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t48
                        x: 83
                        y: 0
                        width: 24
                        height: 20
                        text: "45"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t43
                        x: 108
                        y: 0
                        width: 24
                        height: 20
                        text: "40"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t38
                        x: 133
                        y: 0
                        width: 24
                        height: 20
                        text: " 35"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t33
                        x: 158
                        y: 0
                        width: 24
                        height: 20
                        text: " 30"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t28
                        x: 183
                        y: 0
                        width: 24
                        height: 20
                        text: "  25"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t23
                        x: 208
                        y: 0
                        width: 24
                        height: 20
                        text: "  20"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t18
                        x: 233
                        y: 0
                        width: 24
                        height: 20
                        text: "  15"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t13
                        x: 258
                        y: 0
                        width: 24
                        height: 20
                        text: "  10"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t8
                        x: 283
                        y: 0
                        width: 24
                        height: 20
                        text: "   5"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        id: t3
                        x: 308
                        y: 0
                        width: 24
                        height: 20
                        text: "    0"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Rectangle {
                id: backTemps
                x: 1
                y: 360
                width: 435
                height: 89
                color: "#ffffff"
                border.width: 0
                property var tempList: viewmodel.udp.backTemps
                Rectangle {
                    id: backTempsTitle
                    x: 48
                    y: 0
                    width: 357
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    Text {
                        id: backTempsTitleText
                        x: 0
                        y: 0
                        width: 357
                        height: 30
                        text: "Текущая температура °С"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Rectangle {
                    id: backAirTemp
                    x: 48
                    y: 29
                    width: 90
                    height: 59
                    color: "#ffffff"
                    Rectangle {
                        id: backAirTitle
                        width: 90
                        height: 30
                        color: "#ffa500"
                        border.width: 1
                        Text {
                            id: backAirTitleText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: "Воздух"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: backAirValue
                        x: 0
                        y: 29
                        width: 90
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: backAirValueText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: backTemps.tempList[0]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }

                Rectangle {
                    id: backWaterTemp
                    x: 137
                    y: 29
                    width: 90
                    height: 59
                    color: "#ffffff"
                    Rectangle {
                        id: backWaterTitle
                        width: 90
                        height: 30
                        color: "#add8e6"
                        border.width: 1
                        Text {
                            id: backWaterTitleText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: "Вода"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: backWaterValue
                        x: 0
                        y: 29
                        width: 90
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: backWaterValueText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: backTemps.tempList[1]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }

                Rectangle {
                    id: backOutTemp
                    x: 226
                    y: 29
                    width: 90
                    height: 59
                    color: "#ffffff"
                    Rectangle {
                        id: backOutTitle
                        width: 90
                        height: 30
                        color: "#ffc0cb"
                        border.width: 1
                        Text {
                            id: backOutTitleText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: "Сброс"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: backOutValue
                        x: 0
                        y: 29
                        width: 90
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: backOutValueText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: backTemps.tempList[2]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }

                Rectangle {
                    id: backCameraTemp
                    x: 315
                    y: 29
                    width: 90
                    height: 59
                    color: "#ffffff"
                    Rectangle {
                        id: backCameraTitle
                        width: 90
                        height: 30
                        color: "#90ee90"
                        border.width: 1
                        Text {
                            id: backCameraTitleText
                            x: 0
                            y: 0
                            width: 90
                            height: 30
                            text: "Камера"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: backCameraValue
                        x: 0
                        y: 29
                        width: 90
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: backCameraValueText
                            y: 0
                            width: 90
                            height: 30
                            text: backTemps.tempList[3]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }
            }

            Rectangle {
                id: backPress
                x: 435
                y: 360
                width: 435
                height: 89
                color: "#ffffff"
                border.width: 0
                property var pressList: viewmodel.udp.backPress
                Rectangle {
                    id: backPressTitle
                    x: 48
                    y: 0
                    width: 356
                    height: 30
                    color: "#ffffff"
                    border.width: 1
                    Text {
                        x: 0
                        y: 0
                        width: 356
                        height: 30
                        text: "Текущее давление кгс/см²"
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: false
                    }
                }

                Rectangle {
                    id: backAirPress
                    x: 48
                    y: 29
                    width: 179
                    height: 59
                    color: "#ffffff"
                    Rectangle {
                        id: backAirPressTitle
                        width: 179
                        height: 30
                        color: "#d3d3d3"
                        border.width: 1
                        Text {
                            id: backAirPressTitleText
                            x: 0
                            y: 0
                            width: 179
                            height: 30
                            text: "Воздух"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: backAirPressValue
                        x: 0
                        y: 29
                        width: 179
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: backAirPressValueText
                            x: 0
                            y: 0
                            width: 179
                            height: 30
                            text: backPress.pressList[0]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }

                Rectangle {
                    id: backWaterPress
                    x: 226
                    y: 29
                    width: 178
                    height: 59
                    color: "#ffffff"
                    Rectangle {
                        id: backWaterPressTitle
                        width: 178
                        height: 30
                        color: "#add8e6"
                        border.width: 1
                        Text {
                            id: backWaterPressTitleText
                            x: 0
                            y: 0
                            width: 178
                            height: 30
                            text: "Вода"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                            font.bold: false
                        }
                    }

                    Rectangle {
                        id: backWaterPressValue
                        x: 0
                        y: 29
                        width: 178
                        height: 32
                        color: "#ffffff"
                        border.width: 1
                        Text {
                            id: backWaterPressValueText
                            x: 0
                            y: 0
                            width: 178
                            height: 30
                            text: backPress.pressList[1]
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "Arial"
                        }
                    }
                }

                Button {
                    id: button1
                    x: -31
                    y: -40
                    visible: false
                    onClicked: controller.sendHistory()
                }
            }
        }

    }
}
