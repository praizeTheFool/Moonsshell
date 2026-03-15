pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

// ─────────────────────────────────────────────────────────────────
// CrescentShell BarContent
// Floating notch-style capsule. Always visible with solid fallback.
// ─────────────────────────────────────────────────────────────────
Item {
    id: root

    // ── Geometry ──────────────────────────────────────────────────
    readonly property int capsuleHeight: 44
    readonly property int capsuleRadius: 22
    readonly property int paddingH:      14
    readonly property int paddingV:       6
    readonly property int minWidth:      680

    required property var screen

    implicitWidth: Math.min(
        Math.max(capsuleRow.implicitWidth + paddingH * 2, minWidth),
        screen ? screen.width - 40 : 1400)
    implicitHeight: capsuleHeight

    // ── Capsule background ────────────────────────────────────────
    Rectangle {
        id: capsuleBg
        anchors.fill: parent
        radius: root.capsuleRadius

        // Solid color with safe fallback - always visible
        color: {
            try {
                const c = Appearance.colors.colLayer0
                if (c) return Qt.rgba(c.r, c.g, c.b, 0.90)
            } catch(e) {}
            return "#1e1e2e"
        }
        border.width: 1
        border.color: {
            try {
                const c = Appearance.colors.colLayer0Border
                if (c) return Qt.rgba(c.r, c.g, c.b, 0.5)
            } catch(e) {}
            return "#45475a"
        }
    }

    // Drop shadow
    DropShadow {
        anchors.fill: capsuleBg
        source: capsuleBg
        radius: 16
        samples: 33
        color: Qt.rgba(0, 0, 0, 0.35)
        transparentBorder: true
    }

    // ── Content row ───────────────────────────────────────────────
    RowLayout {
        id: capsuleRow
        anchors {
            verticalCenter: parent.verticalCenter
            left:           parent.left
            right:          parent.right
            leftMargin:     root.paddingH
            rightMargin:    root.paddingH
        }
        height: root.capsuleHeight - root.paddingV * 2
        spacing: 8

        // ─ 1. WORKSPACES ─────────────────────────────────────────
        Workspaces {
            id: wsWidget
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: GlobalStates.overviewOpen = !GlobalStates.overviewOpen
            }
        }

        BarDivider {}

        // ─ 2. ACTIVE WINDOW ──────────────────────────────────────
        ActiveWindow {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: screen ? screen.width >= 900 : true
        }

        // ─ 3. DASHBOARD BUTTON ───────────────────────────────────
        RippleButton {
            id: dashBtn
            Layout.alignment: Qt.AlignVCenter
            readonly property bool active: GlobalStates.dashboardOpen
            implicitWidth:  28
            implicitHeight: 28
            buttonRadius: Appearance.rounding.full
            colBackground:          active ? Appearance.colors.colSecondaryContainer
                                           : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
            colBackgroundHover:     Appearance.colors.colLayer1Hover
            colRipple:              Appearance.colors.colLayer1Active
            colBackgroundToggled:   Appearance.colors.colSecondaryContainer
            colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
            colRippleToggled:       Appearance.colors.colSecondaryContainerActive
            toggled: active
            onClicked: GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen

            MaterialSymbol {
                anchors.centerIn: parent
                text: "space_dashboard"
                iconSize: Appearance.font.pixelSize.larger
                color: dashBtn.active
                    ? Appearance.m3colors.m3onSecondaryContainer
                    : Appearance.colors.colOnLayer0
            }
        }

        BarDivider {}

        // ─ 4. CLOCK ──────────────────────────────────────────────
        MouseArea {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth:  clockWidget.implicitWidth
            implicitHeight: clockWidget.implicitHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen
            ClockWidget {
                id: clockWidget
                showDate: screen ? screen.width >= 1100 : false
            }
        }

        BarDivider {}

        // ─ 5. SYSTEM ICONS ───────────────────────────────────────
        RippleButton {
            id: sysIconsBtn
            Layout.alignment: Qt.AlignVCenter
            readonly property bool active: GlobalStates.sidebarRightOpen
            implicitWidth:  iconsRow.implicitWidth + 10 * 2
            implicitHeight: iconsRow.implicitHeight + 5 * 2
            buttonRadius: Appearance.rounding.full
            colBackground:          active ? Appearance.colors.colSecondaryContainer
                                           : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
            colBackgroundHover:     Appearance.colors.colLayer1Hover
            colRipple:              Appearance.colors.colLayer1Active
            colBackgroundToggled:   Appearance.colors.colSecondaryContainer
            colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
            colRippleToggled:       Appearance.colors.colSecondaryContainerActive
            toggled: active
            onClicked: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen

            property color iconColor: active
                ? Appearance.m3colors.m3onSecondaryContainer
                : Appearance.colors.colOnLayer0

            RowLayout {
                id: iconsRow
                anchors.centerIn: parent
                spacing: 12

                Revealer {
                    reveal: Audio.source?.audio?.muted ?? false
                    Layout.fillHeight: true
                    MaterialSymbol { text: "mic_off"; iconSize: Appearance.font.pixelSize.larger; color: sysIconsBtn.iconColor }
                }
                Revealer {
                    reveal: Audio.sink?.audio?.muted ?? false
                    Layout.fillHeight: true
                    MaterialSymbol { text: "volume_off"; iconSize: Appearance.font.pixelSize.larger; color: sysIconsBtn.iconColor }
                }
                HyprlandXkbIndicator {
                    Layout.alignment: Qt.AlignVCenter
                    color: sysIconsBtn.iconColor
                }
                Revealer {
                    reveal: Notifications.silent || Notifications.unread > 0
                    Layout.fillHeight: true
                    NotificationUnreadCount {}
                }
                MaterialSymbol {
                    text: Network.materialSymbol
                    iconSize: Appearance.font.pixelSize.larger
                    color: sysIconsBtn.iconColor
                }
                Revealer {
                    reveal: Battery.available
                    Layout.fillHeight: true
                    BatteryIndicator { Layout.alignment: Qt.AlignVCenter }
                }
            }
        }

        // SysTray
        SysTray {
            visible: screen ? screen.width >= 1000 : true
            Layout.fillHeight: true
            invertSide: false
        }
    }

    // ── Thin divider ─────────────────────────────────────────────
    component BarDivider: Rectangle {
        Layout.topMargin:    8
        Layout.bottomMargin: 8
        Layout.fillHeight:   true
        implicitWidth: 1
        color: Appearance.colors.colOutlineVariant
        opacity: 0.45
    }
}
