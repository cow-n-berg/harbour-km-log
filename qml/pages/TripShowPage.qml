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
    // tripId
    // tripDate
    // descriptn
    // kilometer
    // project
    // price
    // isTarget
    // bgColor

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
            numberOfTrips = trips.length;
//            console.log(JSON.stringify(listModel.get(0)));
        }
    }

    Component.onCompleted: listModel.update();

    SilicaListView {
        id: listView
        model: listModel

        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
        spacing: Theme.paddingMedium

//        header: PageHeader {
//            id: pageHeader
//            title: ( numberOftrips ? numberOftrips : qsTr("No")) + " " + qsTr("trips") + ( hideFound ? qsTr(" to be found") : ", " + numberOfFinds + " " + qsTr("Found"))
//        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            id: placeh
            enabled: listModel.count === 0
            text: "No trips yet"
            hintText: "Pull down to add,\nand/or create some projects"
        }

        delegate: ListItem {
            id: listItem
            menu: contextMenu

            width: parent.width
            contentHeight: Theme.itemSizeSmall
            ListView.onRemove: animateRemoval(listItem)

//            Rectangle {
//                anchors.fill: listItem
//                color: bgColor
//                opacity: 0.4
//            }

            Label {
                id: date
                text: TF.truncateString(tripDate, 30)
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                width: listItem.width * 0.8
                anchors {
                    left: parent.left
                    right: km.left
                    margins: Theme.paddingSmall
                }
            }

            Label {
                id: km
                text: kilometer
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                anchors {
                    left: date.right
                    right: parent.right
                    margins: Theme.paddingSmall
                }
            }

            Label {
                id: desc
                text: TF.truncateString(descriptn, 30)
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                width: listItem.width * 0.8
                anchors {
                          top: date.bottom
                          left: parent.left
                          right: proj.left
                          margins: Theme.paddingSmall
                        }
            }

            Label {
                id: proj
                text: TF.truncateString(project, 10)
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                anchors {
                          top: km.bottom
                          left: desc.right
                          right: parent.right
                          margins: Theme.paddingSmall
                        }
            }

            Separator {
                width: parent.width
                color: Theme.secondaryColor
            }

            RemorsePopup { id: remorse }

//            Component {
//                id: contextMenu
//                ContextMenu {
//                    MenuItem {
//                        text: qsTr("View in browser")
//                        onClicked:  {
//                            console.log("Browser " + generic.browserUrl  + trip + ", id " + tripid)
//                            ExternalLinks.browse(generic.browserUrl + trip)
//                        }
//                    }
//                    MenuItem {
//                        text: qsTr("Edit")
//                        onClicked: {
//                            console.log("Edit " + index + ", id " + listModel[model.index].tripid)
//                        }
//                    }
//                    MenuItem {
//                        text: qsTr("Delete")
//                        onClicked: remorse.execute("Clearing trip", function() {
//                            console.log("Remove trip " + code.text)
////                            Database.deletetrip(code.text)
//                            dialog.callback(true)
//                        })
//                    }
//
//                }
//            }
        }

        PullDownMenu {
//            MenuItem {
//                text: qsTr("Show Contents DB in Console")
//                enabled: generic.debug
//                visible: generic.debug
//                onClicked: Database.showAllData()
//            }
//            MenuItem {
//                text: qsTr("About")
//                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
//            }
//            MenuItem {
//                text: qsTr("Settings")
//                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),
//                                          {callback: updateAfterDialog})
//            }
//            MenuItem {
//                text: qsTr("View projects")
//                onClicked: pageStack.push(Qt.resolvedUrl("ProjectPage.qml"))
//            }
            MenuItem {
                text: qsTr("Add trip")
                onClicked: pageStack.push(Qt.resolvedUrl("TripAddPage.qml"),
                                          {callback: updateAfterDialog})
            }
        }
    }
}
