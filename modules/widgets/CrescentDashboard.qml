pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs
import qs.modules.common
import qs.modules.common.widgets

// ─────────────────────────────────────────────────────────────────
// CrescentDashboard - floating dashboard panel
// Opens when GlobalStates.dashboardOpen = true
// ─────────────────────────────────────────────────────────────────
Scope {
    id: dashScope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: dashWindow
            required property ShellScreen modelData
            screen: dashWindow.modelData

            anchors {
                top:    true
                bottom: true
                left:   true
                right:  true
            }

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.namespace:     "crescentshell:dashboard"
            WlrLayershell.layer:         WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            visible: GlobalStates.dashboardOpen

            // Dim overlay - click to close
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.5)
                opacity: GlobalStates.dashboardOpen ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: GlobalStates.dashboardOpen = false
                }
            }

            // Dashboard panel
            Rectangle {
                id: panel
                width:  Math.min(860, dashWindow.width  - 80)
                height: Math.min(540, dashWindow.height - 80)
                anchors.centerIn: parent
                radius: 18
                color: {
                    try {
                        const c = Appearance.colors.colLayer0
                        if (c) return Qt.rgba(c.r, c.g, c.b, 0.95)
                    } catch(e) {}
                    return "#1e1e2e"
                }
                border.width: 1
                border.color: {
                    try {
                        const c = Appearance.colors.colLayer0Border
                        if (c) return Qt.rgba(c.r, c.g, c.b, 0.45)
                    } catch(e) {}
                    return "#45475a"
                }
                clip: true

                scale:   GlobalStates.dashboardOpen ? 1.0 : 0.90
                opacity: GlobalStates.dashboardOpen ? 1.0 : 0.0
                Behavior on scale   { NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.05 } }
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuart } }

                // Prevent click-through to dim layer
                MouseArea { anchors.fill: parent; onClicked: {} }

                // Dashboard content from Ambxst loaded dynamically
                // to avoid import chain issues at parse time
                Loader {
                    id: dashLoader
                    anchors.fill: parent
                    active: GlobalStates.dashboardOpen
                    source: Qt.resolvedUrl("dashboard/DashboardView.qml")

                    onStatusChanged: {
                        if (status === Loader.Error)
                            console.error("[CrescentDashboard] Failed to load DashboardView:", source)
                    }
                }
            }

            Keys.onEscapePressed: GlobalStates.dashboardOpen = false
        }
    }


}
