import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/TextFunctions.js" as TF

CoverBackground {
    id: coverPage

    Image {
        id: backgroundImage
        source: TF.iconUrl("icon-cover", Theme.colorScheme === Theme.LightOnDark)
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        opacity: 0.15
    }

    Item {
        anchors.fill: parent
        Label {
            id: coverLabel
            anchors.centerIn: parent
            text: generic.coverShowAppName ? "Kilometer" : ""
            color: Theme.primaryColor
        }
    }
//    CoverActionList {
//        CoverAction {
//            iconSource: "image://theme/icon-cover-new"
//            onTriggered: {
//                if (!generic.applicationActive) {
//                    pageStack.push(Qt.resolvedUrl("TripAddPage.qml"),
//                           {tripId: undefined, callback: undefined})
//                    generic.activate();
//                }
//            }
//        }
//    }
}
