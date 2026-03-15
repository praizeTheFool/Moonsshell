// ShapeCanvas stub - polyfill for systems without the Quickshell ShapeCanvas C++ plugin
// Falls back to a simple Rectangle. The shape enum is declared in MaterialShape.qml.
import QtQuick

Rectangle {
    id: root
    property var shape
    property double implicitSize: 32
    property bool polygonIsNormalized: true
    property var roundedPolygon
    implicitWidth: implicitSize
    implicitHeight: implicitSize
    radius: width / 2
    color: "transparent"
}
