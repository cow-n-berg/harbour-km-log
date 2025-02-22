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

    property bool somethingHasChanged : false

    onAccepted: {
        dialog.callback(somethingHasChanged)
    }

    onRejected: {
        dialog.callback(somethingHasChanged)
    }

    function updateAfterDialog(updated) {
        if (updated) {
            somethingHasChanged = true
            getThisProj(recId)
        }
    }

    function getThisProj(recId) {
        // Available in a Project
        // project, invoiced, price, kmTarget, isTarget, projType, bgColor

            var proj = Database.getOneProj(recId)
            console.log("This project: " + JSON.stringify(proj))
            project      = proj.project
            txtProj.text = proj.project
            invoiced     = proj.invoiced
            isTarget     = proj.isTarget
            txtPric.text = proj.price
            txtTarg.text = proj.kmTarget
            txtType.text = proj.projType
            colorIndicator.color = proj.bgColor
    }

    Component.onCompleted: getThisProj(recId);

    SilicaFlickable {
        id: wpView

        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
        contentHeight: column.height + Theme.itemSizeMedium
        quickScroll : true

        PageHeader {
            id: pageHeader
            title: qsTr("One project") + "     "
        }

        Rectangle {
            id: colorIndicator
            width: Theme.iconSizeMedium
            height: width
            anchors {
                verticalCenter: pageHeader.verticalCenter
                right: parent.right
            }
        }

        Column {
            id: column
            width: parent.width
            anchors {
                top: pageHeader.bottom
                margins: 0
            }

            TextField {
                id: txtProj
                width: parent.width
                readOnly: true
                label: qsTr("Project")
                color: Theme.primaryColor
            }

            TextField {
                id: txtType
                width: parent.width
                readOnly: true
                label: qsTr("Type of project")
                color: Theme.primaryColor
            }

//            TextSwitch {
//                id: checkInvc
//                text: (checked ? qsTr("Yes, pricing is on") : qsTr("No pricing") )
//                description: "Priced per kilometer or not?"
//            }

            TextField {
                id: txtPric
                width: parent.width
                label: qsTr("Price per kilometer")
                readOnly: true
                color: Theme.primaryColor
                visible: invoiced
            }

//            TextSwitch {
//                id: checkTarg
//                text: (checked ? qsTr("Yes, a target it is") : qsTr("No, serves another purpose") )
//                description: "Meant as a target to reach?"
//                onCheckedChanged: {
//                    txtTarg.focus = true
//                }
//            }

            TextField {
                id: txtTarg
                width: parent.width
                label: qsTr("Kilometer target")
                readOnly: true
                color: Theme.primaryColor
                visible: isTarget
            }

        }
        RemorsePopup { id: remorse }

        PullDownMenu {
            MenuItem {
                text: qsTr("Delete this project")
                onClicked: remorse.execute("Deleting project", function() {
                    console.log("Remove project " + project)
                    Database.deleteProj(project)
                    dialog.callback(true)
                    pageStack.pop()
                })
            }
            MenuItem {
                text: "Edit project"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ProjAddPage.qml"),
                                   {"recId": project, callback: updateAfterDialog})
                }
            }
        }
    }
}
