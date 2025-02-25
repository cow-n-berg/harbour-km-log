import QtQuick 2.2
import Sailfish.Silica 1.0
import "../modules/Opal/Tabs"

Page {
    id: root

//    anchors {
//        fill: parent
//    }

    allowedOrientations: Orientation.Portrait

    TabView {
        id: tabs
        anchors.fill: parent
        currentIndex: 1
        tabBarPosition: Qt.AlignTop

        Tab {
            id: targTab
            title: qsTr("Targets")

//            Label {
//                text: "test Targets"
//            }

            Component {
                TargetTab { }
            }
        }

        Tab {
            id: invcTab
            title: qsTr("Invoices")

//            Label {
//                text: "test Invoices"
//            }
            Component {
                InvoiceTab { }
            }
        }

        Tab {
            id: exptTab
            title: qsTr("Export csv")

//            Label {
//                text: "test Export"
//            }
//            Component { }
        }
    }
}
