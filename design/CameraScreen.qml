import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 1920
    height: 570

    Rectangle {
        id: camaraViews
        x: 0
        y: 0
        width: 1920
        height: 570
        color: "#ffffff"

        Rectangle {
            id: frontView
            x: 0
            y: 0
            width: 960
            height: 540
            color: "#cccccc"
            border.width: 1
            Rectangle {
                id: frontNoSignal
                x: 360
                y: 236
                width: 240
                height: 68
                color: "#ffffff"
                radius: 4
                border.width: 3
                Text {
                    id: frontNoSignalText
                    width: 240
                    height: 68
                    text: "НЕТ СИГНАЛА"
                    font.pixelSize: 30
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }

            Image {
                id: frontStream
                z: 10
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
                cache: false
                Connections {
                    target: stream_front
                    function onFrameReady() {
                        frontStream.source = ""
                        frontStream.source = "image://camera/front"
                    }
                }
            }

            Rectangle {
                id: frontTitle
                x: 0
                y: 540
                width: 960
                height: 31
                color: "#ffffff"
                border.width: 1

                Text {
                    id: frontTitleText
                    x: 0
                    y: 1
                    width: 960
                    height: 30
                    text: "СТОРОНА ФРОНТА"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }


                Rectangle {
                    id: frontIndicator
                    x: 10
                    y: 3
                    width: 175
                    height: 24
                    color: "#00d3d3d3"
                    radius: 6
                    border.width: 2

                    property int state: viewmodel.udp.frontState

                    Rectangle {
                        id: frontOfflineIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: frontIndicator.state === -1
                        color: "#d3d3d3"
                        radius: 6
                        border.width: 2
                        Text {
                            id: frontInOfflineIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            text: "НЕТ СВЯЗИ"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }


                    Rectangle {
                        id: frontReadyIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: frontIndicator.state === 0
                        color: "#94f7ff"
                        radius: 6
                        border.width: 2
                        Text {
                            id: frontInReadyIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            text: "ГОТОВ"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: frontPreparingIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: frontIndicator.state >= 1 && frontIndicator.state <= 2
                        color: "#ffe88a"
                        radius: 6
                        border.width: 2
                        Text {
                            id: frontInPreparingIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            text: "ПОДГОТОВКА"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }


                    Rectangle {
                        id: frontInWorkIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: frontIndicator.state === 3
                        color: "#90ee90"
                        radius: 6
                        border.width: 2

                        Text {
                            id: frontInWorkIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            visible: true
                            text: "В РАБОТЕ"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: frontErrorIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: frontIndicator.state === 4
                        color: "#fd5c78"
                        radius: 6
                        border.width: 2
                        Text {
                            id: frontErrorIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            visible: true
                            text: "ОШИБКА"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: frontRestartIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: frontIndicator.state === 5
                        color: "#ffd06b"
                        radius: 6
                        border.width: 2
                        Text {
                            id: frontRestartIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            visible: true
                            text: "ОСТАНОВЛЕН"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }




                }
            }

            Connections {
                target: stream_front
            }
        }

        Rectangle {
            id: backView
            x: 960
            width: 960
            height: 540
            color: "#cccccc"
            border.width: 1
            Rectangle {
                id: backNoSignal
                x: 360
                y: 236
                width: 240
                height: 68
                color: "#ffffff"
                radius: 4
                border.width: 3
                Text {
                    id: backNoSignalText
                    width: 240
                    height: 68
                    text: "НЕТ СИГНАЛА"
                    font.pixelSize: 30
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }

            Image {
                id: backStream
                z: 10
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
                cache: false
                Connections {
                    target: stream_back
                    function onFrameReady() {
                        backStream.source = ""
                        backStream.source = "image://camera/back"
                    }
                }
            }

            Rectangle {
                id: backTitle
                x: 0
                y: 540
                width: 960
                height: 31
                color: "#ffffff"
                border.width: 1
                Text {
                    id: backTitleText
                    x: 0
                    y: 1
                    width: 960
                    height: 30
                    text: "СТОРОНА ТЫЛА"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    id: backIndicator
                    x: 775
                    y: 3
                    width: 175
                    height: 24
                    color: "#00d3d3d3"
                    radius: 6
                    border.width: 2

                    property int state: viewmodel.udp.backState

                    Rectangle {
                        id: backOfflineIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: backIndicator.state === -1
                        color: "#d3d3d3"
                        radius: 6
                        border.width: 2
                        Text {
                            id: backInOfflineIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            text: "НЕТ СВЯЗИ"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backReadyIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: backIndicator.state === 0
                        color: "#94f7ff"
                        radius: 6
                        border.width: 2
                        Text {
                            id: backInReadyIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            text: "ГОТОВ"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backPreparingIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: backIndicator.state >= 1 && backIndicator.state <= 2
                        color: "#ffe88a"
                        radius: 6
                        border.width: 2
                        Text {
                            id: backInPreparingIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            text: "ПОДГОТОВКА"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backInWorkIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: backIndicator.state === 3
                        color: "#90ee90"
                        radius: 6
                        border.width: 2
                        Text {
                            id: backInWorkIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            visible: true
                            text: "В РАБОТЕ"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backtErrorIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: backIndicator.state === 4
                        color: "#fd5c78"
                        radius: 6
                        border.width: 2
                        Text {
                            id: backErrorIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            visible: true
                            text: "ОШИБКА"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }

                    Rectangle {
                        id: backRestartIndicator
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        visible: backIndicator.state === 5
                        color: "#ffd06b"
                        radius: 6
                        border.width: 2
                        Text {
                            id: backRestartIndicatorText
                            x: 0
                            y: 0
                            width: 175
                            height: 23
                            visible: true
                            text: "ОСТАНОВЛЕН"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                        }
                    }
                }
            }

            Connections {
                target: stream_back
            }
        }
    }
}
