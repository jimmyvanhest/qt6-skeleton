import QtQuick
import QtQuick.Window

Window {
    visible: true

    title: qsTr("qt6-skeleton")

    width: 640
    height: 480

    Text {
        anchors.centerIn: parent
        text: qsTr("Hello World")
        color: "black"
    }
}
