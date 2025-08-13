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
                    text: qsTr("НЕТ СИГНАЛА")
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
                    text: qsTr("СТОРОНА ФРОНТА")
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
                    color: "#8cf383"
                    radius: 6
                    border.width: 2
                    Text {
                        id: frontIndicatorText
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        text: qsTr("В РАБОТЕ")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
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
                    text: qsTr("НЕТ СИГНАЛА")
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
                    text: qsTr("СТОРОНА ТЫЛА")
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
                    color: "#8cf383"
                    radius: 6
                    border.width: 2
                    Text {
                        id: backIndicatorText
                        x: 0
                        y: 0
                        width: 175
                        height: 24
                        text: qsTr("В РАБОТЕ")
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                    }
                }
            }

            Connections {
                target: stream_back
            }
        }
    }
}
