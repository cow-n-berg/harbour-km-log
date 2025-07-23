import QtQuick 2.6
import Sailfish.Silica 1.0
import "../modules/Opal/Tabs"

Page {
    id: root

    allowedOrientations: Orientation.Portrait

    TabView {
        id: tabs
        anchors.fill: parent
        currentIndex: 1
        tabBarPosition: Qt.AlignTop

        Tab {
            id: targTab
            title: qsTr("Targets")


            Component {
                TargetTab { }
            }
        }

        Tab {
            id: invcTab
            title: qsTr("Invoices")

            Component {
                InvoiceTab { }
            }
        }

        Tab {
            id: exptTab
            title: qsTr("Export csv")

            Component {
                ExportTab { }
            }
        }
    }
}
