import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Dialog {
    id: dialog

    allowedOrientations: Orientation.All

    property var recId
    property var callback

    property var    tripId
    property var    tripDate
    property string description
    property real   km
    property string proj

    property bool somethingHasChanged : false

    onAccepted: {
        dialog.callback(somethingHasChanged)
    }

    onRejected: {
        dialog.callback(somethingHasChanged)
    }

    function updateAfterDialog(updated, trId) {
        if (updated) {
            somethingHasChanged = true
            prepareTrip(trId)
        }
    }

    function prepareTrip(trId) {
        console.log("Prepare for showing: " + JSON.stringify(recId))
        var trip = Database.getOneTrip(trId)
        console.log("Getting this trip for showing: " + JSON.stringify(trip))
        tripId       = trip.tripId
        txtDate.text = trip.tripDate
        txtDesc.text = trip.descriptn
        txtKilo.text = trip.kilometer
        txtProj.text = trip.project
        colorIndicator.color = trip.bgColor
    }

    Component.onCompleted: prepareTrip(recId);

    SilicaFlickable {
        id: tripView

        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
        contentHeight: column.height + Theme.itemSizeMedium
        quickScroll : true

        PageHeader {
            id: pageHeader
            title: qsTr("This trip") + "     "
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

            spacing: Theme.paddingSmall

            TextField {
                id: txtDate
                width: parent.width
                readOnly: true
                label: qsTr("Date")
                color: Theme.primaryColor
            }

            TextField {
                id: txtKilo
                width: parent.width
                readOnly: true
                label: qsTr("Kilometer")
                color: Theme.primaryColor
            }

            TextField {
                id: txtProj
                width: parent.width
                readOnly: true
                label: qsTr("Project")
                color: Theme.primaryColor
            }

            TextField {
                id: txtDesc
                width: parent.width
                readOnly: true
                label: qsTr("Description")
                color: Theme.primaryColor
            }

        }

        RemorsePopup { id: remorse }

        PullDownMenu {
            MenuItem {
                text: qsTr("Delete this trip")
                onClicked: remorse.execute("Deleting trip", function() {
                    console.log("Remove Trip " + tripId)
                    Database.deleteTrip(tripId)
                    dialog.callback(true)
                    pageStack.pop()
                })
            }
            MenuItem {
                text: "Edit trip"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("TripAddPage.qml"),
                                   {recId: tripId, callback: updateAfterDialog})
                }
            }
        }
    }
}
