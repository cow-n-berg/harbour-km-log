import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Page {
    id: tripsPage

    anchors {
        fill: parent
    }

    allowedOrientations: Orientation.Portrait

    function updateAfterDialog(updated) {
        if (updated) {
            listModel.update()
            listView.scrollToTop()
        }
    }

    // Available Trips
    // tripId, tripDate, descriptn, kilometer, project, projType, price, isTarget, bgColor

    ListModel {
        id: listModel

        function update()
        {
            listModel.clear();
            var trips = Database.getTrips();
            for (var i = 0; i < trips.length; ++i) {
                listModel.append(trips[i]);
                console.log( JSON.stringify(trips[i]));
            }
            console.log( "listModel trips updated");
//            console.log(JSON.stringify(listModel.get(0)));
        }
    }

    Component.onCompleted: listModel.update();

    //        IconButton {
    //            id: iconContainer
    //            anchors {
    //                right: listView.right - Theme.paddingMedium
    //                verticalCenter: pageHeader.verticalCenter
    //            }

    //            icon.source: "image://theme/icon-m-add"
    //            icon.color: Theme.primaryColor
    //            onClicked: pageStack.push(Qt.resolvedUrl("TripAddPage.qml"),
    //                                      {recId: undefined, callback: updateAfterDialog})
    //        }


    SilicaListView {
        id: listView
        model: listModel

        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
        spacing: Theme.paddingMedium

        header: PageHeader {
            id: pageHeader
            title: qsTr("Trips") //+ "     "
        }

        quickScroll : true

        VerticalScrollDecorator {}

        ViewPlaceholder {
            id: placeh
            enabled: listModel.count === 0
            text: "No trips yet"
            hintText: "Pull down to add,\nand/or create some projects"
        }

        delegate: ListItem {
            id: listItem
//            menu: contextMenu
            width: parent.width
//            ListView.onRemove: animateRemoval(listItem)

            onClicked: {
                console.log("Showing trip: " + tripId)
                pageStack.push(Qt.resolvedUrl("TripShowPage.qml"),
                      {"recId": tripId, callback: updateAfterDialog})
            }

            Rectangle {
                id: rect
                width: Theme.paddingMedium
                height: parent.height - Theme.paddingSmall * 2
                anchors {
                    margins: Theme.paddingMedium
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                color: bgColor ? bgColor : "#555555"
                opacity: 1
            }

            Label {
                id: km
                text: kilometer
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.primaryColor
                width: parent.width * 0.2
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: rect.right
                    margins: Theme.paddingSmall
                }
            }

            Label {
                id: date
                text: tripDate
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                anchors {
                    top: parent.top
                    left: km.right
                    margins: Theme.paddingSmall
                }
            }

            Label {
                id: proj
                text: project
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                width: parent.width * 0.4
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: Theme.paddingSmall
                }
            }

            Label {
                id: desc
                text: descriptn
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                width: parent.width * 0.8
                anchors {
                    top: date.bottom
                    left: km.right
                    right: parent.right
                    margins: Theme.paddingSmall
                }
            }

            Separator {
                width: parent.width
                color: Theme.secondaryColor
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Show Contents DB in Console")
                enabled: generic.debug
                visible: generic.debug
                onClicked: Database.showAllData()
            }
//            MenuItem {
//                text: qsTr("About")
//                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
//            }
//            MenuItem {
//                text: qsTr("Settings")
//                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),
//                                          {callback: updateAfterDialog})
//            }
            MenuItem {
                text: qsTr("View invoices")
                onClicked: pageStack.push(Qt.resolvedUrl("ReportPage.qml"))
            }
            MenuItem {
                text: qsTr("View projects")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectsPage.qml"))
            }
            MenuItem {
                text: qsTr("Add trip")
                onClicked: pageStack.push(Qt.resolvedUrl("TripAddPage.qml"),
                                          {"recId": undefined, callback: updateAfterDialog})
            }
        }
    }
}
