/* based on JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.0
import "jsonpath.js" as JsonPath

Item {
    property string source: ""
    property string json: ""
    property string query: ""
    property string eTag: ""
    property string userAgent: "Ubuntu Touch Xxedule"
    property Item activityIndicator
    property Item cache

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    onSourceChanged: {
        if (source) {
            if (activityIndicator) activityIndicator.running = true

            // get from cache
            eTag = ''
            if (cache) {
                eTag = cache.getETag(source)
                json = cache.getJson(source)
            }

            var xhr = new XMLHttpRequest;
            xhr.open("GET", source);
            xhr.setRequestHeader("If-None-Match", eTag)
            xhr.setRequestHeader("User-Agent", userAgent)
            xhr.setRequestHeader("Accept", "application/json")
            xhr.onreadystatechange = function() {
                if (xhr.readyState == XMLHttpRequest.DONE) {
                    if (xhr.status == 200) {
                        eTag = xhr.getResponseHeader("ETag")
                        json = xhr.responseText;
                        if (cache) cache.put(source, eTag, json)
                    }
                    if (activityIndicator) activityIndicator.running = false
                }
            }
            xhr.send();
        }
    }

    onJsonChanged: updateJsonModel()
    onQueryChanged: updateJsonModel()

    function updateJsonModel() {
        model.clear();

        if ( json === "" )
            return;

        var objectArray = parseJsonString(json, query);
        for ( var key in objectArray ) {
            var jo = objectArray[key];
            model.append( jo );
        }
    }

    function parseJsonString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JsonPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }
}
