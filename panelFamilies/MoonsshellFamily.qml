pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs
import qs.modules.common
import qs.modules.bar
import qs.modules.moon.background
import qs.modules.moon.cheatsheet
import qs.modules.moon.dock
import qs.modules.moon.lock
import qs.modules.moon.mediaControls
import qs.modules.moon.notificationPopup
import qs.modules.moon.onScreenDisplay
import qs.modules.moon.onScreenKeyboard
import qs.modules.moon.overview
import qs.modules.moon.polkit
import qs.modules.moon.regionSelector
import qs.modules.moon.screenCorners
import qs.modules.moon.sessionScreen
import qs.modules.moon.sidebarLeft
import qs.modules.moon.sidebarRight
import qs.modules.moon.overlay
import qs.modules.moon.verticalBar
import qs.modules.moon.wallpaperSelector
import qs.modules.widgets

// ──────────────────────────────────────────────────────────────────
// MoonsshellFamily
// Loads all Moonsshell panels. PanelLoader is defined inline here
// since MoonsshellFamily lives in panelFamilies/ and cannot import
// its sibling PanelLoader.qml via a directory import.
// ──────────────────────────────────────────────────────────────────
Scope {

    // Inline PanelLoader (mirrors panelFamilies/PanelLoader.qml)
    component PanelLoader: LazyLoader {
        property bool extraCondition: true
        active: Config.ready && extraCondition
    }

    // ── Moonsshell floating notch bar ─────────────────────────────
    PanelLoader {
        extraCondition: !Config.options.bar.vertical
        component: Bar {}
    }

    // ── Ambxst Dashboard ──────────────────────────────────────────
    PanelLoader { component: CrescentDashboard {} }

    // ── End-4 panels (all unchanged) ──────────────────────────────
    PanelLoader { component: Background {} }
    PanelLoader { component: Cheatsheet {} }
    PanelLoader { extraCondition: Config.options.dock.enable; component: Dock {} }
    PanelLoader { component: Lock {} }
    PanelLoader { component: MediaControls {} }
    PanelLoader { component: NotificationPopup {} }
    PanelLoader { component: OnScreenDisplay {} }
    PanelLoader { component: OnScreenKeyboard {} }
    PanelLoader { component: Overlay {} }
    PanelLoader { component: Overview {} }
    PanelLoader { component: Polkit {} }
    PanelLoader { component: RegionSelector {} }
    PanelLoader { component: ScreenCorners {} }
    PanelLoader { component: SessionScreen {} }
    PanelLoader { component: SidebarLeft {} }
    PanelLoader { component: SidebarRight {} }
    PanelLoader { extraCondition: Config.options.bar.vertical; component: VerticalBar {} }
    PanelLoader { component: WallpaperSelector {} }
}
