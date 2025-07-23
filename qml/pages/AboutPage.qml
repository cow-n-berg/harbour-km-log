import QtQuick 2.6
import "../modules/Opal/About"

AboutPageBase {
    appName: qsTr("Kilometer")
    appIcon: Qt.resolvedUrl("../images/harbour-km-log.svg")
    appVersion: generic.version
//    appRelease: APP_RELEASE
    description: "<p>"
                 + qsTr("Kilometer is a log serving two purposes.")
                 + "</p><p>&nbsp;</p><p>"
                 + qsTr("Firstly, kilometers made per car, to be invoiced to a client and/or to be paid to the owner (e.g. you), to cover the costs.")
                 + "</p><p>&nbsp;</p><p>"
                 + qsTr("Secondly, my bicycle guy prompted me to show up again with my new bicycle after 300 km - not earlier and certainly not later. And then he said the same for a repaired folding bike.")
                 + "</p><p>&nbsp;</p><p>"
                 + qsTr("So here we are...")
                 + "</p><p>&nbsp;</p><p>"
                 + qsTr("(With special thanks to nephros for pointing out the Opal library.)")
                 + "</p>"
    authors: "2025 Rob Kouwenberg"
    licenses: License { spdxId: "GPL-3.0-or-later" }
    attributions: //[
        Attribution {
            name: "Opal"
            entries: "Mirian Margiani (ichthyosaurus)"
            licenses: License { spdxId: "GPL-3.0-or-later" }
        }
    //]

    sourcesUrl: "https://github.com/cow-n-berg/harbour-km-log"

    changelogItems: [
        // add new entries at the top
        ChangelogItem {
            version: "0.5-2"
            date: "2025-07-23"
            paragraphs: "Swedish translation by eson57."
        },
        ChangelogItem {
            version: "0.5-0"
            date: "2025-04-06"
            paragraphs: "Option to show or hide completed projects."
        },
        ChangelogItem {
            version: "0.4-4"
            date: "2025-03-14"
            paragraphs: "Small changes."
        },
        ChangelogItem {
            version: "0.4-1"
            date: "2025-03-06"
            paragraphs: "Small changes."
        },
        ChangelogItem {
            version: "0.4-0"
            date: "2025-03-04"
            paragraphs: "First published version."
        },
        ChangelogItem {
            version: "0.3-6"
            date: "2025-02-27"
            paragraphs: "First usable version."
        }
    ]
}
