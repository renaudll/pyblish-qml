import QtQuick 2.3
import QtQuick.Controls 1.3 as Controls
import QtQuick.Controls.Styles 1.3 as ControlStyle
import Pyblish 0.1
import "utils.js" as Util


Column {
    ListView {
        id: listView

        width: parent.width
        height: parent.height - filter.height

        clip: true

        model: app.terminalProxy

        delegate: Loader {
            width: ListView.view.width
            source: "delegates/" + Util.toTitleCase(type) + "Delegate.qml"
        }
    }

    // Row {
    //     id: toolBar

    //     Button {
    //         text: "A"
    //     }
    //     Button {
    //         text: "B"
    //     }
    //     Button {
    //         text: "C"
    //     }
    //     Button {
    //         text: "D"
    //     }
    // }

    Controls.TextField {
        id: filter

        width: parent.width
        height: 30

        placeholderText: "Filter.."

        style: ControlStyle.TextFieldStyle {
            background: Rectangle {
                color: Qt.darker(Theme.backgroundColor, 1.4)
            }
            textColor: "white"
            placeholderTextColor: Qt.darker(textColor, 1.5)
        }

        onTextChanged: app.terminalProxy.setFilterFixedString(text)
    }
}
