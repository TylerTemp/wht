/*
  Copyright (C) 2015 Olavi Haapala.
  Contact: Olavi Haapala <ojhaapala@gmail.com>
  Twitter: @olpetik
  All rights reserved.
  You may use this file under the terms of BSD license as follows:
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config.js" as DB
Dialog {
    id: page

    property QtObject dataContainer: null
    property QtObject editMode: null
    property string description: "No description"
    property string project: "default" //coming later
    property double duration: 8
    property string uid: "0"
    property string dateText: "Today"
    property date selectedDate : new Date()
    property date timeNow : new Date()
    property int startSelectedHour : timeNow.getHours() - 8
    property int startSelectedMinute : timeNow.getMinutes()
    property int endSelectedHour : timeNow.getHours()
    property int endSelectedMinute : timeNow.getMinutes()

    function pad(n) { return ("0" + n).slice(-2); }

    function updateDateText(){
        var date = new Date(dateText);
        var now = new Date();
        if(now.toDateString() === date.toDateString())
            datePicked.value = "Today"
        else {
            var splitted = date.toDateString().split(" ");
            datePicked.value = splitted[1] + " " +splitted[2] + " "+ splitted[3];
        }
    }

    function saveHours() {
        if (descriptionTextArea.text)
           description = descriptionTextArea.text
        if (uid == "0")
            uid = DB.getUniqueId()

        var d = selectedDate
        console.log(d)
        //YYYY-MM-DD
        var yyyy = d.getFullYear().toString();
        var mm = (d.getMonth()+1).toString(); // getMonth() is zero-based
        var dd  = d.getDate().toString();
        var dateString = yyyy +"-"+ (mm[1]?mm:"0"+mm[0]) +"-"+ (dd[1]?dd:"0"+dd[0]); // padding

        var startTime = pad(startSelectedHour) + ":" + pad(startSelectedMinute);
        var endTime = pad(endSelectedHour) + ":" + pad(endSelectedMinute);

        console.log(dateString)
        //.replace(/-/g,"")
        DB.setHours(uid,dateString,startTime, endTime, duration,project,description)
        if (dataContainer != null)
            page.dataContainer.getHours()

        if (editMode != null)
            page.editMode.updateView()
    }


    SilicaFlickable {
        contentHeight: column.y + column.height
        width: parent.width
        height: parent.height
        //contentHeight: column.y + column.height
        Column {
            id: column

            DialogHeader {
                        acceptText: "Save"
                        cancelText: "Cancel"
            }

            spacing: 20
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter

            SectionHeader { text: "Description" }
            TextField{
                id: descriptionTextArea
                //focus: true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
                width: parent.width
                placeholderText: "Enter an optional description"
            }

            SectionHeader { text: "Select date and time" }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 300
                height: 80
                ValueButton {
                    id: datePicked
                    anchors.centerIn: parent
                    function openDateDialog() {
                        var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                        date: new Date()
                                     })

                        dialog.accepted.connect(function() {
                            value = dialog.dateText
                            selectedDate = dialog.date
                        })
                    }

                    label: "Date:"
                    value: dateText
                    width: parent.width
                    onClicked: openDateDialog()
                }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 300
                height: 80
                ValueButton {
                    id: startTime
                    anchors.centerIn: parent
                    function openTimeDialog() {
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hourMode: (DateTime.TwentyFourHours),
                                        hour: startSelectedHour,
                                        minute: startSelectedMinute,
                                     })

                        dialog.accepted.connect(function() {
                            value = dialog.timeText
                            startSelectedHour = dialog.hour
                            startSelectedMinute = dialog.minute
                            if (endSelectedHour < startSelectedHour)
                                endSelectedHour +=24
                         duration = ((((endSelectedHour - startSelectedHour)*60) + (endSelectedMinute - startSelectedMinute)) / 60).toFixed(2)
                            durationLabel.text = "Duration: " + duration +"h"
                         })
                    }

                    label: "Start time:"
                    value: pad(startSelectedHour) + ":" + pad(startSelectedMinute)
                    width: parent.width
                    onClicked: openTimeDialog()
                }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryHighlightColor
                radius: 10.0
                width: 300
                height: 80
                ValueButton {
                    id: endTime
                    anchors.centerIn: parent
                    function openTimeDialog() {
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                        hourMode: (DateTime.TwentyFourHours),
                                        hour: endSelectedHour,
                                        minute: endSelectedMinute,
                                     })

                        dialog.accepted.connect(function() {
                            value = dialog.timeText
                            endSelectedHour = dialog.hour
                            endSelectedMinute = dialog.minute
                            if (endSelectedHour < startSelectedHour)
                                endSelectedHour +=24
                            duration = ((((endSelectedHour - startSelectedHour)*60) + (endSelectedMinute - startSelectedMinute)) / 60).toFixed(2)
                            durationLabel.text = "Duration: " + duration +"h"
                        })
                    }

                    label: "End time:"
                    value: pad(endSelectedHour) + ":" + pad(endSelectedMinute)
                    width: parent.width
                    onClicked: openTimeDialog()
                }
            }
            SectionHeader { text: "Duration" }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                radius: 10.0
                width: 300
                height: 80

                Label {
                    id: durationLabel
                    anchors.centerIn: parent
                    color: "green"
                    text: "Duration: " + duration +"h"
                }
            }
            Component.onCompleted: {
                if (startSelectedHour < 0)
                    startSelectedHour = endSelectedHour + 16;
                if (startSelectedHour.length === 1)
                    startSelectedHour = "0" + startSelectedHour;
                if (endSelectedHour.length === 1)
                    endSelectedHour = "0" + endSelectedHour;
                if (startSelectedMinute.length === 1)
                    startSelectedMinute = "0" + startSelectedMinute;
                if (endSelectedMinute.length === 1)
                    endSelectedMinute = "0" + endSelectedMinute;
                if (description != "No description")
                    descriptionTextArea.text = description;
                if(dateText != "Today")
                    updateDateText()
            }
        }
    }
    onDone: {
            if (result == DialogResult.Accepted) {
                saveHours();
            }
        }
}