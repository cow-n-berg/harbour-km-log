import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Page {
    id: reportPage

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
    SilicaFlickable {
        PageHeader {
            id: pageHeader
            title: qsTr("Reports") //+ "     "
        }

        Column {

            anchors {
                fill: parent
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
            }

            Label {
                height: parent.height
                text: "Klaar voor actie"
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
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
                text: qsTr("View projects")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjectsPage.qml"))
            }
            MenuItem {
                text: qsTr("View trips")
                onClicked: pageStack.push(Qt.resolvedUrl("TripsPage.qml"))
            }
        }
    }
}
