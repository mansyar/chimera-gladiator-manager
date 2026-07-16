# Track Specification: UI Framework & Screen Manager (TRACK-009)

## Overview

Implement the foundational UI architecture for Chimera Gladiator Manager: a `ScreenManager` that loads and transitions between 9 game screens, a persistent `TopBar` displaying Gold/Infamy, a Godot `Theme` resource applying Kenney Future font and NinePatchRect styles, 4 reusable UI widgets, and UI sound feedback. This track establishes the UI skeleton that subsequent tracks (TRACK-010 through TRACK-014) will populate with functional screen implementations.

**Type:** Feature  
**Dependencies:** TRACK-001 (project scaffolding, autoloads), TRACK-004 (EventBus signals, GameState)  
**Estimated Effort:** 2-3 Days  

### Context Anchors
- **GDD Reference:** Section 5 (UI/UX — 9 screens, Lab Hub as hub, Arena modal flow), Section 3.3 (UI Pack — buttons, panels, font, sounds), Section 3.4 (RPG Expansion — HP bars, panels, cursors), Section 3.6 (Color Palette — strain-to-color mapping)
- **TDD Reference:** Section 10 (UI Architecture — ScreenManager, Screen Flow, Screen Registration, ChimeraSprite Composition), Section 11 (Asset Pipeline — UI Pack, Font Registration, UI Sound Effects)
- **ROADMAP Reference:** TRACK-009 (lines 341-377)

## Design Decisions

1. **Primary Theme Color: Grey** — Neutral dark-science lab aesthetic. Strain colors (Green, Red, Blue, Yellow) used as accents for rarity badges and strain indicators. Matches the Undead=Grey strain mapping.
2. **Widget Data Binding: @export injection** — All 4 widgets expose typed `@export` variables. Parent screens assign data. Enables isolated unit testing with mock data.
3. **Screen Transitions: Instant + audio** — Matches TDD Section 10 exactly (`queue_free()` old, `add_child()` new). UI sounds (switch/tap) provide transition feedback. No animation system.
4. **Stub Screen Content: Label + back button** — Each stub (except Lab Hub) shows the screen name and a 'Back to Lab Hub' button. Enables manual navigation testing of the full screen flow immediately.

## Functional Requirements

### FR-1: Main Scene Structure
- **FR-1.1:** `main.tscn` contains a root `Main` (Control) node with two children: `ScreenManager` (Control) and `TopBar` (Control).
- **FR-1.2:** `ScreenManager` fills the screen below the `TopBar` area (TopBar anchored to top, ScreenManager fills remaining space).
- **FR-1.3:** `main.tscn` is set as the project's main scene.

### FR-2: ScreenManager
- **FR-2.1:** `ScreenManager` (in `scripts/ui/screen_manager.gd`) preloads all 9 screen PackedScenes in `_ready()` via a `screens` Dictionary, matching TDD Section 10 Screen Registration exactly:
  - `lab_hub`, `assembly`, `black_market`, `arena_pre_match`, `arena_combat`, `roster`, `clinic`, `tournament`, `hall_of_fame`
- **FR-2.2:** `change_screen(screen_name: String)` method: frees the current screen via `queue_free()`, instantiates the new PackedScene, adds it as a child, sets `current_screen`, and emits `EventBus.screen_change_requested`.
- **FR-2.3:** Lab Hub is the default/initial screen on startup.
- **FR-2.4:** `current_screen` property tracks the active screen instance.

### FR-3: Screen Flow
- **FR-3.1:** All non-Arena screens return to Lab Hub when their 'Back to Lab Hub' button is pressed (calls `ScreenManager.change_screen("lab_hub")`).
- **FR-3.2:** Arena flow: Pre-Match → Combat → Lab Hub (modal flow returning to hub after match). Stub implementations call `change_screen` directly.
- **FR-3.3:** Lab Hub stub has no back button (it is the root hub).

### FR-4: Theme Resource
- **FR-4.1:** A Godot `Theme` resource (`.tres` file in `resources/` or `scenes/ui/`) applies:
  - **Font:** Kenney Future Regular as the default font for all Control types (Label, Button, etc.)
  - **Button styles:** NinePatchRect-based StyleBoxTexture using Grey UI Pack button sprites (normal, hover, pressed states)
  - **Panel styles:** NinePatchRect-based StyleBoxTexture using Grey UI Pack panel sprites
  - **Color palette:** Per GDD Section 3.6, strain accent colors available for widgets (Undead=Grey, Robotic=Grey, Draconic=Red, Beast=Green, Elemental=Blue, Aberrant=Yellow)
- **FR-4.2:** Theme is assigned as the default project theme in `project.godot` (`gui/theme/custom`).

### FR-5: TopBar
- **FR-5.1:** `TopBar` (in `scripts/ui/top_bar.gd`) is a persistent Control anchored to the top of the screen.
- **FR-5.2:** Displays Gold and Infamy values as Labels.
- **FR-5.3:** Connects to `EventBus.gold_changed(amount: int)` and updates the Gold label on signal.
- **FR-5.4:** Connects to `EventBus.infamy_changed(amount: int)` and updates the Infamy label on signal.
- **FR-5.5:** On `_ready()`, reads initial values from `GameState.gold` and `GameState.infamy`.

### FR-6: Reusable Widgets
Four reusable widget scenes in `scenes/ui/widgets/`, each using `@export` data injection:

- **FR-6.1: `part_slot.tscn`** — Displays a single part's sprite and basic info.
  - `@export var part_data: PartData` — when set, displays the part's sprite (via `PartDatabase.get_sprite_path()`) and slot label.
  - Shows part sprite (TextureRect), slot type label (HEAD/TORSO/ARMS/LEGS).

- **FR-6.2: `stat_display.tscn`** — Displays a labeled stat value.
  - `@export var stat_name: String` and `@export var stat_value: float` — renders as "StatName: Value".

- **FR-6.3: `chimera_card.tscn`** — Displays a chimera summary (nickname + key stats).
  - `@export var chimera: ChimeraData` — when set, displays nickname, HP/Attack/Defense/Speed values, and instability label.
  - Instability label mapping: 0=Pure, 1=Stable Hybrid, 2=Volatile Hybrid, 3=Chaotic (per GDD Section 2.2).

- **FR-6.4: `formation_grid.tscn`** — Visual 3×3 grid for formation display.
  - `@export var grid_data: Array` — array of placement data (stub: renders 9 cells in 3×3 layout, highlights occupied cells).

### FR-7: UI Sounds
- **FR-7.1:** Load 6 UI sound OGG files from `assets/kenney-ui-pack/Sounds/` (click ×2, switch ×2, tap ×2) as `AudioStream` resources.
- **FR-7.2:** Play 'switch' sound on screen transitions (in `change_screen()`).
- **FR-7.3:** Play 'click' sound on button presses (via a shared helper or Theme default).
- **FR-7.4:** Play 'tap' sound on widget interactions (stub — wired but minimal interaction points in stubs).

### FR-8: 9 Screen Stubs
- **FR-8.1:** Create 9 minimal screen scenes in `scenes/ui/screens/` (one per screen name in FR-2.1).
- **FR-8.2:** Each stub (except `lab_hub`) contains:
  - A centered Label showing the screen name (e.g., "Chimera Assembly")
  - A 'Back to Lab Hub' Button that calls `ScreenManager.change_screen("lab_hub")`
- **FR-8.3:** `lab_hub.tscn` stub contains:
  - A centered Label "Lab Hub"
  - 8 navigation buttons (one per other screen) that call `change_screen` for each target screen.
- **FR-8.4:** Each stub has a corresponding script in `scripts/ui/screens/` (e.g., `lab_hub.gd`, `assembly.gd`, etc.) with minimal `_ready()` logic.

## Non-Functional Requirements

- **NFR-1:** All `.gd` files pass `gd-tools lint` with zero errors.
- **NFR-2:** All `.gd` files pass `gd-tools format --check` with zero formatting issues.
- **NFR-3:** Test coverage ≥ 80% for all source files with testable logic (ScreenManager, TopBar, widget scripts). Scene files (`.tscn`), Theme resources (`.tres`), and stub scripts with no logic are exempt per workflow rules.
- **NFR-4:** All UI elements use the Kenney Future font via the Theme resource (no hardcoded fonts per Control).
- **NFR-5:** NinePatchRect used for all scalable UI elements (buttons, panels) to preserve pixel-art edges on resize.
- **NFR-6:** Pixel art settings maintained: Nearest filter, snap 2D transforms, lossless compression (per TRACK-001 config).
- **NFR-7:** Stretch mode `canvas_items` with aspect `keep` preserves UI layout on window resize.

## Acceptance Criteria

- **AC-1:** `main.tscn` loads with ScreenManager + TopBar visible. Lab Hub is the default screen.
- **AC-2:** `ScreenManager.change_screen()` loads the correct PackedScene for all 9 screen names.
- **AC-3:** `change_screen()` frees the previous screen (no orphaned nodes accumulate).
- **AC-4:** TopBar Gold label updates when `EventBus.gold_changed` fires.
- **AC-5:** TopBar Infamy label updates when `EventBus.infamy_changed` fires.
- **AC-6:** TopBar reads initial Gold (200) and Infamy (0) from GameState on startup.
- **AC-7:** `part_slot` widget displays the correct sprite when `part_data` is set.
- **AC-8:** `chimera_card` widget displays nickname and stats when `chimera` is set.
- **AC-9:** `chimera_card` displays correct instability label (Pure/Stable/Volatile/Chaotic) based on strain count.
- **AC-10:** All 8 Lab Hub navigation buttons transition to their respective screens.
- **AC-11:** All 8 non-hub stub 'Back to Lab Hub' buttons return to Lab Hub.
- **AC-12:** Theme applies Kenney Future font and Grey NinePatchRect styles consistently across all screens.
- **AC-13:** UI sounds play on screen transitions (switch) and button presses (click).
- **AC-14:** `gd-tools test --coverage --min 80` exits 0.
- **AC-15:** `gd-tools lint` exits 0.
- **AC-16:** `gd-tools format --check` exits 0.

## Out of Scope

- Individual screen functional implementations (stubs only — TRACK-010 through TRACK-014)
- Drag-and-drop interaction (TRACK-011, TRACK-013)
- Combat HUD (TRACK-014)
- VFX system (TRACK-014)
- ChimeraSprite live composition in Assembly (TRACK-011 — widget exists but live re-composition deferred)
- Market purchasing logic, clinic repair logic, tournament bracket logic (TRACK-012, TRACK-015)
- Pre-match formation interaction (TRACK-013 — `formation_grid` widget exists but click-to-place deferred)
- Specific balancing values, prices, or stat numbers
