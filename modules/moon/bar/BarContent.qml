pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
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
// Moonsshell BarContent – floating notch-style capsule
//
// Inspired by Ambxst's floating notch design.
// Powered by End-4 services (Appearance, Audio, Battery, Network…).
//
// Layout: [Workspaces] | [ActiveWindow] [DashBtn] | [Clock] | [SysIcons]
// ─────────────────────────────────────────────────────────────────
Item {
    id: root

    // ── Geometry constants ────────────────────────────────────────
    readonly property int capsuleHeight:  44
    readonly property int capsuleRadius:  22    // full pill
    readonly property int paddingH:       14
    readonly property int paddingV:        6
    readonly property int sectionSpacing:  8
    readonly property int minWidth:       680

    required property var screen

    implicitWidth:  Math.min(
        Math.max(capsuleRow.implicitWidth + paddingH * 2, minWidth),
        screen ? screen.width - 80 : 1200)
    implicitHeight: capsuleHeight

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.animation.elementMoveFast.duration
            easing.type: Easing.OutQuart
        }
    }

    // ── Blur + background capsule ─────────────────────────────────
    Rectangle {
        id: capsuleBg
        anchors.fill: parent
        radius: root.capsuleRadius
        color: Config.options.bar.showBackground
            ? Qt.rgba(
                Appearance.colors.colLayer0.r,
                Appearance.colors.colLayer0.g,
                Appearance.colors.colLayer0.b,
                0.82)
            : "transparent"
        border.width: 1
        border.color: Qt.rgba(
            Appearance.colors.colLayer0Border.r,
            Appearance.colors.colLayer0Border.g,
            Appearance.colors.colLayer0Border.b,
            0.5)
    }

    // Backdrop blur via layer effect
    layer.enabled: Config.options.bar.showBackground
    layer.effect: MultiEffect {
        blurEnabled: true
        blurMax: 32
        blur: 0.65
    }

    // Drop shadow
    StyledDropShadow {
        anchors.fill: parent
        source: capsuleBg
        visible: Config.options.bar.showBackground
        spread: 0
        radius: 16
        samples: 30
        color: Qt.rgba(0, 0, 0, 0.30)
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
        spacing: root.sectionSpacing

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

        // separator
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

            readonly property bool active: GlobalStates.sidebarLeftOpen

            implicitWidth:  28
            implicitHeight: 28
            buttonRadius: Appearance.rounding.full
            colBackground:           active
                ? Appearance.colors.colSecondaryContainer
                : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
            colBackgroundHover:      Appearance.colors.colLayer1Hover
            colRipple:               Appearance.colors.colLayer1Active
            colBackgroundToggled:    Appearance.colors.colSecondaryContainer
            colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
            colRippleToggled:        Appearance.colors.colSecondaryContainerActive
            toggled: active

            onClicked: GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen

            MaterialSymbol {
                anchors.centerIn: parent
                text: "space_dashboard"
                iconSize: Appearance.font.pixelSize.larger
                color: dashBtn.active
                    ? Appearance.m3colors.m3onSecondaryContainer
                    : Appearance.colors.colOnLayer0
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }
        }

        // separator
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

        // separator
        BarDivider {}

        // ─ 5. SYSTEM ICONS ───────────────────────────────────────
        RippleButton {
            id: sysIconsBtn
            Layout.alignment: Qt.AlignVCenter

            implicitWidth:  iconsRow.implicitWidth + 10 * 2
            implicitHeight: iconsRow.implicitHeight + 5 * 2
            buttonRadius: Appearance.rounding.full

            colBackground:           GlobalStates.sidebarRightOpen
                ? Appearance.colors.colSecondaryContainer
                : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
            colBackgroundHover:      Appearance.colors.colLayer1Hover
            colRipple:               Appearance.colors.colLayer1Active
            colBackgroundToggled:    Appearance.colors.colSecondaryContainer
            colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
            colRippleToggled:        Appearance.colors.colSecondaryContainerActive
            toggled: GlobalStates.sidebarRightOpen

            onClicked: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen

            property color iconColor: toggled
                ? Appearance.m3colors.m3onSecondaryContainer
                : Appearance.colors.colOnLayer0
            Behavior on iconColor {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }

            RowLayout {
                id: iconsRow
                anchors.centerIn: parent
                spacing: 12

                // Muted mic indicator
                Revealer {
                    reveal: Audio.source?.audio?.muted ?? false
                    Layout.fillHeight: true
                    MaterialSymbol {
                        text: "mic_off"
                        iconSize: Appearance.font.pixelSize.larger
                        color: sysIconsBtn.iconColor
                    }
                }

                // Muted speaker indicator
                Revealer {
                    reveal: Audio.sink?.audio?.muted ?? false
                    Layout.fillHeight: true
                    MaterialSymbol {
                        text: "volume_off"
                        iconSize: Appearance.font.pixelSize.larger
                        color: sysIconsBtn.iconColor
                    }
                }

                // Keyboard layout (Hyprland XKB)
                HyprlandXkbIndicator {
                    Layout.alignment: Qt.AlignVCenter
                    color: sysIconsBtn.iconColor
                }

                // Notifications badge
                Revealer {
                    reveal: Notifications.silent || Notifications.unread > 0
                    Layout.fillHeight: true
                    NotificationUnreadCount {}
                }

                // Network icon
                MaterialSymbol {
                    text: Network.materialSymbol
                    iconSize: Appearance.font.pixelSize.larger
                    color: sysIconsBtn.iconColor
                }

                // Bluetooth icon
                Revealer {
                    reveal: BluetoothStatus.available
                    Layout.fillHeight: true
                    MaterialSymbol {
                        text: BluetoothStatus.connected    ? "bluetooth_connected"  :
                              BluetoothStatus.enabled      ? "bluetooth"             :
                                                             "bluetooth_disabled"
                        iconSize: Appearance.font.pixelSize.larger
                        color: sysIconsBtn.iconColor
                    }
                }

                // Battery
                Revealer {
                    reveal: Battery.available
                    Layout.fillHeight: true
                    BatteryIndicator {
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }

        // ─ 6. SYS TRAY ───────────────────────────────────────────
        SysTray {
            visible: screen ? screen.width >= 1000 : true
            Layout.fillHeight: true
            invertSide: false
        }
    }

    // ── Thin divider helper ───────────────────────────────────────
    component BarDivider: Rectangle {
        Layout.topMargin:    8
        Layout.bottomMargin: 8
        Layout.fillHeight:   true
        implicitWidth: 1
        color: Appearance.colors.colOutlineVariant
        opacity: 0.45
    }
}
