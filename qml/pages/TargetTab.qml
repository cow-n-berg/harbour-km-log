import QtQuick 2.2
import Sailfish.Silica 1.0
import "../modules/Opal/Delegates"
import "../modules/Opal/Tabs"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

TabItem {
    id: targetTab

//    anchors {
//        fill: parent
//    }

    ListModel {
        id: listTotal

        // Available Totals
        // project, detail, tripMonth, txtKmTarget, txtKm

        function update()
        {
            listTotal.clear();
            var totals = Database.showTotals();
            for (var i = 0; i < totals.length; ++i) {
                listTotal.append(totals[i]);
                console.log( JSON.stringify(totals[i]));
            }
            console.log( "listTotal updated");
        }
    }

    Component.onCompleted: listTotal.update()

    SilicaFlickable {
        id: flick
        anchors.fill: parent

        VerticalScrollDecorator {
            flickable: flick
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            ViewPlaceholder {
                id: placehTot
                enabled: listTotal.count === 0
                text: "No targets yet"
                hintText: "Add some trips,\nand/or create some projects"
            }

            DelegateColumn {
                model: listTotal
                delegate: TwoLineDelegate {
                    text: project
                    description: qsTr("Target is ") + txtKmTarget + qsTr(" km")

//                    showOddEven: true

                    leftItem: Item {
                         width: Theme.itemSizeSmall
                         height: width

                         Rectangle {
                             id: colRect
                             height: Theme.itemSizeMedium * 0.5
                             width: height
                             radius: Theme.itemSizeMedium * 0.15
                             anchors {
                                 left: parent.left
                                 verticalCenter: parent.verticalCenter
                             }
                             color: bgColor
                         }
                    }

                    rightItem: DelegateInfoItem {
                        text: txtKm
                        description: qsTr("km")
                        alignment: Qt.AlignRight
                    }
                }
            }
        }
    }
}
