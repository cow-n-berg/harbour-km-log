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

    property bool   addNewTrip : true
    property var    tripId
    property var    tripDate
    property string description
    property real   km
    property string proj

    property var    boxList    : []
    property int    boxIndex
    property bool   boxIsSet   : false

//    onOpened: prepareProj();

    canAccept: txtKilo.text.length > 0

    onAccepted: {
        console.log("Accepted Dialog")
        km          = txtKilo.text
        tripDate    = txtDate.text
        description = txtDesc.text
//        proj        = boxProj.currentItem
        console.log("New trip: " + "|" + tripDate + "|" + description + "|" + km + "|" + proj)
        // addTrip(addNewTrip, tripId, tripDate, descriptn, kilometer, project)
        Database.addTrip(addNewTrip, tripId, tripDate, description, km, proj)
        dialog.callback(true)
    }

    onRejected: {
        dialog.callback(false)
    }

    // Available Projects
    // project, invoiced, price, kmTarget, isTarget, projType, bgColor

    function prepareProj() {
//        listModel.clear();
        var projects = Database.getProjects();
        for (var i = 0; i < projects.length; ++i) {
            boxList.push(projects[i].project)
        }
        console.log( JSON.stringify(boxList));
        console.log( JSON.stringify(boxList.length));

        // Setting up the ListModel
        for (i = 0; i < boxList.length; ++i) {
            listModel.append( { listText: boxList[i] });
        }
        console.log( "listModel projects updated");

        boxIsSet = true
    }

    function prepareTrip(trId) {

        if (!boxIsSet) prepareProj();

        console.log("Prepare for editing: " + JSON.stringify(recId))
        if (recId === undefined) {
            console.log("New trip, providing defaults")
            var tmp = new Date()
            addNewTrip   = true
            tripId       = Qt.formatDateTime(tmp, "yyyy-MM-dd hh:mm:ss")
            txtDate.text = Qt.formatDateTime(tmp, "yyyy-MM-dd")
            txtDesc.text = ""
            txtKilo.text = ""
        }
        else {
            var trip = Database.getOneTrip(recId)
            console.log("Getting this trip for editing: " + JSON.stringify(trip))
            addNewTrip   = false
            tripId       = trip.tripId
            txtDate.text = trip.tripDate
            txtDesc.text = trip.descriptn
            txtKilo.text = trip.kilometer
        }

        // set the ComboBox right
        boxIndex = 1;
        for (i = 0; i < boxList.length; i++) {
            if (boxList[i] === projType) {
                boxIndex = i;
            }
        }
        typeBox.currentIndex = boxIndex;
    }

    DialogHeader {
        id: pageHeader
        title: (addNewTrip ? "Add trip" : "Edit trip")
    }

    Component.onCompleted: prepareTrip(recId);

    ListModel {
        id: listModel
    }

    IconButton {
        id: modifyDateButton

        width: Theme.iconSizeMedium
        height: width

        anchors {
            top: pageHeader.bottom
            right: parent.right
            margins: Theme.paddingMedium
        }

        icon.source: "image://theme/icon-m-date"

        onClicked: {
            console.log("modifyDateButton clicked")
            var dialogDate = pageStack.push(pickerDate, { date: new Date(txtDate.text) })
            dialogDate.accepted.connect(function() {
                console.log("You chose:", dialogDate.dateText)
                // use date, as dateText return varies
                txtDate.text = Qt.formatDateTime(new Date(dialogDate.date), "yyyy-MM-dd")
            })
        }

        Component {
            id: pickerDate
            DatePickerDialog {}
        }
    }

    Column {
        id: column
        width: parent.width
        anchors {
            top: pageHeader.bottom
            margins: Theme.paddingMedium
        }

        spacing: Theme.paddingSmall

        TextField {
            id: txtDate
            focus: true
            width: parent.width - modifyDateButton.width - Theme.paddingMedium * 2
            anchors {
                left: parent.left // modifyDateButton.right
            }
            label: qsTr("Date")
            placeholderText: label
            placeholderColor: Theme.secondaryColor
            color: Theme.primaryColor
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.onClicked: txtKilo.focus = true
        }


        TextField {
            id: txtKilo
            width: parent.width
            label: qsTr("Kilometer")
            placeholderText: label
            placeholderColor: Theme.secondaryColor
            color: Theme.primaryColor
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.enabled: text.length > 0
            EnterKey.onClicked: txtDesc.focus = true
        }
        ComboBox {
            id: boxProj
            label: qsTr("Project")
//                currentIndex: 1
            menu: ContextMenu {
                Repeater {
                    model: listModel
                    MenuItem {
                        text: listText;
                        onClicked: {
                            console.log("ComboBox onClicked: " + listText)
                            proj = listText
                        }
                    }
                }
            }
        }

        TextField {
            id: txtDesc
            width: parent.width
            label: qsTr("Description")
            placeholderText: label + " - " + qsTr("not mandatory")
            placeholderColor: Theme.secondaryColor
            color: Theme.primaryColor
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.onClicked: dialog.accept()
        }
    }
}

