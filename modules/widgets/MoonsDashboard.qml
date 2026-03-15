pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs.modules.globals
import qs.modules.theme
import qs.modules.components
import qs.modules.services
import qs.modules.widgets.dashboard
import qs.config

// ─────────────────────────────────────────────────────────────────
// MoonsDashboard
// Wraps the Ambxst Dashboard view inside a floating panel that is
// triggered by the bar's DashboardButton (GlobalStates.sidebarLeftOpen).
// It inherits End-4 services (Audio, Network, Battery, Notifications…)
// and passes them into the Ambxst Dashboard tabs.
// ─────────────────────────────────────────────────────────────────
Item {
    id: root

    required property ShellScreen screen

    // ── Visibility driven by End-4 global state ──────────────────
    readonly property bool visible_: GlobalStates.sidebarLeftOpen
    readonly property bool dashboardOpen: visible_

    // ── Geometry ─────────────────────────────────────────────────
    readonly property int panelWidth:  760
    readonly property int panelHeight: 500
    readonly property int panelRadius: 22
    readonly property int panelTopOffset: 60   // distance below bar top edge

    // ── Animation ────────────────────────────────────────────────
    property real _scale: visible_ ? 1.0 : 0.88
    property real _opacity: visible_ ? 1.0 : 0.0

    Behavior on _scale   { NumberAnimation { duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
    Behavior on _opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuart } }

    // ═════════════════════════════════════════════════════════════
    // Panel popup
    // ═════════════════════════════════════════════════════════════
    Rectangle {
        id: panel
        width: root.panelWidth
        height: root.panelHeight
        radius: root.panelRadius

        // Centre below the bar capsule
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.panelTopOffset

        // Blurred translucent background
        color: Qt.rgba(
            Appearance.colors.colLayer0.r,
            Appearance.colors.colLayer0.g,
            Appearance.colors.colLayer0.b,
            0.88)
        border.width: 1
        border.color: Qt.rgba(
            Appearance.colors.colLayer0Border.r,
            Appearance.colors.colLayer0Border.g,
            Appearance.colors.colLayer0Border.b,
            0.45)

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 32
            blur: 0.65
        }

        // Scale + opacity animation
        scale:   root._scale
        opacity: root._opacity
        transformOrigin: Item.Top
        visible: root._opacity > 0.01

        // Drop shadow
        StyledDropShadow {
            anchors.fill: parent
            source: panel
            spread: 0
            radius: 24
            samples: 36
            color: Qt.rgba(0, 0, 0, 0.35)
        }

        // ── Clip to rounded rect ────────────────────────────────
        clip: true

        // ── Dashboard content ───────────────────────────────────
        Dashboard {
            id: dashboardContent
            anchors.fill: parent
            anchors.margins: 0
            // leftPanelWidth exposed by Ambxst Dashboard
            leftPanelWidth: 48

            // Bridge: tell Ambxst that the dashboard is open
            // (Ambxst's Dashboard.isVisible reads GlobalStates.dashboardOpen)
        }
    }

    // ── Close on click outside ─────────────────────────────────
    MouseArea {
        z: -1
        anchors.fill: parent
        enabled: root.visible_
        onClicked: GlobalStates.sidebarLeftOpen = false
    }
}
