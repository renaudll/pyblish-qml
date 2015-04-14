import QtQuick 2.3
import Pyblish 0.1


Item {
    id: root

    property color color: "white"

    property Component body
    // property alias loader.item: loader.item
    property alias loader: loader
    property alias toggle: toggle

    property bool expandable
    property bool expanded

    Row {
        anchors.fill: parent

        anchors.verticalCenter: parent.verticalCenter

        spacing: 5

        MouseArea {
            id: mouseArea

            hoverEnabled: true

            anchors.verticalCenter: parent.verticalCenter

            width: toggle.width
            height: parent.height

            Rectangle {
                color: Theme.primaryColor
                anchors.fill: parent
                opacity: 0.5
                visible: expandable && parent.containsMouse
            }

            Icon {
                id: toggle

                name: "button-expand"
                opacity: expandable ? 1 : 0
                rotation: expanded ? 90 : 0

                anchors.verticalCenter: parent.verticalCenter
            }

            onClicked: {
                if (expandable)
                    expanded = !expanded
            }
        }

        Loader {
            id: loader

            width: root.width - toggle.width - 10
            anchors.verticalCenter: parent.verticalCenter

            sourceComponent: body
        }
    }
}