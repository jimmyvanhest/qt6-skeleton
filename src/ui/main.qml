import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import App 1.0

Window {
    height: 480
    title: qsTr("Hello World")
    visible: true
    width: 640

    App {
        id: app
        number: 1
        string: "My String with my number: " + app.number
    }

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Label {
            text: "Number: " + app.number
        }

        Label {
            text: "String: " + app.string
        }

        Button {
            text: "Increment Number"

            onClicked: app.incrementNumber()
        }

        Button {
            text: "Say Hi!"

            onClicked: app.sayHi(app.string, app.number)
        }
    }
}
