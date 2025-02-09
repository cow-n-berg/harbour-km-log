import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Database.js" as Database
// import "../scripts/ExternalLinks.js" as ExternalLinks
// import "../scripts/TextFunctions.js" as TF

Page {
    id: cachesPage

    anchors {
        fill: parent
    }

    allowedOrientations: Orientation.Portrait

    property var  numberOfCaches : 0
    property var  numberOfFinds  : 0
    property bool hideFound      : generic.hideFoundCaches

    function updateAfterDialog(updated) {
        if (updated) {
            listModel.update()
            listView.scrollToTop()
        }
    }

    ListModel {
        id: listModel

        function update()
        {
            listModel.clear();
            numberOfFinds = 0;
            var caches = Database.getGeocaches(hideFound);
            for (var i = 0; i < caches.length; ++i) {
                listModel.append(caches[i]);
                numberOfFinds += caches[i].found ? 1 : 0;
                console.log( JSON.stringify(caches[i]));
            }
            console.log( "listModel Caches updated");
            console.log(JSON.stringify(listModel.get(0)));
            numberOfCaches = caches.length;
        }
    }

    Component.onCompleted: listModel.update();

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 1.0
//        radius: 10
        visible: generic.nightCacheMode
    }

    SilicaListView {
        id: listView
        model: listModel

        anchors {
            fill: parent
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
        spacing: Theme.paddingMedium

        header: PageHeader {
            id: pageHeader
            title: ( numberOfCaches ? numberOfCaches : qsTr("No")) + " " + qsTr("Geocaches") + ( hideFound ? qsTr(" to be found") : ", " + numberOfFinds + " " + qsTr("Found"))
        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            id: placeh
            enabled: listModel.count === 0
            text: "No geocaches yet"
            hintText: "Pull down to add,\nor go to Settings for examples"
        }

        delegate: ListItem {
            id: listItem
            menu: contextMenu

            width: parent.width
            contentHeight: Theme.itemSizeSmall
            ListView.onRemove: animateRemoval(listItem)

            Label {
                id: nameGC
                text: TF.truncateString(name, 35)
                font.pixelSize: Theme.fontSizeMedium
                anchors {
                    left: parent.left
                    right: foundGC.left
                    margins: Theme.paddingSmall
                }
                color: generic.primaryColor
            }
            onClicked: {
                console.log("Clicked GC " + index)
                generic.gcName = name
                generic.gcCode = geocache
                generic.gcId   = cacheid

                pageStack.push(Qt.resolvedUrl("MultiShowPage.qml"),
                               {callback: updateAfterDialog})
            }
//            onPressAndHold: {
//            }

            Label {
                id: codeGC
                text: geocache
                font.pixelSize: Theme.fontSizeSmall
                color: generic.secondaryColor
                anchors {
                          top: nameGC.bottom
                          left: parent.left
                          right: foundGC.left
                          margins: Theme.paddingSmall
                        }
            }

            Icon {
                id: foundGC
                anchors {
                          right: parent.right
                          margins: Theme.paddingSmall
                        }
                source: TF.foundIconUrl(found)
                color: generic.primaryColor
            }

            Separator {
                width: parent.width
                color: generic.secondaryColor
            }

            RemorsePopup { id: remorse }

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: qsTr("View in browser")
                        onClicked:  {
                            console.log("Browser " + generic.browserUrl  + geocache + ", id " + cacheid)
                            ExternalLinks.browse(generic.browserUrl + geocache)
                        }
                    }
//                    MenuItem {
//                        text: qsTr("Edit")
//                        onClicked: {
//                            console.log("Edit " + index + ", id " + listModel[model.index].cacheid)
//                        }
//                    }
//                    MenuItem {
//                        text: qsTr("Delete")
//                        onClicked: remorse.execute("Clearing geocache", function() {
//                            console.log("Remove geocache " + codeGC.text)
////                            Database.deleteCache(codeGC.text)
//                            dialog.callback(true)
//                        })
//                    }

                }
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
//                text: qsTr("Refresh page")
//                onClicked: { listModel.update() }
//            }
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),
                                          {callback: updateAfterDialog})
            }
            MenuItem {
                text: qsTr("Add Geocache Multi")
                onClicked: pageStack.push(Qt.resolvedUrl("MultiAddPage.qml"),
                                          {callback: updateAfterDialog})
            }
        }
        PushUpMenu {
            MenuItem {
                text: hideFound ? qsTr("Unhide found geocaches") : qsTr("Hide found geocaches")
                onClicked: {
                    hideFound = !hideFound
                    generic.hideFoundCaches = hideFound
                    Database.setSetting( "hideFoundCaches", generic.hideFoundCaches )
                    listModel.update()
                }
            }
        }
    }
}
