# Moonsshell

A Quickshell configuration that merges the End-4 dotfiles shell with Ambxst UI components.

---

## Architecture

```
Moonsshell
├── Base system   →  End-4 (dots-hyprland / ii family)
│                    services, modules, widgets, wallpaper selector,
│                    system integrations, scripts
└── UI layer      →  Ambxst
                     floating notch-style bar, dashboard, panel animations
```

## What comes from where

| Component | Source | Notes |
|---|---|---|
| `services/` | End-4 | Audio, Battery, Network, Bluetooth, Notifications… |
| `scripts/` | End-4 | Color, wallpaper, AI, thumbnail scripts |
| `modules/common/` | End-4 | Appearance, Config, Icons, widgets library |
| `modules/ii/` | End-4 | Overview, SidebarLeft, SidebarRight, OSD, Dock, Lock, Session… |
| `modules/bar/Bar.qml` | **Moonsshell** | Floating capsule window (new) |
| `modules/bar/BarContent.qml` | **Moonsshell** | Notch-style capsule layout (new) |
| `modules/bar/*.qml` | End-4 | Workspaces, ActiveWindow, Clock, SysTray, Battery… |
| `modules/notch/` | Ambxst | Notch container, animations, StackView |
| `modules/widgets/dashboard/` | Ambxst | Dashboard UI (Widgets, Wallpapers, Metrics, AI tabs) |
| `modules/widgets/MoonsDashboard.qml` | **Moonsshell** | Dashboard popup bridge (new) |
| `modules/components/` | Ambxst | StyledRect, shaders, custom primitives |
| `modules/theme/` | Ambxst | Colors, Styling, Icons |
| `GlobalStates.qml` | **Moonsshell** | Merged End-4 + Ambxst states (new) |
| `panelFamilies/MoonsshellFamily.qml` | **Moonsshell** | Panel loader (new) |
| `shell.qml` | **Moonsshell** | Entry point (new) |

---

## Panel layout

```
┌──────────────────────────────────────────────────────────────────────┐
│                    ╭──────────────────────────────╮                  │
│                    │ ⬡⬡⬡ │ Window │ ⊞ │ 12:34 │ 🔊🔋 │             │
│                    ╰──────────────────────────────╯                  │
│                    floating capsule · blur backdrop · rounded pill   │
└──────────────────────────────────────────────────────────────────────┘
```

**Sections (left → right):**

1. **Workspaces** — Hyprland workspace pills (right-click → overview)
2. **Active Window** — focused window title (hidden on narrow screens)
3. **Dashboard button** — opens Ambxst Dashboard (⊞ icon)
4. **Clock** — time + optional date (click → right sidebar)
5. **System icons** — mic/speaker mute, keyboard layout, notifications, network, Bluetooth, battery
6. **SysTray** — system tray icons

---

## Capsule design

- **Centered** at the top of each screen
- **Floating** — gaps on all sides
- **Blurred** semi-transparent background (`MultiEffect` blur)
- **Rounded pill** (`border-radius: 22px`)
- **Drop shadow** beneath
- **Auto-hide** support (slides up, reveals on hover)
- **Smooth width animation** as content changes

---

## Dashboard

Opened by clicking the **⊞ dashboard button** in the bar, or via the `dashboardToggle` shortcut.

Uses the **Ambxst Dashboard** UI connected to **End-4 services**:

| Tab | Content |
|---|---|
| 0 – Widgets | Launcher, quick controls, notifications, weather, calendar |
| 1 – Wallpapers | Wallpaper picker with color scheme preview |
| 2 – Metrics | CPU, memory, GPU resource graphs |
| 3 – AI | Chat assistant (Gemini, OpenAI, Mistral, Ollama…) |

---

## Module paths

| Import | Directory |
|---|---|
| `qs` | `Moonsshell/` root (singletons: `GlobalStates`, `Config`, `Appearance`…) |
| `qs.services` | `services/` |
| `qs.modules.common` | `modules/common/` |
| `qs.modules.common.widgets` | `modules/common/widgets/` |
| `qs.modules.bar` | `modules/bar/` |
| `qs.modules.ii.*` | `modules/ii/*/` |
| `qs.modules.notch` | `modules/notch/` |
| `qs.modules.widgets` | `modules/widgets/` |

---

## Global shortcuts

| Shortcut name | Action |
|---|---|
| `barToggle` | Show / hide the floating bar |
| `dashboardToggle` | Open / close the Ambxst dashboard |
| `sidebarRightToggle` | Open / close right sidebar (quick settings) |
| `overviewToggle` | Open / close workspace overview |
| `sessionToggle` | Open / close session / power menu |
| `workspaceNumber` | Hold super to show workspace numbers |

Register these in your Hyprland config with:
```
bind = $mod, B, global, moonsshell:barToggle
bind = $mod, D, global, moonsshell:dashboardToggle
bind = $mod, N, global, moonsshell:sidebarRightToggle
bind = $mod, Tab, global, moonsshell:overviewToggle
```

---

## IPC

All End-4 IPC targets still work:

```sh
qs msg -I moonsshell:bar toggle
qs msg -I moonsshell:sidebarLeft toggle
qs msg -I moonsshell:sidebarRight toggle
qs msg -I moonsshell:overview toggle
qs msg -I moonsshell:session toggle
qs msg -I moonsshell:wallpaperSelector toggle
```

---

## Running

```sh
quickshell -p /home/user/dev/quickshell/Moonsshell
```

Or symlink to `~/.config/quickshell/`:

```sh
ln -sf /home/user/dev/quickshell/Moonsshell ~/.config/quickshell/Moonsshell
quickshell -p ~/.config/quickshell/Moonsshell
```

---

## Dependencies

Inherited from End-4 + Ambxst. Key runtime deps:

- `quickshell` (latest git)
- `hyprland`
- `pipewire` / `wireplumber` (audio)
- `networkmanager`
- `upower` (battery)
- `cliphist` (clipboard history)
- `matugen` (material color generation)
- Python 3 + `materialyoucolor` (color scripts)
