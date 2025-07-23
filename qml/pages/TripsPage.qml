import QtQuick 2.6
import Sailfish.Silica 1.0
import "../modules/Opal/Delegates"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Page {
    id: tripsPage

    property bool hideCompleted : generic.hideCompleted
    property int listLength

    anchors {
        fill: parent
    }

    allowedOrientations: Orientation.Portrait

    function updateAfterDialog(updated) {
        if (updated) {
            listModel.update()
            flick.scrollToTop()
        }
    }

    // Available Trips
    // tripId, tripDate, descriptn, kilometer, project, projType, price, isTarget, bgColor

    ListModel {
        id: listModel

        function update()
        {
            listModel.clear();
            var trips = Database.getTrips(hideCompleted, null);
            listLength = trips.length;
            for (var i = 0; i < listLength; ++i) {
                listModel.append(trips[i]);
//                console.log( JSON.stringify(trips[i]));
            }
            console.log( "listModel trips updated");
//            console.log(JSON.stringify(listModel.get(0)));
        }
    }

    Component.onCompleted: listModel.update()

//    SilicaListView {
    SilicaFlickable {
        id: flick
        anchors.fill: parent
//        contentWidth: column.width
        contentHeight: listLength * Theme.itemSizeLarge
        flickableDirection: Flickable.VerticalFlick

        VerticalScrollDecorator {
            flickable: flick
        }

        quickScroll : true

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader {
                id: pageHeader
                title: qsTr("Trips")
            }

            ViewPlaceholder {
                id: placeh
                enabled: listModel.count === 0
                text: "No trips yet"
                hintText: "Pull down to add,\nand/or create some projects"
            }

            DelegateColumn {
                id: colDelegat
                model: listModel

                delegate: TwoLineDelegate {
                    id: tripDelegat
                    text: tripDate + '  ' + project
                    description: descriptn

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
                            text: kilometer.toString().replace(".", generic.csvDecimal);                            description: qsTr("km")
                            alignment: Qt.AlignHCenter
                            anchors {
                                left: colRect.right
                                verticalCenter: colRect.verticalCenter
                            }
                        }

                    }

                    rightItem: DelegateIconButton {
                        iconSource: "image://theme/icon-m-clipboard"
                        iconSize: Theme.iconSizeMedium
                        onClicked: pageStack.push(Qt.resolvedUrl("TripAddPage.qml"),
                                   {"recId": recId, "copyFrom": true, callback: updateAfterDialog})
                    }

                    onClicked: {
                        console.log("Showing trip: " + recId)
                        pageStack.push(Qt.resolvedUrl("TripShowPage.qml"),
                              {"recId": recId, callback: updateAfterDialog})
                    }
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Reports")
                onClicked: pageStack.push(Qt.resolvedUrl("ReportsPage.qml"))
            }
            MenuItem {
                text: qsTr("Projects")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectsPage.qml"))
            }
            MenuItem {
                text: qsTr("Add trip")
                onClicked: pageStack.push(Qt.resolvedUrl("TripAddPage.qml"),
                           {"recId": undefined, "copyFrom": false, callback: updateAfterDialog})
            }
        }
        PushUpMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),
                                          {callback: updateAfterDialog})
            }
        }
    }
}
