import QtQuick 2.2
import Sailfish.Silica 1.0
import "../modules/Opal/Delegates"
import "../modules/Opal/Tabs"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

TabItem {
    id: targetTab

    property int listLength

    ListModel {
        id: listTotal

        // Available Totals
        // project, detail, tripMonth, txtKmTarget, txtKm

        function update()
        {
            listTotal.clear();
            var totals = Database.showTotals();
            listLength = totals.length;
            for (var i = 0; i < listLength; ++i) {
//            for (var i = 0; i < totals.length; ++i) {
                listTotal.append(totals[i]);
//                console.log( JSON.stringify(totals[i]));
            }
            console.log( "listTotal updated");
        }
    }

    Component.onCompleted: listTotal.update()

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: listLength * Theme.itemSizeLarge
        flickableDirection: Flickable.VerticalFlick

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
                    highlighted: detail === 0

                    leftItem: Item {
                         width: Theme.itemSizeExtraLarge
                         height: Theme.itemSizeSmall

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
                             visible: detail === 0
                         }
                         DelegateInfoItem {
                             text: tripMonth
                             visible: detail === 1
                         }
                    }

                    rightItem: DelegateInfoItem {
                        text: txtKm.replace(".", generic.csvDecimal);
                        description: qsTr("km")
                        alignment: Qt.AlignRight
                    }
                }
            }
        }
    }
}
