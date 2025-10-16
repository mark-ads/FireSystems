import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    width: 1920
    height: 1080
    visible: true
    title: "FireSystems"
    property int currentScreen: 0

    StackLayout {
        id: screenStack
        anchors.fill: parent
        currentIndex: root.currentScreen
        z: 0

        SystemScreen {}
        TechScreen {}
        SettingsScreen {
            id: settingsScreen
            navPanelRef: navPanel
            rootRef: root
        }
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
                model: (typeof viewmodel !== "undefined" && viewmodel.systemNames)
                       ? Object.keys(viewmodel.systemNames)
                       : []

                delegate: Rectangle {
                    width: 155
                    height: 50
                    border.color: "#cccccc"
                    border.width: 1
                    color: "white"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            let systemId = modelData
                            systemMenu.close()
                            viewmodel.choose_system(systemId)
                            controller.switch_system(systemId)
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        font.pointSize: 12
                        color: "black"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: viewmodel.systemNames[modelData]
                    }
                }
            }

            Rectangle {
                id: createSystemButton
                width: 155
                height: visible ? 50 : 0
                visible: (typeof viewmodel !== "undefined" && Object.keys(viewmodel.systemNames).length < 4)
                border.color: "#cccccc"
                border.width: 1
                color: "white"

                Behavior on height { NumberAnimation { duration: 100 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        controller.add_new_system()
                        viewmodel.update_system_names()
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

                Connections {
                    target: viewmodel
                    function onNamesUpdated() {
                        systemRepeater.model = Object.keys(viewmodel.systemNames)
                    }
                }
            }
        }
    }
}