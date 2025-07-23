import QtQuick 2.6
import Sailfish.Silica 1.0
import "../modules/Opal/Delegates"
import "../modules/Opal/Tabs"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

TabItem {
    id: invoiceTab

    property bool hideCompleted : generic.hideCompleted
    property int  listLength

    function header(detail, project) {
        var hdr = "";
        if (detail === -1)
            hdr = qsTr("Yearly totals");
        else if (detail === 0)
            hdr = qsTr("Monthly totals");
        else
            hdr = project;
        return hdr;
    }

    ListModel {
        id: listInvoice

        // Available Invoices
        // project, detail, tripMonth, txtPrice, txtKm, txtAmount

        function update()
        {
            listInvoice.clear();
            var totals = Database.showInvoices(hideCompleted);
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
                    text: header(detail, project)
                    description: txtKm.replace(",", generic.csvMille) + qsTr(" km @ ") + txtPrice.replace(".", generic.csvDecimal);
                    highlighted: detail === 0

                    leftItem: DelegateInfoItem {
                        width: Theme.itemSizeExtraLarge
                        text: tripMonth
                        alignment: Qt.AlignLeft
                    }

                    rightItem: Item {
                        width: Theme.itemSizeExtraLarge

                        Rectangle {
                            id: colRect
                            height: Theme.itemSizeMedium * 0.5
                            width: Theme.itemSizeMedium * 0.1
                            radius: width
                            anchors {
                                right: parent.right
//                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            color: bgColor
                            visible: detail === 1
                        }

//                    rightItem: DelegateInfoItem {
                        DelegateInfoItem {
                            id: infoItem
                            text: txtAmount.replace(".", generic.csvDecimal);
                            description: qsTr("euro")
                            alignment: Qt.AlignRight
                            anchors {
//                                right: parent.right
                                left: parent.left
                                verticalCenter: colRect.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
