import QtQuick 2.2
import Sailfish.Silica 1.0
import "../modules/Opal/Delegates"
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
            var trips = Database.getTrips();
            for (var i = 0; i < trips.length; ++i) {
                listModel.append(trips[i]);
                console.log( JSON.stringify(trips[i]));
            }
            console.log( "listModel trips updated");
//            console.log(JSON.stringify(listModel.get(0)));
        }
    }

    Component.onCompleted: listModel.update()

    SilicaFlickable {
        id: flick
        anchors.fill: parent

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

//            ButtonLayout {
//                Button {
//                    text: "Add Trip"
//                    icon.source: "image://theme/icon-splus-add"
//                    onClicked: pageStack.push(Qt.resolvedUrl("TripAddPage.qml"),
//                               {"recId": undefined, "copyFrom": false, callback: updateAfterDialog})
//                }
//            }

            ViewPlaceholder {
                id: placeh
                enabled: listModel.count === 0
                text: "No trips yet"
                hintText: "Pull down to add,\nand/or create some projects"
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
                            width: Theme.itemSizeMedium * 0.15
                            radius: width
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            color: bgColor
                        }

                        DelegateInfoItem {
                            id: kmItem
                            text: kilometer
                            description: qsTr("km")
                            alignment: Qt.AlignHCenter
                            anchors {
                                left: colRect.right
                                verticalCenter: colRect.verticalCenter
                            }
                        }

                    }

                    rightItem: DelegateIconButton {
                        iconSource: "image://theme/icon-m-clipboard" // TF.iconUrl("icon-copy", Theme.colorScheme === Theme.LightOnDark)
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

//            Rectangle {
//                id: rect
//                width: Theme.paddingMedium
//                height: parent.height - Theme.paddingSmall * 2
//                anchors {
//                    margins: Theme.paddingMedium
//                    left: parent.left
//                    verticalCenter: parent.verticalCenter
//                }
//                color: bgColor ? bgColor : "#555555"
//                opacity: 1
//            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Totals")
                onClicked: pageStack.push(Qt.resolvedUrl("TotalsPage.qml"))
            }
            MenuItem {
                text: qsTr("Invoices")
                onClicked: pageStack.push(Qt.resolvedUrl("ReportPage.qml"))
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
    //            MenuItem {
    //                text: qsTr("Settings")
    //                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),
    //                                          {callback: updateAfterDialog})
    //            }
        }
    }
}
