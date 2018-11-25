import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

import Pyblish 0.1
import Pyblish.ListItems 0.1


Item {
    id: overview

    MouseArea {
        id: pluginMouse
        anchors.fill: parent
        hoverEnabled: true
    }

    property string __lastPlugin

    property bool validated: false

    signal instanceEntered(int index)
    signal pluginEntered(int index)

    states: [
        State {
            name: "publishing"
        },

        State {
            name: "finished"
        },

        State {
            name: "initialising"
        },

        State {
            name: "stopping"
        }
    ]

    function setMessage(message) {
        footer.message.text = message
        footer.message.animation.restart()
        footer.message.animation.start()
    }

    TabBar {
        id: tabBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        tabs: [
            {
                text: "",
                icon: "logo-white"
            },
            "Terminal"
        ]
    }

    View {
        id: tabView

        anchors.top: tabBar.bottom
        anchors.bottom: commentBox.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: tabView.margins
        anchors.bottomMargin: 0

        width: parent.width - 10

        elevation: -1

        Row {
            visible: tabBar.currentIndex == 0

            anchors.fill: parent
            anchors.margins: parent.margins

            List {
                model: app.instanceProxy

                width: Math.floor(parent.width / 2.0)  // To keep checkbox border from collapsing
                height: parent.height

                section.property: "object.category"
                section.delegate: SectionItem {
                    text: section
                    object: app.instanceProxy.itemByName(section)

                    onSectionClicked: {
                        app.hideSection(!hideState, text)
                    }

                    onLabelClicked: {
                        checkState = !checkState
                        app.toggleSection(checkState, text)
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                onActionTriggered: {
                    if (action.name == "repair")
                        app.repairInstance(index)
                    else if (action.name == "enter")
                        overview.instanceEntered(index)
                }

                onItemToggled: app.toggleInstance(index)
            }

            List {
                id: pluginList

                model: app.pluginProxy

                width: Math.floor(parent.width / 2.0)
                height: parent.height

                section.property: "object.verb"
                section.delegate: SectionItem {
                    text: section
                    object: app.pluginProxy.itemByName(section)

                    onSectionClicked: {
                        app.hideSection(!hideState, text)
                    }

                    onLabelClicked: {
                        checkState = !checkState
                        app.toggleSection(checkState, text)
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                onActionTriggered: {
                    if (action.name == "repair")
                        app.repairPlugin(index)
                    else if (action.name == "enter")
                        overview.pluginEntered(index)
                }

                onItemToggled: app.togglePlugin(index)
                onItemRightClicked: {
                    var actions = app.getPluginActions(index)

                    if (actions.length === 0)
                        return

                    function show() {
                        return Utils.showContextMenu(
                            overview,           // Parent
                            actions,            // Children
                            pluginMouse.mouseX, // X Position
                            pluginMouse.mouseY) // Y Position
                    }

                    if (Global.currentContextMenu !== null) {
                            function callback() {
                                Global.currentContextMenu.beingHidden.disconnect(callback)
                                Global.currentContextMenu = show()
                          }

                          Global.currentContextMenu.beingHidden.connect(callback)
                          Global.currentContextMenu.hide()

                    } else {
                        Global.currentContextMenu = show()
                    }
                }

                Connections {
                    target: Global.currentContextMenu
                    onToggled: app.runPluginAction(JSON.stringify(data))
                }
            }
        }

        Terminal {
            id: terminal

            anchors.fill: parent
            anchors.margins: 2

            visible: tabBar.currentIndex == 1
        }
    }

    CommentBox {
        id: commentBox

        // Enable editing only when the GUI is not busy with something else
        readOnly: overview.state != ""

        anchors {
            bottom: footer.top
            left: parent.left
            right: parent.right
            top: (isMaximised && height == parent.height - footer.height) ? tabBar.top : undefined
        }

        height: isMaximised ? parent.height - footer.height : isUp ? 150 : 0
    }

    Footer {
        id: footer

        visible: overview.state != "initialising"

        mode:  overview.state == "publishing" ? 1 : overview.state == "finished" ? 2 : 0

        width: parent.width
        anchors.bottom: parent.bottom

        onPublish: app.publish()
        onValidate: app.validate()
        onReset: app.reset()
        onStop: app.stop()
        onSave: app.save()
        onComment: commentBox.height > 75 ? commentBox.down() : commentBox.up()
    }

    Connections {
        target: app

        onError: setMessage(message)
        onInfo: setMessage(message)

        onFirstRun: {
            app.commentEnabled ? commentBox.up() : null
            commentBox.text = app.comment()
        }

        onStateChanged: {
            if (state == "ready") {
                overview.state = ""
                setMessage("Ready")
            }

            if (state == "initialising") {
                overview.state = "initialising"
                setMessage("Initialising..")
            }

            if (state == "collecting") {
                overview.state = "publishing"
                setMessage("Collecting..")
            }

            if (state == "validating") {
                overview.state = "publishing"
                setMessage("Validating..")
                overview.validated = false
            }

            if (state == "extracting") {
                overview.state = "publishing"
                setMessage("Extracting..")
                overview.validated = true
            }

            if (state == "integrating") {
                overview.state = "publishing"
                setMessage("Integrating..")
            }

            if (state == "finished") {
                overview.state = "finished"
                overview.validated ? setMessage("Published") : setMessage("Validated")
            }

            if (state == "stopping") {
                setMessage("Stopping..")
            }

            if (state == "stopped") {
                overview.state = "finished"
                setMessage("Stopped")
            }

            if (state == "dirty") {
                setMessage("Dirty..")
            }

            if (state == "acting") {
                setMessage("Acting")
                overview.state = "publishing"
            }
        }
    }
}
