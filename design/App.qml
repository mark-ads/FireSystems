
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    width: 1920
    height: Math.min(Screen.height, 1080)
    visible: true
    title: "FireSystems"
    property var systemsModel: ["Система 1", "Система 2"]
    property int currentScreen: 0

    StackLayout {
        id: screenStack
        anchors.fill: parent
        currentIndex: root.currentScreen
        z: 0

        SystemScreen {}
        TechScreen {}
        SettingsScreen {}
    }

    CameraScreen {
        id: cameraViews
        x: 0
        y: 0
        z: 10

    }

    NavigationPanel {
        id: navPanel
        x: 870
        y: 570
        anchors.margins: 16
        anchors.rightMargin: 870
        anchors.topMargin: 570
        z: 10
        onScreenSelected: root.currentScreen = index
        activeIndex: root.currentScreen
    }
    Popup {
        id: systemMenu
        x: 870
        y: 780
        width: 180
        modal: true
        focus: true

        background: Rectangle {
            color: "#ffffff"
            border.color: "#888888"
            radius: 0
        }

        Column {
            id: systemList
            spacing: 0
            anchors.fill: parent
            anchors.margins: 0

            Repeater {
                id: systemRepeater
                model: systemsModel
                delegate: Rectangle {
                    width: 155
                    height: 50
                    border.color: "#cccccc"
                    border.width: 1
                    color: "white"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("Выбрана:", modelData)
                            systemMenu.close()
                            // Выбор системы
                        }

                        Text {
                            text: modelData
                            anchors.centerIn: parent
                            font.pointSize: 12
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Loader {
                id: createSystemLoader
                active: systemsModel.length < 4
                sourceComponent: createSystemButton
            }


            Component {
                id: createSystemButton
                Rectangle {
                    width: 155
                    height: 50
                    border.color: "#cccccc"
                    border.width: 1
                    color: "white"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("Создание новой системы")
                            systemMenu.close()
                            // Вставить вызов логики создания системы
                        }


                        Text {
                            text: "+\n(Создать систему)"
                            anchors.centerIn: parent
                            font.pointSize: 10
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: "black"
                        }
                    }


                }
            }
        }
    }
}
