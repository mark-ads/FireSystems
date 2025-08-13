import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15

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
            id: frontRectangle
            x: 0
            y: 570
            width: 871
            height: 450
            color: "#ffffff"
            border.width: 1
            
            ChartView {
                id: frontTempChart
                x: 0
                y: 0
                width: 435
                height: 360
                antialiasing: true
                legend.visible: false
                
                ValueAxis {
                    id: frontTempTimeAxis
                    min: -60
                    max: 0
                    tickCount: 13
                    titleText: "Минут назад"
                    labelFormat: "%d"
                    titleFont.family: "Arial"
                    titleFont.pointSize: 12
                    titleFont.bold: true
                }
                
                ValueAxis {
                    id: frontTempAxis
                    //min: 0
                    //max: 100
                    tickCount: 11
                    titleText: "Температура °C"
                    titleFont.family: "Arial"
                    titleFont.pointSize: 12
                    titleFont.bold: true
                }
                
                SplineSeries {
                    name: "Воздух"
                    axisX: frontTempTimeAxis
                    axisY: frontTempAxis
                    color: "orange"
                    width: 3
                    
                    XYPoint { x: -60; y: 80.4 }
                    XYPoint { x: -55; y: 22.9 }
                    XYPoint { x: -50; y: 50.1 }
                    XYPoint { x: -45; y: 55.4 }
                    XYPoint { x: -40; y: 53.9 }
                    XYPoint { x: -35; y: 40.0 }
                    XYPoint { x: -30; y: 90.7 }
                    XYPoint { x: -25; y: 17.2 }
                    XYPoint { x: -20; y: 16.0 }
                    XYPoint { x: -15; y: 25.8 }
                    XYPoint { x: -10; y: 32.9 }
                    XYPoint { x: -5;  y: 60.2 }
                    XYPoint { x:  0;  y: 80.5 }
                }
                
                SplineSeries {
                    name: "Вода"
                    axisX: frontTempTimeAxis
                    axisY: frontTempAxis
                    color: "light blue"
                    width: 3
                    
                    XYPoint { x: -60; y: 30.4 }
                    XYPoint { x: -55; y: 52.9 }
                    XYPoint { x: -50; y: 60.1 }
                    XYPoint { x: -45; y: 35.4 }
                    XYPoint { x: -40; y: 83.9 }
                    XYPoint { x: -35; y: 20.0 }
                    XYPoint { x: -30; y: 33.7 }
                    XYPoint { x: -25; y: 11.2 }
                    XYPoint { x: -20; y: 37.0 }
                    XYPoint { x: -15; y: 72.8 }
                    XYPoint { x: -10; y: 80.9 }
                    XYPoint { x: -5;  y: 23.2 }
                    XYPoint { x:  0;  y: 35.5 }
                    
                }
                SplineSeries {
                    name: "Сброс"
                    axisX: frontTempTimeAxis
                    axisY: frontTempAxis
                    color: "pink"
                    width: 3
                    
                    XYPoint { x: -60; y: 60.4 }
                    XYPoint { x: -55; y: 32.9 }
                    XYPoint { x: -50; y: 50.1 }
                    XYPoint { x: -45; y: 45.4 }
                    XYPoint { x: -40; y: 43.9 }
                    XYPoint { x: -35; y: 40.0 }
                    XYPoint { x: -30; y: 25.7 }
                    XYPoint { x: -25; y: 17.2 }
                    XYPoint { x: -20; y: 20.0 }
                    XYPoint { x: -15; y: 45.8 }
                    XYPoint { x: -10; y: 32.9 }
                    XYPoint { x: -5;  y: 60.2 }
                    XYPoint { x:  0;  y: 40.5 }
                }
                SplineSeries {
                    name: "Камера"
                    axisX: frontTempTimeAxis
                    axisY: frontTempAxis
                    color: "light green"
                    width: 3
                    
                    XYPoint { x: -60; y: 80.4 }
                    XYPoint { x: -55; y: 22.9 }
                    XYPoint { x: -50; y: 50.1 }
                    XYPoint { x: -45; y: 55.4 }
                    XYPoint { x: -40; y: 53.9 }
                    XYPoint { x: -35; y: 40.0 }
                    XYPoint { x: -30; y: 15.7 }
                    XYPoint { x: -25; y: 17.2 }
                    XYPoint { x: -20; y: 16.0 }
                    XYPoint { x: -15; y: 25.8 }
                    XYPoint { x: -10; y: 32.9 }
                    XYPoint { x: -5;  y: 60.2 }
                    XYPoint { x:  0;  y: 80.5 }
                }
            }
            
            ChartView {
                id: frontPressure
                x: 435
                y: 0
                width: 435
                height: 360
                antialiasing: true
                legend.visible: false
                
                ValueAxis {
                    id: frontPressTimeAxis
                    min: -60
                    max: 0
                    tickCount: 13
                    titleText: "Минут назад"
                    labelFormat: "%d"
                    titleFont.family: "Arial"
                    titleFont.pointSize: 12
                    titleFont.bold: true
                }
                
                ValueAxis {
                    id: frontPressAxis
                    //min: 0
                    //max: 100
                    tickCount: 11
                    titleText: "Давление кгс/см²"
                    titleFont.family: "Arial"
                    titleFont.pointSize: 12
                    titleFont.bold: true
                }
                
                SplineSeries {
                    name: "Воздух"
                    axisX: frontPressTimeAxis
                    axisY: frontPressAxis
                    color: "light grey"
                    width: 3
                    
                    XYPoint { x: -60; y: 80.4 }
                    XYPoint { x: -55; y: 22.9 }
                    XYPoint { x: -50; y: 50.1 }
                    XYPoint { x: -45; y: 55.4 }
                    XYPoint { x: -40; y: 53.9 }
                    XYPoint { x: -35; y: 40.0 }
                    XYPoint { x: -30; y: 15.7 }
                    XYPoint { x: -25; y: 17.2 }
                    XYPoint { x: -20; y: 16.0 }
                    XYPoint { x: -15; y: 25.8 }
                    XYPoint { x: -10; y: 32.9 }
                    XYPoint { x: -5;  y: 60.2 }
                    XYPoint { x:  0;  y: 80.5 }
                }
                SplineSeries {
                    name: "Вода"
                    axisX: frontPressTimeAxis
                    axisY: frontPressAxis
                    color: "light blue"
                    width: 3
                    
                    XYPoint { x: -60; y: 30.4 }
                    XYPoint { x: -55; y: 52.9 }
                    XYPoint { x: -50; y: 60.1 }
                    XYPoint { x: -45; y: 35.4 }
                    XYPoint { x: -40; y: 83.9 }
                    XYPoint { x: -35; y: 20.0 }
                    XYPoint { x: -30; y: 33.7 }
                    XYPoint { x: -25; y: 11.2 }
                    XYPoint { x: -20; y: 37.0 }
                    XYPoint { x: -15; y: 72.8 }
                    XYPoint { x: -10; y: 80.9 }
                    XYPoint { x: -5;  y: 23.2 }
                    XYPoint { x:  0;  y: 35.5 }
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
                        text: qsTr("Текущая температура °С")
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
                            text: qsTr("Воздух")
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
                            text: qsTr("50.0")
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
                            text: qsTr("Вода")
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
                            text: qsTr("45.0")
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
                            text: qsTr("Сброс")
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
                            text: qsTr("60.0")
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
                            text: qsTr("Камера")
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
                            text: qsTr("73.3")
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
                        text: qsTr("Текущее давление кгс/см²")
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
                            text: qsTr("Воздух")
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
                            text: qsTr("50.0")
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
                            text: qsTr("Вода")
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
                            text: qsTr("73.3")
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
            id: backRectangle
            x: 1049
            y: 570
            width: 871
            height: 450
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
            border.width: 1
            z: 10
            rotation: 0
        }
        
    }
}
