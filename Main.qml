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

    function getPresentationTitle(entry) {
        if (entry.talk && entry.talk.title) return entry.talk.title
        if (entry["break"]) return entry["break"].nameEN
        return ''
    }

    function getPresentationSummary(entry) {
        if (entry.talk && entry.talk.summary) return entry.talk.summary
        return ''
    }

    function getPresentationSpeakers(entry) {
        var res = ''
        if (entry.talk && entry.talk.speakers) {
            var speakers = entry.talk.speakers
            if (speakers) {
                for (var index = 0; index < speakers.length; ++index) {
                    var speaker = speakers[index];
                    if (res) {
                        res = res + '\r\n' + speaker.link.title
                    } else {
                        res = speaker.link.title
                    }
                }
            }
        }
        return res
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
                    updateTitle()
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
                        return getPresentationTitle(entry)
                    }
                    return ""
                }

                function updateTitle() {
                    schedule.title = 'Schedule' + (count > 0 ? ' - ' + get(0).day : '')
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
                presentationFromTime.text = item.fromTime
                presentationToTime.text = item.toTime
                presentationRoom.text = item.roomName
                presentationTitle.text = getPresentationTitle(item)
                presentationSummary.text = getPresentationSummary(item)
                presentationSpeakers.text = getPresentationSpeakers(item)
            }

            Flickable {
                id: presentationFlickable
                anchors {
                    fill: parent
                    margins: units.gu(2)
                }
                contentHeight: contentItem.childrenRect.height

                Column {
                    id : presentationLayout
                    width: parent.width
                    spacing: units.gu(1)

                    Row {
                        spacing: units.gu(1)
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: 'Time'
                            width: units.gu(5)
                        }

                        TextField {
                            id: presentationFromTime
                            width: units.gu(8)
                            readOnly: true

                            UbuntuShape {
                                z: -1
                                color: Theme.palette.normal.field
                                anchors.fill: parent
                            }
                        }
                        TextField {
                            id: presentationToTime
                            width: units.gu(8)
                            readOnly: true

                            UbuntuShape {
                                z: -1
                                color: Theme.palette.normal.field
                                anchors.fill: parent
                            }
                        }
                    }
                    Row {
                        spacing: units.gu(1)
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: 'Room'
                            width: units.gu(5)
                        }
                        TextField {
                            id: presentationRoom
                            width: units.gu(20)
                            readOnly: true

                            UbuntuShape {
                                z: -1
                                color: Theme.palette.normal.field
                                anchors.fill: parent
                            }
                        }
                    }
                    TextArea {
                        id: presentationTitle
                        width: parent.width
                        autoSize: true
                        maximumLineCount: 0
                        readOnly: true

                        UbuntuShape {
                            z: -1
                            color: Theme.palette.normal.field
                            anchors.fill: parent
                        }
                    }
                    TextArea {
                        id: presentationSummary
                        width: parent.width
                        autoSize: true
                        maximumLineCount: 0
                        readOnly: true

                        UbuntuShape {
                            z: -1
                            color: Theme.palette.normal.field
                            anchors.fill: parent
                        }
                    }
                    TextArea {
                        id: presentationSpeakers
                        width: parent.width
                        autoSize: true
                        maximumLineCount: 0
                        readOnly: true

                        UbuntuShape {
                            z: -1
                            color: Theme.palette.normal.field
                            anchors.fill: parent
                        }
                    }
                }
            }
            Scrollbar {
                flickableItem: presentationFlickable
                align: Qt.AlignTrailing
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

