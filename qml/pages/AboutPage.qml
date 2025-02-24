import QtQuick 2.2
import "../modules/Opal/About"

AboutPageBase {
    appName: qsTr("Kilometer")
    appIcon: Qt.resolvedUrl("../images/harbour-km-log.svg")
    appVersion: generic.version
//    appRelease: APP_RELEASE
    description: qsTr("Kilometer is a log for two purposes. " +
                      "Firstly, kilometers made per car, to be invoiced to a client " +
                      "and/or to be paid to the owner (you), to cover the costs. " +
                      "Secondly, my bicycle guy prompted me to show up again with my " +
                      "new bicycle after 300 km - not earlier and certainly not later. " +
                      "And then he said the same for a repaired folding bike. " +
                      "So here we are... " +
                      "(Special thanks to nephros for pointing out the Opal library.)")
    authors: "2025 Rob Kouwenberg"
    licenses: License { spdxId: "GPL-3.0-or-later" }
    attributions: [
        Attribution {
            name: "Opal"
            entries: ["ichthyosaurus"]
            licenses: License { spdxId: "GPL-3.0-or-later" }
        }
    ]

    sourcesUrl: "https://github.com/cow-n-berg/harbour-km-log"

    changelogItems: [
        // add new entries at the top
        ChangelogItem {
            version: "0.3-2"
            date: "2025-02-24"
            paragraphs: "First usable version."
        }
    ]
}
