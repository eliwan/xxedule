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

    Cache {
        id: jsonCache
        maxItems: -1
    }

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

            property string scheduleHref

            ListModel {
                id: scheduleItems

                function getFromTime(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).fromTime: ""
                }
                function getToTime(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).toTime: ""
                }
                function getRoom(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).roomName: ""
                }
                function getTitle(idx) {
                    if (idx >= 0 && idx < count) {
                        var entry = get(idx)
                        if (entry.talk && entry.talk.title) return entry.talk.title
                        if (entry["break"]) return entry["break"].nameEN
                    }
                    return ""
                }
            }

            ActivityIndicator {
                id: scheduleActivityIndicator
                anchors.right: parent.right
            }

            JsonListModel {
                    id: scheduleJsonItems
                    model: scheduleItems
                    query: "$.slots"
                    activityIndicator: scheduleActivityIndicator
                    cache: jsonCache
                }

            onScheduleHrefChanged: scheduleJsonItems.source = scheduleHref

            Column {
                id: scheduleLayout

                anchors {
                    fill: parent
                    margins: units.gu(2)
                }

                Empty {
                    id: scheduleDelegate
                    //progression: true
                    onClicked: {
                        presentation.updatePresentation(scheduleItems.get(index))
                        pageStack.push(presentation)
                    }
                    Column {
                        //anchors.fill: parent
                        spacing: units.gu(1)
                        Text { text: scheduleItems.getTitle(index) }
                        Row {
                            spacing: units.gu(1)
                            Text {
                                width: units.gu(8)
                                text: scheduleItems.getFromTime(index)
                            }
                            Text {
                                width: units.gu(8)
                                text: scheduleItems.getToTime(index)
                            }
                            Text {
                                width: units.gu(13)
                                text: scheduleItems.getRoom(index)
                            }
                        }
                    }
                }

                ListView {
                    anchors.fill: parent
                    model: scheduleItems

                    delegate: Standard {
                        progression: true
                        onClicked: {
                            presentation.updatePresentation(scheduleItems.get(index))
                            pageStack.push(presentation)
                        }
                        Column {
                            spacing: units.gu(.5)
                            Label {
                                width: units.gu(44)
                                text: scheduleItems.getTitle(index)
                                elide: Text.ElideMiddle
                            }
                            Row {
                                spacing: units.gu(1)
                                Label {
                                    width: units.gu(8)
                                    fontSize: "small"
                                    text: scheduleItems.getFromTime(index)
                                }
                                Label {
                                    width: units.gu(8)
                                    fontSize: "small"
                                    text: scheduleItems.getToTime(index)
                                }
                                Label {
                                    width: units.gu(6)
                                }
                                Label {
                                    width: units.gu(13)
                                    fontSize: "small"
                                    text: scheduleItems.getRoom(index)
                                }
                            }
                        }
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
            }

            JsonListModel {
                    id: dayJsonItems
                    model: dayItems
                    query: "$.links"
                    activityIndicator: daysActivityIndicator
                    cache: jsonCache
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
                        progression: true
                        onClicked: {
                            schedule.scheduleHref = dayItems.getHref(index)
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

            function updatePresentation(item) {
                presentationTime.text = item.fromTime + " - " + item.toTime
                presentationRoom.text = item.roomName
                presentationTitle.text = item.talk.title
                presentationSummary.text = item.talk.summary
                //presentationSpeakers.text = item.talk.speakers.name
            }

            Column {
                id : presentationLayout

                anchors {
                    fill: parent
                    margins: units.gu(2)
                }

                Text {
                    id: presentationTime
                }
                Text {
                    id: presentationRoom
                }
                Text {
                    id: presentationTitle
                }
                Text {
                    id: presentationSummary
                    wrapMode: Text.WordWrap
                }
                Text {
                    id: presentationSpeakers
                }
            }
       }

        Page {
            id: conferences
            title: "Xxedule - Conference"
            visible: false

            ListModel {
                id: conferenceItems

                function getHref(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).href: ""
                }
                function getTitle(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).title: ""
                }
            }

            ActivityIndicator {
                id: conferencesActivityIndicator
                anchors.right: parent.right
            }

            JsonListModel {
                    id: conferenceJsonItems
                    model: conferenceItems
                    query: "$.links"
                    activityIndicator: conferencesActivityIndicator
                    cache: jsonCache
                    //source: 'http://cfp.devoxx.be/api/conferences'
                }
            Component.onCompleted: conferenceJsonItems.source = 'http://cfp.devoxx.be/api/conferences'


            Component {
                id: conferenceItemDelegate
                Row {
                    spacing: units.gu(1)
                    Text { text: label }
                }
            }

            Column {
                id: conferencesLayout

                anchors {
                    fill: parent
                    margins: units.gu(2)
                }

                ListView {
                    anchors.fill: parent
                    model: conferenceItems
                    delegate: Standard {
                        text: title.replace(' CFP', '')
                        progression: true
                        onClicked: {
                            days.schedulesHref = conferenceItems.getHref(index) + '/schedules'
                            pageStack.push(days)
                        }
                    }
                }
            }
        }
    }
}

