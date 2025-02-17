import QtQuick 2.2
import Sailfish.Silica 1.0
//import "../scripts/ExternalLinks.js" as ExternalLinks
//import "../scripts/TextFunctions.js" as TF

Page {
    id: aboutPage

    property string author: "Rob Kouwenberg"
    property string devMail: "sailfishapp@cow-n-berg.nl"
    property url devGithub: "https://github.com/cow-n-berg"
    property url repoGithub: "https://github.com/cow-n-berg/harbour-km-log"
    property string mailSubjectHeader: "[SailfishOS][km log " + generic.version + "] "
    property string mailErrorSubjectHeader: "[SailfishOS][km log " + generic.version + "][Error] "
    property string mailBodyHeader: "Hey Rob, "

//    allowedOrientations: Orientation.Landscape
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent

        contentWidth: parent.width;
        contentHeight: pageHeader.height + contentColumn.height + Theme.paddingLarge

        flickableDirection: Flickable.VerticalFlick

        PageHeader {
            id: pageHeader
            title: qsTr("About")
        }

        Column {
            id: contentColumn

            spacing: Theme.paddingLarge
            anchors {
                top: pageHeader.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width

            Rectangle {
                color: "transparent"
                width: parent.width
                height: childrenRect.height

                Image {
                    id: coverImage
                    source: Qt.resolvedUrl("../images/harbour-about-image.png")
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    clip: true
                    asynchronous: true
                    width: parent.width - 2*Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Label {
                    id: topText
                    anchors {
//                        top: parent.top
                        top: coverImage.bottom
                        topMargin: Theme.paddingSmall
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width - 2*Theme.paddingLarge
                    text: qsTr("GMFS - Geocaching Multi Formula Solver")
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    anchors {
                        top: topText.bottom
                        topMargin: Theme.paddingSmall
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width
                    text: qsTr("version %1").arg(version)
                    font.pixelSize: Theme.fontSizeExtraSmall
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity / 3)
                width: parent.width - 2*Theme.paddingLarge
                height: childrenRect.height + 2*Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter

                Label {
                    id: authorLabel
                    anchors {
                        top: parent.top
                        topMargin: Theme.paddingMedium
                        horizontalCenter: parent.horizontalCenter
                    }
                    font {
                        italic: true
                        pixelSize: Theme.fontSizeExtraSmall
                    }
                    color: generic.highlightColor
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("created by %1").arg(author)
                }

                Row {
                    id: authorLinksRow
                    anchors {
                        top: authorLabel.bottom
                        topMargin: Theme.paddingMedium
                        horizontalCenter: parent.horizontalCenter
                    }
                    spacing: Theme.paddingLarge

                    IconButton {
                        id: authorGithubButton
                        height: Theme.iconSizeMedium
                        width: Theme.iconSizeMedium
                        icon {
                            source: Qt.resolvedUrl("../images/icon-github.svg")
                            height: Theme.iconSizeMedium
                            fillMode: Image.PreserveAspectFit
                            color: Theme.primaryColor
                        }
                        onClicked: ExternalLinks.browse(repoGithub)
                    }

                    IconButton {
                        id: authorMailButton
                        height: Theme.iconSizeMedium
                        width: Theme.iconSizeMedium
                        icon {
                            source: "image://theme/icon-m-mail"
                            height: Theme.iconSizeMedium
                            fillMode: Image.PreserveAspectFit
                            color: Theme.primaryColor
                        }
                        onClicked: ExternalLinks.mail(constants.devMail, mailSubjectHeader, constants.mailBodyHeader)
                    }
                }

            }

            Label {
                id: codeLabel
                width: parent.width - 2*Theme.paddingLarge
                text: qsTr("The source code is available at Github.
                       <br/>You can contact me for any remarks,
                       <br/>bugs, feature requests, ideas,...")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                linkColor: generic.highlightColor
                onLinkActivated: ExternalLinks.browse(link)
            }

            Label {
                id: historyLabel
                width: parent.width - 2*Theme.paddingLarge
                text: qsTr("Android app GCC offers a
                       <br/>formula solver for geocaching,
                       <br/>but I don't like it that much.
                       <br/>Now there is a native app!")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                linkColor: generic.highlightColor
                onLinkActivated: ExternalLinks.browse(link)
            }

            Label {
                id: functionsLabel
                width: parent.width - 2*Theme.paddingLarge
                text: qsTr("GMFS is packed with powerful functions.
                       <br/>Check out the possibilities for importing
                       <br/>a gpx file from geocaching.com
                       <br/>(Premium membership only).
                       <br/>Or else, just copy the geocache page
                       <br/>into the import routine. I recommend
                       <br/>WlanKeyboard or TinyEdit for this.
                       <br/>Edit formulas and letters, and go!")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                linkColor: generic.highlightColor
                onLinkActivated: ExternalLinks.browse(link)
            }

            Label {
                id: extrasLabel
                width: parent.width - 2*Theme.paddingLarge
                text: qsTr("Many calculations have been added, like
                       <br/>intersections of lines and circles.
                       <br/>BTW: I started using it for Mysteries as
                       <br/>well, like the Bonus cache of a trail.
                       <br/>Just one waypoint with the formula, and
                       <br/>all letters to collect during the trail.")
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                linkColor: generic.highlightColor
                onLinkActivated: ExternalLinks.browse(link)
            }

            Label {
                id: enjoyLabel
                width: parent.width
                text: qsTr("Enjoy!")
                font.pixelSize: Theme.fontSizeLarge
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
