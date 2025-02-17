import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Dialog {
    id: dialog

    allowedOrientations: Orientation.All

    property var tripId
    property var callback
    property var template
    property var maxNumber

    property bool   addNewTr  : true
    property var    tripDate
    property string description
    property real   km
    property string projId

    canAccept: txtKilometer.text !== "0"

    onAccepted: {
        rawText = txtRaw.text === "" ? txtFormula.text : txtRaw.text
        // addTrip(trid, tripDate, descriptn, kilometer, prid)
        Database.addTrip(generic.tripId, tripDate, txtDescr.text, kilo, projid)
        dialog.callback(true, false)
    }

    onRejected: {
        dialog.callback(false, false)
    }

    function getThisTrip(tripId) {
        if (tripid === undefined) {
            addNewTrip  = true
            tripDate    = Qt.formatDate(new Date())
            description = ""
            km          = 0
            projId      = ""
        }
        else {
            var trip = Database.getOneTrip(tripid)
            console.log("This trip: " + JSON.stringify(trip))
            tripDate    = trip.tripDate
            description = trip.descriptn
            km          = trip.kilometer
            projId      = trip.projId

        }
    }

    Component.onCompleted: getThisTrip(tripId);

    SilicaFlickable {
        id: tripView

        VerticalScrollDecorator {}

        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
        contentHeight: column.height // + Theme.itemSizeMedium
//        quickScroll : true

        Column {
            id: column
            width: parent.width
            anchors {
                top: pageHeader.bottom
                margins: 0
            }

//            spacing: Theme.paddingSmall

            PageHeader {
                id: pageHeader
                title: (addNewtrip ? "Add trip" : "Edit trip")
            }

            TextField {
                id: txtKilometer
                focus: true
                width: parent.width
                label: qsTr("Kilometer")
                placeholderText: label
                placeholderColor: Theme.secondaryColor
                color: Theme.primaryColor
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: txtTripDate.focus = true
            }

            ValueButton {
                id: txtTripDate

                function openDateDialog() {
                    var obj = pageStack.animatorPush("Sailfish.Silica.DatePickerDialog",
                                                     { date: tripDate })

                    obj.pageCompleted.connect(function(page) {
                        page.accepted.connect(function() {
                            value = page.dateText
                            tripDate = page.date
                        })
                    })
                }

                label: qsTr("Date")
                value: tripDate
                width: parent.width
                onClicked: openDateDialog()
            }

            TextArea {
                id: txtDescr
                width: parent.width
                label: qsTr("Description")
                placeholderText: label
                placeholderColor: Theme.secondaryColor
                color: Theme.primaryColor
//                EnterKey.enabled: text.length > 0
            }

        }
    }
}
