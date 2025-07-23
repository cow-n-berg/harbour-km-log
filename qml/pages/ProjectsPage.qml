import QtQuick 2.6
import Sailfish.Silica 1.0
import "../modules/Opal/Delegates"
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Page {
    id: projectsPage

    property bool hideCompleted : generic.hideCompleted
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

    function descr(invoiced, txtPrice, txtKmTarget, isTarget, projType, isComplete) {
        var txt = '';

        txt += projType + ' | ';

        if (invoiced)
            txt += qsTr("Invoiced @ ") + txtPrice.replace(".", generic.csvDecimal);
        else
            txt += qsTr("Priceless");
        txt += ' | ';

        if (isTarget)
            txt += qsTr("Target: ") + txtKmTarget.replace(".", generic.csvDecimal);
        else
            txt += qsTr("No Target");
        txt += ' | ';

//        if (isComplete)
//            txt += qsTr("Completed");
//        else
//            txt += qsTr("Continuing");

        return txt
    }

    // Available Projects
    // project, invoiced, price, kmTarget, isTarget, projType, bgColor, isComplete

    ListModel {
        id: listModel

        function update()
        {
            listModel.clear();
            var projects = Database.getProjects(hideCompleted);
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

                delegate: ThreeLineDelegate {
                    id: projDelegat
                    title: qsTr("Status") + ": " + (isComplete ? qsTr("Completed") : qsTr("Continuing"))
                    text: project
                    description: descr(invoiced, txtPrice, txtKmTarget, isTarget, projType, isComplete)

                    property string recId : project

                    leftItem:  Item {
                        width: Theme.itemSizeMedium

                        Rectangle {
                            id: colRect
                            height: Theme.itemSizeMedium * 0.5
                            width: Theme.itemSizeMedium * 0.1
                            radius: width
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            color: bgColor
                        }

                        DelegateInfoItem {
//                            id: lftItem
                            text: isTarget ? txtKmTarget.replace(".", generic.csvDecimal) : txtPrice.replace(".", generic.csvDecimal);
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

                    Separator {
                        width: parent.width
                        color: Theme.secondaryColor
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
