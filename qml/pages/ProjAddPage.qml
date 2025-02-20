import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Dialog {
    id: dialog

    allowedOrientations: Orientation.All

    property var recId
    property var callback
    property var template

    property bool   addNewProj  : true
    property string project
    property bool   invoiced
    property string price
    property string kmTarget
    property bool   isTarget
    property string projType
    property string bgColor

    property string debugLog: generic.debugLog

    canAccept: txtProj.text.length > 0 && (checkInvc.checked || checkTarg.checked)

    onAccepted: {
        console.log("Accepted Dialog")
        project     = txtProj.text
        invoiced    = checkInvc.checked
        isTarget    = checkTarg.checked
        price       = checkInvc.checked ? txtPric.text : 0
        kmTarget    = checkTarg.checked ? txtTarg.text : 0
        projType    = typeBox.value
        bgColor     = colorIndicator.color
        console.log("New proj: " + project )
        // addProj(addNewProj, project, invoiced, price, kmTarget, isTarget, projType, bgColor)
        Database.addProj(addNewProj, project, invoiced, price, kmTarget, isTarget, projType, bgColor)
        dialog.callback(true, false)
    }

    onRejected: {
        dialog.callback(false, false)
    }

    function getThisProj(recId) {
        // Available in a Project
        // project, invoiced, price, kmTarget, isTarget, projType, bgColor

        if (recId === undefined) {
            console.log("New project, providing defaults")
            var tmp = new Date()
            addNewProj   = true
            txtProj.text      = ""
            checkInvc.checked = false
            checkTarg.checked = false
            txtPric.text      = ""
            txtTarg.text      = ""
            typeBox.value     = "walk"
//            typeBox.currentIndex = 0
            colorIndicator.color = "#777777"
        }
        else {
            var proj = Database.getOneProj(project)
            console.log("This project: " + JSON.stringify(proj))
            addNewProj   = false
            txtProj.text      = proj.project
            checkInvc.checked = proj.invoiced
            checkTarg.checked = proj.isTarget
            txtPric.text      = proj.price
            txtTarg.text      = proj.kmTarget
            typeBox.value     = proj.projType
            colorIndicator.color = proj.bgColor

        }
    }

    Component.onCompleted: getThisProj(recId);

    SilicaFlickable {
        id: projView

        PageHeader {
            id: pageHeader
            title: (addNewProj ? "Add proj" : "Edit proj")
        }

        VerticalScrollDecorator {}

        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
        contentHeight: column.height // + Theme.itemSizeMedium

        Column {
            id: column
            width: parent.width
            anchors {
                top: pageHeader.bottom
                margins: 0
            }

            TextField {
                id: txtProj
                focus: true
                width: parent.width
                label: qsTr("Project")
                placeholderText: label
                placeholderColor: Theme.secondaryColor
                color: Theme.primaryColor
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: checkInvc.focus = true
            }

            BackgroundItem {
                id: colorPickerButton
                Row {
                    x: Theme.horizontalPageMargin
                    height: parent.height
                    spacing: Theme.paddingMedium
                    Rectangle {
                        id: colorIndicator

                        width: height
                        height: parent.height
                        color: "#777777"
                    }
                    Label {
                        text: "Color"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                onClicked: {
                    var obj = pageStack.animatorPush("Sailfish.Silica.ColorPickerPage", { color: colorIndicator.color })
                    obj.pageCompleted.connect(function(page) {
                        page.colorClicked.connect(function(color) {
                            colorIndicator.color = color
                            console.log("You selected:", color)
                            pageStack.pop()
                        })
                    })
                }
                Component {
                    id: colorPickerPage
                    ColorPickerPage {}
                }
            }

            ComboBox {
                id: typeBox
                label: "Type of project"
                menu: ContextMenu {
                    MenuItem { text: "bike" }
                    MenuItem { text: "car" }
                    MenuItem { text: "run" }
                    MenuItem { text: "walk" }
                }
            }

            SectionHeader {
                text: "Option: priced per km?"
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            TextSwitch {
                id: checkInvc
                text: (checked ? qsTr("Yes, pricing is on") : qsTr("No pricing") )
                description: "Priced per kilometer or not?"
                onCheckedChanged: {
                    txtPric.focus = true
                }
            }

            TextField {
                id: txtPric
                width: parent.width
                label: qsTr("Price per kilometer")
                placeholderText: label
                placeholderColor: Theme.secondaryColor
                color: Theme.primaryColor
                enabled: checkInvc.checked
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: checkTarg.focus = true
            }

            SectionHeader {
                text: "Option: a target to work towards?"
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            TextSwitch {
                id: checkTarg
                text: (checked ? qsTr("Yes, a target it is") : qsTr("No, serves another purpose") )
                description: "Meant as a target to reach?"
                onCheckedChanged: {
                    txtTarg.focus = true
                }
            }

            TextField {
                id: txtTarg
                width: parent.width
                label: qsTr("Kilometer target")
                placeholderText: label
                placeholderColor: Theme.secondaryColor
                color: Theme.primaryColor
                enabled: checkTarg.checked
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: dialog.accept()
            }

        }
    }
}
