import QtQuick 2.2
import Sailfish.Silica 1.0
import "../modules/Opal/Delegates"
import "../modules/Opal/Tabs"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

TabItem {
    id: invoiceTab

    property int listLength

    ListModel {
        id: listInvoice

        // Available Invoices
        // project, detail, tripMonth, txtPrice, txtKm, txtAmount

        function update()
        {
            listInvoice.clear();
            var totals = Database.showInvoices();
            listLength = totals.length;
            for (var i = 0; i < listLength; ++i) {
                listInvoice.append(totals[i]);
                console.log( JSON.stringify(totals[i]));
            }
            console.log( "listInvoice updated");
        }
    }

    Component.onCompleted: listInvoice.update()

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
            spacing: Theme.paddingSmall

            ViewPlaceholder {
                id: placehInv
                enabled: listInvoice.count === 0
                text: "No invoices yet"
                hintText: "Add some trips,\nand/or create some projects"
            }

            DelegateColumn {
                model: listInvoice
                delegate: TwoLineDelegate {
                    text: project || qsTr("Monthly totals")
                    description: qsTr("Total of ") + txtKm + qsTr(" km @ ") + txtPrice.replace(".", generic.csvDecimal);
                    highlighted: detail === 0

                    leftItem: DelegateInfoItem {
                        text: tripMonth
                    }

                    rightItem: DelegateInfoItem {
                        text: txtAmount.replace(".", generic.csvDecimal);
                        description: qsTr("euro")
                        alignment: Qt.AlignRight
                    }
                }
            }
        }
    }
}
