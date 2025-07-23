import QtQuick 2.6
import Sailfish.Silica 1.0
import "../modules/Opal/Delegates"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Dialog {
    id: dialog

    allowedOrientations: Orientation.All

    property var recId
    property var callback
    property var template

    property string project
    property bool   invoiced
    property string price
    property string kmTarget
    property bool   isTarget
    property string projType
    property string bgColor
    property bool   isComplete
    property real   kmTotal    : 0.0
    property string strKmTotal
    property int    listLength

    property bool hideCompleted : generic.hideCompleted
    property bool somethingHasChanged : false

    onAccepted: {
        dialog.callback(somethingHasChanged)
    }

    onRejected: {
        dialog.callback(somethingHasChanged)
    }

    function updateAfterDialog(updated, proj) {
        if (updated) {
            somethingHasChanged = true
            getThisProj(proj)
        }
    }

    ListModel {
        id: listModel
    }

    function getThisProj(projId) {
        // Available in a Project
        // project, invoiced, price, kmTarget, isTarget, projType, bgColor, txtPrice, txtKmTarget, isComplete

        var proj = Database.getOneProj(projId)
        console.log("This project: " + JSON.stringify(proj))
        project      = proj.project;
        txtProj.text = proj.project;
        isComplete   = proj.isComplete;
        invoiced     = proj.invoiced;
        isTarget     = proj.isTarget;
        txtPric.text = proj.price.toString().replace(".", generic.csvDecimal);
        txtTarg.text = proj.kmTarget;
        txtType.text = proj.projType;
        colorIndicator.color = proj.bgColor;

        // Show the trips from the project too
        listModel.clear();
        kmTotal = 0;
        var trips = Database.getTrips(false, projId);
        listLength = trips.length;
        for (var i = 0; i < listLength; ++i) {
            listModel.append(trips[i]);
            kmTotal += trips[i].kilometer;
//            console.log( JSON.stringify(trips[i]));
        }
        strKmTotal = kmTotal.toString().replace(".", generic.csvDecimal);
        console.log( "listModel trips updated");
    }

    Component.onCompleted: getThisProj(recId);

    SilicaFlickable {
        id: wpView

        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }

//        contentHeight: column.height + Theme.itemSizeMedium
        contentHeight: (5 +listLength) * Theme.itemSizeLarge
        flickableDirection: Flickable.VerticalFlick
        quickScroll : true

        PageHeader {
            id: pageHeader
            title: qsTr("One project") + "       "
        }

        Rectangle {
            id: colorIndicator
            height: Theme.itemSizeMedium * 0.5
            width: height
            radius: Theme.itemSizeMedium * 0.15
            anchors {
                verticalCenter: pageHeader.verticalCenter
                right: parent.right
                rightMargin: Theme.paddingMedium
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

            TextField {
                id: txtPric
                width: parent.width
                label: qsTr("Price per kilometer")
                readOnly: true
                color: Theme.primaryColor
                visible: invoiced
            }

            TextField {
                id: txtTarg
                width: parent.width
                label: qsTr("Kilometer target")
                readOnly: true
                color: Theme.primaryColor
                visible: isTarget
            }

            TextField {
                id: txtCmpl
                width: parent.width
                label: qsTr("Status") + ": " + (isComplete ? qsTr("Completed") : qsTr("Continuing"))
                readOnly: true
                color: Theme.primaryColor
            }

            Separator {
                width: parent.width
                color: Theme.secondaryColor
            }

            Item {
                height: Theme.itemSizeMedium
                width: parent.width

                Label {
                    id: lblTotal
                    text: qsTr("The project's current total: ") + strKmTotal + qsTr(" km")
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.primaryColor
                    anchors {
                        margins: Theme.paddingLarge
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            Separator {
                width: parent.width
                color: Theme.secondaryColor
            }

            DelegateColumn {
                model: listModel

                delegate: TwoLineDelegate {
                    id: tripDelegat
                    text: tripDate + '  ' + project
                    description: descriptn
    //                showOddEven: true

                    property string recId : tripId

                    leftItem:  Item {
                        width: Theme.itemSizeMedium

                        Rectangle {
                            id: colRect
                            height: Theme.itemSizeMedium * 0.5
                            width: Theme.itemSizeMedium * 0.1
                            radius: width
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            color: bgColor
                        }

                        DelegateInfoItem {
                            id: kmItem
                            text: kilometer.toString().replace(".", generic.csvDecimal);
                            description: qsTr("km")
                            alignment: Qt.AlignHCenter
                            anchors {
                                left: colRect.right
                                verticalCenter: colRect.verticalCenter
                            }
                        }
                    }
                }
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
