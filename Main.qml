import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1


/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "xxeduleqml.eliwan"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(50)
    height: units.gu(75)

    property real spacing: units.gu(1)
    property real margins: units.gu(2)
    property real buttonWidth: units.gu(9)
    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            pageStack.push(conferences)
        }

        Page {
            id: schedule
            title: 'Schedule'
            visible: false

            property int dayIndex

            function updateDay(idx) {
                dayIndex = idx
                dayInfo.text = dayItems.getTitle(dayIndex)
            }

            Column {
                id: scheduleLayout

                anchors {
                    fill: parent
                    margins: units.gu(2)
                }
                spacing: units.gu(1)

                Row {
                    anchors.fill: parent
                    spacing: units.gu(1)

                    TextField {
                        id: dayInfo
                        objectName: "inputFrom"
                        errorHighlight: false
                        height: units.gu(5)
                        width: units.gu(46)
                        font.pixelSize: FontUtils.sizeToPixels("medium")
                        text: ''
                    }
                }
            }
        }

        Page {
            id: days
            title: 'Days'
            visible: false

            property string schedulesHref

            ListModel {
                id: dayItems

                // got eTag:941982863 (zonder Zz)
                ListElement {
                    href: "http://cfp.devoxx.be/api/conferences/DV15/schedules/monday/"
                    rel: "http://cfp.devoxx.be/api/profile/schedule"
                    title: "ZzMonday, 9th November 2015"
                }
                ListElement {
                    href: "http://cfp.devoxx.be/api/conferences/DV15/schedules/tuesday/"
                    rel: "http://cfp.devoxx.be/api/profile/schedule"
                    title: "ZzTuesday, 10th November 2015"

                }
                ListElement {
                    href: "http://cfp.devoxx.be/api/conferences/DV15/schedules/wednesday/"
                    rel: "http://cfp.devoxx.be/api/profile/schedule"
                    title: "ZzWednesday, 11th November 2015"
                }
                ListElement {
                    href: "http://cfp.devoxx.be/api/conferences/DV15/schedules/thursday/"
                    rel: "http://cfp.devoxx.be/api/profile/schedule"
                    title: "ZzThursday, 12th November 2015"

                }
                ListElement {
                    href: "http://cfp.devoxx.be/api/conferences/DV15/schedules/friday/"
                    rel: "http://cfp.devoxx.be/api/profile/schedule"
                    title: "ZzFriday, 13th November 2015"
                }

                function getHref(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).href: ""
                }
                function getTitle(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).title: ""
                }
            }

            ActivityIndicator {
                id: daysActivityIndicator
                anchors.right: parent.right
                running: dayJsonItems.isLoading
                onVisibleChanged: running = dayJsonItems.isLoading()
            }

            JsonListModel {
                    id: dayJsonItems
                    model: dayItems
                    query: "$.links"
                    activityIndicator: daysActivityIndicator
                }

            onSchedulesHrefChanged: dayJsonItems.source = schedulesHref

            Component {
                id: dayItemDelegate
                Row {
                    spacing: units.gu(1)
                    Text { text: label }
                }
            }

            Column {
                id: daysLayout

                anchors {
                    fill: parent
                    margins: units.gu(2)
                }

                ListView {
                    anchors.fill: parent
                    model: dayItems
                    delegate: Standard {
                        text: title
                        onClicked: {
                            schedule.updateDay(index)
                            pageStack.push(schedule)
                        }
                    }
                }
            }
        }

        Page {
            id: presentation
            title: 'Presentation'
            visible: false
       }

        Page {
            id: conferences
            title: i18n.tr("XxeduleQml")
            visible: false

            /*
            ActivityIndicator {
                objectName: "activityIndicator"
                anchors.right: parent.right
                running: ratesFetcher.status === XmlListModel.Loading
            }
            */

            Column {
                id: pageLayout

                anchors {
                    fill: parent
                    margins: units.gu(2)
                }
                spacing: units.gu(1)

                Button {
                    id: toDays
                    objectName: "toDays"
                    text: i18n.tr("to Days")
                    width: units.gu(12)
                    onClicked: {
                        days.schedulesHref = "http://cfp.devoxx.be/api/conferences/DV15/schedules/"
                        pageStack.push(days)
                    }
                }
            }
        }
    }
}

