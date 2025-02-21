import QtQuick 2.2
import Sailfish.Silica 1.0
import "../scripts/Database.js" as Database
import "../scripts/TextFunctions.js" as TF

Page {
    id: projectsPage

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

    // Available Projects
    // project, invoiced, price, kmTarget, isTarget, projType, bgColor

    ListModel {
        id: listModel

        function update()
        {
            listModel.clear();
            var projects = Database.getProjects();
            for (var i = 0; i < projects.length; ++i) {
                listModel.append(projects[i]);
                console.log( JSON.stringify(projects[i]));
            }
            console.log( "listModel projects updated");
//            console.log(JSON.stringify(listModel.get(0)));
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

        header: PageHeader {
            id: pageHeader
            title: qsTr("Projects") //+ "     "
        }

        quickScroll : true

        VerticalScrollDecorator {}

        ViewPlaceholder {
            id: placeh
            enabled: listModel.count === 0
            text: "No projects yet"
            hintText: "Pull down to add"
        }

        delegate: ListItem {
            id: listItem
            menu: contextMenu
            width: parent.width
//            contentHeight: Theme.itemSizeSmall
//            ListView.onRemove: animateRemoval(listItem)

            onClicked: {
                console.log("Clicked proj " + index)
                pageStack.push(Qt.resolvedUrl("ProjShowPage.qml"),
                               {"recId": project, callback: updateAfterDialog})
            }

            Rectangle {
                id: rect
                width: Theme.paddingMedium
                height: parent.height - Theme.paddingSmall * 2
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                color: bgColor ? bgColor : "#555555"
                opacity: 1
//                Label {
//                    text: ""
//                }
            }

            Label {
                id: proj
                text: project
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                anchors {
                    left: rect.right
                    right: parent.right
                    margins: Theme.paddingSmall
                }
            }

            Label {
                id: desc
                text: projType + ' | ' + (invoiced ? qsTr("Invoiced @ ") + (price ? price.toString() : "0") : qsTr("Priceless")) + ' | ' + (isTarget ? qsTr("Target: ") + kmTarget : qsTr("No Target"))
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                anchors {
                    top: proj.bottom
                    left: rect.right
                    right: parent.right
                    margins: Theme.paddingSmall
                }
            }

            Separator {
                width: parent.width
                color: Theme.secondaryColor
            }

            RemorsePopup { id: remorse }

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: "Edit project"
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("ProjAddPage.qml"),
                                           {"recId": project, callback: updateAfterDialog})
                        }
                    }
                    MenuItem {
                        text: qsTr("Delete this project")
                        onClicked: remorse.execute("Deleting project", function() {
                            console.log("Remove project " + project)
                            Database.deleteProj(project)
                            updateAfterDialog(true)
                        })
                    }
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
//                text: qsTr("About")
//                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
//            }
//            MenuItem {
//                text: qsTr("Settings")
//                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),
//                                          {callback: updateAfterDialog})
//            }
//            MenuItem {
//                text: qsTr("View projects")
//                onClicked: pageStack.push(Qt.resolvedUrl("ProjectPage.qml"))
//            }
            MenuItem {
                text: qsTr("Add project")
                onClicked: pageStack.push(Qt.resolvedUrl("ProjAddPage.qml"),
                                          {recId: undefined, callback: updateAfterDialog})
            }
        }
    }
}
