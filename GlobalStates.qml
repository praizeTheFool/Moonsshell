// Moonsshell GlobalStates
// Merges End-4 states with Ambxst dashboard states in one Singleton.
// dashboardOpen controls the Ambxst dashboard panel.
// sidebarLeftOpen controls End-4's AI/translator sidebar.

import qs.modules.common
import qs.services
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root

    // ── End-4 core states (unchanged) ─────────────────────────────
    property bool barOpen: true
    property bool crosshairOpen: false
    property bool sidebarLeftOpen: false
    property bool sidebarRightOpen: false
    property bool mediaControlsOpen: false
    property bool osdBrightnessOpen: false
    property bool osdVolumeOpen: false
    property bool oskOpen: false
    property bool overlayOpen: false
    property bool overviewOpen: false
    property bool regionSelectorOpen: false
    property bool searchOpen: false
    property bool screenLocked: false
    property bool screenLockContainsCharacters: false
    property bool screenUnlockFailed: false
    property bool sessionOpen: false
    property bool superDown: false
    property bool superReleaseMightTrigger: true
    property bool wallpaperSelectorOpen: false
    property bool workspaceShowNumbers: false

    // ── Ambxst-compatible read-only aliases ────────────────────────
    // Ambxst Dashboard open state (independent from sidebarLeft/AI panel)
    property bool dashboardOpen: false
    // Ambxst reads lockscreenVisible
    readonly property bool lockscreenVisible: screenLocked

    // ── Ambxst dashboard tab state ─────────────────────────────────
    property int    dashboardCurrentTab: 0
    property int    widgetsTabCurrentIndex: 0
    property string launcherSearchText: ""

    function clearLauncherState() {
        launcherSearchText = ""
        widgetsTabCurrentIndex = 0
    }

    // ── Tool visibility flags (Ambxst) ─────────────────────────────
    property bool screenshotToolVisible: false
    property bool screenRecordToolVisible: false

    // ── Side-effects ───────────────────────────────────────────────
    onSidebarRightOpenChanged: {
        if (sidebarRightOpen) {
            Notifications.timeoutAll()
            Notifications.markAllRead()
        }
    }

    // ── Global shortcuts ───────────────────────────────────────────
    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"
        onPressed:  root.superDown = true
        onReleased: root.superDown = false
    }
}
