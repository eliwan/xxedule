import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import "JSONListModel" as JSON


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

            JSON.JSONListModel {
                    id: dayJsonItems
                    model: dayItems
                    query: "$.links"
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

            ListModel {
                id: currencies
                ListElement {
                    currency: "EUR"
                    rate: 1.0
                }

                function getCurrency(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).currency: ""
                }

                function getRate(idx) {
                    return (idx >= 0 && idx < count) ? get(idx).rate: 0.0
                }
            }

            XmlListModel {
                id: ratesFetcher
                source: "http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml"
                namespaceDeclarations: "declare namespace gesmes='http://www.gesmes.org/xml/2002-08-01';"
                                       +"declare default element namespace 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref';"
                query: "/gesmes:Envelope/Cube/Cube/Cube"

                onStatusChanged: {
                    if (status === XmlListModel.Ready) {
                        for (var i = 0; i < count; i++)
                            currencies.append({"currency": get(i).currency, "rate": parseFloat(get(i).rate)})
                    }
                }

                XmlRole { name: "currency"; query: "@currency/string()" }
                XmlRole { name: "rate"; query: "@rate/string()" }
            }

            ActivityIndicator {
                objectName: "activityIndicator"
                anchors.right: parent.right
                running: ratesFetcher.status === XmlListModel.Loading
            }

            Component {
                id: currencySelector
                Popover {
                    Column {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        height: pageLayout.height
                        Header {
                            id: header
                            text: i18n.tr("Select currency")
                        }
                        ListView {
                            clip: true
                            width: parent.width
                            height: parent.height - header.height
                            model: currencies
                            delegate: Standard {
                                objectName: "popoverCurrencySelector"
                                text: currency
                                onClicked: {
                                    caller.currencyIndex = index
                                    caller.input.update()
                                    hide()
                                }
                            }
                        }
                    }
                }
            }

            Column {
                id: pageLayout

                anchors {
                    fill: parent
                    margins: units.gu(2)
                }
                spacing: units.gu(1)

                Row {
                    spacing: units.gu(1)

                    Button {
                        id: selectorFrom
                        objectName: "selectorFrom"
                        property int currencyIndex: 0
                        property TextField input: inputFrom
                        text: currencies.getCurrency(currencyIndex)
                        onClicked: PopupUtils.open(currencySelector, selectorFrom)
                    }

                    TextField {
                        id: inputFrom
                        objectName: "inputFrom"
                        errorHighlight: false
                        validator: DoubleValidator {notation: DoubleValidator.StandardNotation}
                        width: pageLayout.width - 2 * parent.margins - parent.buttonWidth
                        height: units.gu(5)
                        font.pixelSize: FontUtils.sizeToPixels("medium")
                        text: '0.0'
                        onTextChanged: {
                            if (activeFocus) {
                                inputTo.text = convert(inputFrom.text, selectorFrom.currencyIndex, selectorTo.currencyIndex)
                            }
                        }
                        function update() {
                            text = convert(inputTo.text, selectorTo.currencyIndex, selectorFrom.currencyIndex)
                        }
                    }
                }

                Row {
                    spacing: units.gu(1)
                    Button {
                        id: selectorTo
                        objectName: "selectorTo"
                        property int currencyIndex: 1
                        property TextField input: inputTo
                        text: currencies.getCurrency(currencyIndex)
                        onClicked: PopupUtils.open(currencySelector, selectorTo)
                    }

                    TextField {
                        id: inputTo
                        objectName: "inputTo"
                        errorHighlight: false
                        validator: DoubleValidator {notation: DoubleValidator.StandardNotation}
                        width: pageLayout.width - 2 * parent.margins - parent.buttonWidth
                        height: units.gu(5)
                        font.pixelSize: FontUtils.sizeToPixels("medium")
                        text: '0.0'
                        onTextChanged: {
                            if (activeFocus) {
                                inputFrom.text = convert(inputTo.text, selectorTo.currencyIndex, selectorFrom.currencyIndex)
                            }
                        }
                        function update() {
                            text = convert(inputFrom.text, selectorFrom.currencyIndex, selectorTo.currencyIndex)
                        }
                    }
                }

                Button {
                    id: clearBtn
                    objectName: "clearBtn"
                    text: i18n.tr("Clear")
                    width: units.gu(12)
                    onClicked: {
                        inputTo.text = '0.0';
                        inputFrom.text = '0.0';
                    }
                }

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

