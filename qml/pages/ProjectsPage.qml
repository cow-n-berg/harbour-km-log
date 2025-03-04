import QtQuick 2.2
import Sailfish.Silica 1.0
import "../modules/Opal/Delegates"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Page {
    id: projectsPage

    property int listLength

    anchors {
        fill: parent
    }

    allowedOrientations: Orientation.Portrait

    function updateAfterDialog(updated) {
        if (updated) {
            listModel.update()
            flick.scrollToTop()
        }
    }

    // Available Projects
    // project, invoiced, price, kmTarget, isTarget, projType, bgColor

    ListModel {
        id: listModel

        function update()
        {
            listModel.clear();
            var projects = Database.getProjects();
            listLength = projects.length;
            for (var i = 0; i < listLength; ++i) {
                listModel.append(projects[i]);
                console.log( JSON.stringify(projects[i]));
            }
            console.log( "listModel projects updated");
        }
    }

    Component.onCompleted: listModel.update()

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: listLength * Theme.itemSizeLarge
        flickableDirection: Flickable.VerticalFlick

        VerticalScrollDecorator {
            flickable: flick
        }

        quickScroll : true

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader {
                id: pageHeader
                title: qsTr("Projects")
            }

            ViewPlaceholder {
                id: placeh
                enabled: listModel.count === 0
                text: "No projects yet"
                hintText: "Pull down to add"
            }

            DelegateColumn {
                model: listModel

                delegate: TwoLineDelegate {
                    id: projDelegat
                    text: project
                    description: projType + ' | ' + (invoiced ? qsTr("Invoiced @ ") + (price ? price.toString() : "0") : qsTr("Priceless")) + ' | ' + (isTarget ? qsTr("Target: ") + kmTarget : qsTr("No Target"))

                    property string recId : project

                    leftItem:  Item {
                        width: Theme.itemSizeMedium

                        Rectangle {
                            id: colRect
                            height: Theme.itemSizeMedium * 0.5
                            width: Theme.itemSizeMedium * 0.15
                            radius: width
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            color: bgColor
                        }

                        DelegateInfoItem {
//                            id: lftItem
                            text: isTarget ? txtKmTarget : txtPrice
                            alignment: Qt.AlignHCenter
                            anchors {
                                left: colRect.right
                                verticalCenter: colRect.verticalCenter
                            }
                        }

                    }

                    onClicked: {
                        console.log("Clicked proj " + index)
                        pageStack.push(Qt.resolvedUrl("ProjShowPage.qml"),
                              {"recId": recId, callback: updateAfterDialog})
                    }
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Add project")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjAddPage.qml"),
                                          {recId: undefined, callback: updateAfterDialog})
            }
        }
    }
}
