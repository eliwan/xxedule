import QtQuick 2.0

Item {
    property int maxItems: -1

    property variant sources: []
    property variant eTags: []
    property variant jsons: []


    function getETag(source) {
        var index = sources.indexOf(source)
        console.log("index of " + source + " is " + index)
        if (index >= 0) return eTags[index]
        return ''
    }

    function getJson(source) {
        var index = sources.indexOf(source)
        if (index >= 0) return jsons[index]
        return ''
    }

    function put(source, eTag, json) {
        var index = sources.indexOf(source)
        console.log("index of " + source + " is " + index)

        var copy // funny copying needed because variants are immutable
        if (index >= 0) {
            copy = sources
            copy[index] = source
            sources = copy
            copy = eTags
            copy[index] = eTag
            eTags = copy
            copy = jsons
            copy[index] = json
            jsons = copy
        } else {
            copy = sources
            copy.push(source)
            sources = copy
            copy = eTags
            copy.push(eTag)
            eTags = copy
            copy = jsons
            copy.push(json)
            jsons = copy
        }
        console.log("sources.length" + sources.length)
        console.log(sources)

        var length = sources.length
        if (maxItems > -1 && maxItems > length) {
            log.console("Should trim cache if needed")
            sources = sources.slice(length - maxLength)
            eTags = eTags.slice(length - maxLength)
            jsons = jsons.slice(length - maxLength)
        }
    }

    Component.onCompleted: {
        if (maxItems == -1) {
            put("http://cfp.devoxx.be/api/conferences/DV15/schedules",
                "941982863",
                "{
\"links\":
[
{
\"href\": \"http://cfp.devoxx.be/api/conferences/DV15/schedules/monday/\",
\"rel\": \"http://cfp.devoxx.be/api/profile/schedule\",
\"title\": \"Monday, 9th November 2015\"
},
{

\"href\": \"http://cfp.devoxx.be/api/conferences/DV15/schedules/tuesday/\",
\"rel\": \"http://cfp.devoxx.be/api/profile/schedule\",
\"title\": \"Tuesday, 10th November 2015\"
},
{
\"href\": \"http://cfp.devoxx.be/api/conferences/DV15/schedules/wednesday/\",
\"rel\": \"http://cfp.devoxx.be/api/profile/schedule\",
\"title\": \"Wednesday, 11th November 2015\"
},
{
\"href\": \"http://cfp.devoxx.be/api/conferences/DV15/schedules/thursday/\",
\"rel\": \"http://cfp.devoxx.be/api/profile/schedule\",
\"title\": \"Thursday, 12th November 2015\"
},
{
\"href\": \"http://cfp.devoxx.be/api/conferences/DV15/schedules/friday/\",
\"rel\": \"http://cfp.devoxx.be/api/profile/schedule\",
\"title\": \"Friday, 13th November 2015\"
}
]
}")
            put("http://cfp.devoxx.be/api/conferences",
                "",
                "{
\"content\": \"All conferences\",
\"links\":
[
{
\"href\": \"http://cfp.devoxx.be/api/conferences/DV15\",
\"rel\": \"http://cfp.devoxx.be/api/profile/conference\",
\"title\": \"See more details about Devoxx Belgium 2015\"
}
]
}")
        }
    }
}
