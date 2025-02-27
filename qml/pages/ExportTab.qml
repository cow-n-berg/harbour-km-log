import QtQuick 2.2
import Sailfish.Silica 1.0
//import Nemo.Notifications 1.0
import "../modules/Opal/Delegates"
import "../modules/Opal/Tabs"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

TabItem {
    id: exportTab

    property string csvSeparator : generic.csvSeparator
    property string csvDecimal   : generic.csvDecimal
    property string copyMessage  : ""
    property string csv          : ""

    ListModel {
        id: listExport

        // Available csvTrips
        // csvLine

        function update()
        {
            listExport.clear();
            csv = ";"
            var csvTrips = Database.showCsvTrips(csvSeparator, csvDecimal);
            for (var i = 0; i < csvTrips.length; ++i) {
                listExport.append(csvTrips[i]);
                csv += csvTrips[i].csvLine + "\n";
                console.log( JSON.stringify(csvTrips[i]));
            }
            console.log( "listExport updated");
        }
    }

    Component.onCompleted: listExport.update()

    Timer {
        id: highlightTimer
        interval: 500
        running: false
        onTriggered: {
            iconClipboard.icon.color = Theme.secondaryColor
        }
    }

//    Notification {
//        id: notification

//        summary: copyMessage
//        body: "Kilometer"
//        expireTimeout: 500
//        urgency: Notification.Low
//        isTransient: true
//    }

    SilicaFlickable {
        id: flick
        anchors {
            fill: parent
        }

        VerticalScrollDecorator {
            flickable: flick
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            ButtonLayout {
                Button {
                    id: iconClipboard
                    anchors.horizontalCenter: flick.horizontalCenter

                    text: qsTr("Click to copy csv to clipboard")
                    icon.source: "image://theme/icon-m-clipboard"
                    icon.color: Theme.primaryColor
                    onClicked: {
                        Clipboard.text = csv
                        copyMessage = qsTr("csv text copied to clipboard")
                        iconClipboard.icon.color = Theme.highlightColor
                        highlightTimer.start()
//                        notification.publish()
                    }
                }
            }

            ViewPlaceholder {
                id: placehTot
                enabled: listExport.count === 0
                text: "No trips yet"
                hintText: "Add some trips,\nand/or create some projects"
            }

            DelegateColumn {
                model: listExport
                delegate: OneLineDelegate {
                    text: csvLine
                }
            }
        }
    }
}
