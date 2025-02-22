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

    // Available Totals
    // project, detail, tripMonth, price, kilometer, amount

    ListModel {
        id: listModel

        function update()
        {
            listModel.clear();
            var totals = Database.showInvoices();
            for (var i = 0; i < totals.length; ++i) {
                listModel.append(totals[i]);
                console.log( JSON.stringify(totals[i]));
            }
            console.log( "listModel totals updated");
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

        PageHeader {
            id: pageHeader
            title: qsTr("Invoice reports") //+ "     "
        }

        ViewPlaceholder {
            id: placeh
            enabled: listModel.count === 0
            text: "No invoices yet"
            hintText: "Add some trips,\nand/or create some projects"
        }

        delegate: ListItem {
            id: listItem
//            menu: contextMenu
            width: parent.width
//            ListView.onRemove: animateRemoval(listItem)

            Label {
                id: date
                text: tripMonth
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                width: parent.width * 0.2
                anchors {
                    top: parent.top
                    left: parent.left
                    // margins: Theme.paddingSmall
                }
            }

            Label {
                id: proj
                text: TF.truncateString(project, 10)
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                width: parent.width * 0.3
                anchors {
                    top: parent.top
                    left: date.right
                    // margins: Theme.paddingSmall
                }
            }

            Label {
                id: km
                text: kilometer
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                width: parent.width * 0.18
                anchors {
                    top: parent.top
                    left: proj.right
                    // margins: Theme.paddingSmall
                }
            }

            Label {
                id: pric
                text: price
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                width: parent.width * 0.14
                anchors {
                    top: parent.top
                    left: km.right
                    // margins: Theme.paddingSmall
                }
            }

            Label {
                id: amnt
                text: amount
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                width: parent.width * 0.18
                anchors {
                    top: parent.top
                    left: pric.right
//                    right: parent.right
                    // margins: Theme.paddingSmall
                }
            }

            Separator {
                width: parent.width
                color: Theme.secondaryColor
            }
        }
    }
}
