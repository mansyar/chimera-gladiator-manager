# Track: Core Project Scaffolding (TRACK-001)

## Overview

Establish the Godot 4.5+ project foundation: project configuration, full directory tree, autoload stubs, Kenney asset import settings, and the `gd-tools` CLI toolchain. All subsequent tracks depend on this scaffolding.

## Context Anchors

- **GDD Reference:** `docs/GDD.md` Section 1 (Executive Summary), Section 3 (Kenney Asset Mapping Index)
- **TDD Reference:** `docs/TDD.md` Section 1 (Project Configuration), Section 2 (Directory Structure), Section 11 (Asset Pipeline)
- **ROADMAP:** `docs/ROADMAP.md` TRACK-001

## Track Tech Stack

- Godot 4.5+ (Compatibility renderer, OpenGL)
- GDScript
- gd-tools CLI (init, doctor, lint, format, test)
- Kenney asset packs (5 packs already in `assets/`)

## Scope Boundaries

### In Scope

1. **Project Configuration (`project.godot`):**
   - Renderer: Compatibility (OpenGL)
   - Display: Windowed, resizable. Default 1280x720, minimum 960x540
   - Pixel art settings: Nearest filter, snap 2D transforms, lossless compression, mipmaps off
   - Stretch mode: `canvas_items` with aspect `keep`
   - Input map: `ui_accept` (Enter/Space), `ui_cancel` (Escape), `ui_select` (LMB), `navigate_up/down/left/right` (WASD/arrows), `pause` (P only)
   - Kenney Future font registered as default project font

2. **Directory Tree (matching TDD Section 2 exactly):**
   - `scenes/` with subdirs: `combat/`, `ui/screens/`, `ui/widgets/`, `lab/`
   - `scripts/` with subdirs: `autoload/`, `data/`, `combat/`, `ai/states/`, `systems/`, `ui/screens/`
   - `resources/` with subdirs: `parts/head/`, `parts/torso/`, `parts/arms/`, `parts/legs/`, `abilities/head/`, `abilities/torso/`, `abilities/arms/`, `abilities/legs/`, `abilities/combos/`, `behaviors/`, `starters/`
   - `tests/` with subdirs: `data/`, `combat/`, `ai/`, `systems/`, `ui/`

3. **Autoload Stubs (4 scripts, correct load order):**
   - `EventBus` (`scripts/autoload/event_bus.gd`) — prints ready confirmation
   - `GameState` (`scripts/autoload/game_state.gd`) — prints ready confirmation
   - `SaveManager` (`scripts/autoload/save_manager.gd`) — prints ready confirmation
   - `CombatManager` (`scripts/autoload/combat_manager.gd`) — prints ready confirmation
   - Load order: EventBus -> GameState -> SaveManager -> CombatManager

4. **Asset Import Settings:**
   - All 5 Kenney packs: Nearest filter, lossless compression, mipmaps off
   - Applied via `.import` files or project-wide texture defaults

5. **TileSet Resource:**
   - Created from Roguelike RPG pack spritesheet (16x16 tiles, 1px margin)

6. **Root Scene:**
   - `scenes/main.tscn` skeleton (empty root node)

7. **gd-tools Toolchain:**
   - `gd-tools init` executed (installs GUT, deploys coverage addon, generates `gd-tools.toml`, `.gutconfig.json`, `gdlintrc`, `gdformatrc`)
   - `gd-tools doctor` passes all 9 checks

### Out of Scope

- Any gameplay logic (autoload stubs print ready confirmation only)
- Any `.tres` data files (content created in TRACK-003)
- Any scene files beyond `main.tscn` skeleton
- Any UI screen implementations
- Any combat, AI, or system logic

## Verification & Definition of Done (DoD)

### Manual Checkpoint
- Project opens in Godot 4.5+ with zero errors
- Directory structure matches TDD Section 2
- Autoloads print confirmation in order on boot (EventBus -> GameState -> SaveManager -> CombatManager)
- Font renders as Kenney Future
- Pixel art textures display with Nearest filtering
- Stretch mode preserves aspect ratio on window resize

### Automated Tests
- `gd-tools doctor` exits 0 (all 9 checks pass)
- `gd-tools lint` exits 0
- `gd-tools format --check` exits 0

### Conductor Review
- Project boots clean
- Directory tree verified against TDD
- Autoload order confirmed
- gd-tools environment healthy

## Technical Notes

- **TDD Scope:** This track is primarily configuration and scaffolding. Autoload stubs contain no testable logic (print statements only). Per workflow.md, config files and stubs without logic are exempt from TDD. No unit tests required for this track.
- **Asset packs** are already present in `assets/` (read-only). Only import settings are configured.
- **Monster Builder Pack** has no separate head body part — body sprite includes head/face. HEAD slot uses `detail` sprites layered on top.
- **Strain-to-color mapping** (fixed): Undead=dark, Robotic=white, Draconic=red, Beast=green, Elemental=blue, Aberrant=yellow.
