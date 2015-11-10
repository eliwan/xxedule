/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

import QtQuick 2.0
import "jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string json: ""
    property string query: ""
    property string eTag: ""
    property string userAgent: "Ubuntu Touch Xxedule"

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    onSourceChanged: {
        console.log("----source:" + source)
        if (source) {
            var xhr = new XMLHttpRequest;
            xhr.open("GET", source);
            xhr.setRequestHeader("If-None-Match", eTag)
            xhr.setRequestHeader("User-Agent", userAgent)
            xhr.setRequestHeader("Accept", "application/json")
            console.log("xhr invoke" + source)
            xhr.onreadystatechange = function() {
                console.log("onready:" + xhr.readyState)
                if (xhr.readyState == XMLHttpRequest.DONE)
                    eTag = xhr.getResponseHeader("ETag")
                    console.log("got eTag:" + eTag)
                    json = xhr.responseText;
                    console.log("got json:" + json)
            }
            xhr.send();
        }
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function updateJSONModel() {
        if ( json === "" )
            return;

        model.clear();

        var objectArray = parseJSONString(json, query);
        for ( var key in objectArray ) {
            var jo = objectArray[key];
            model.append( jo );
        }
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);

        return objectArray;
    }
}
