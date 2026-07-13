# Track: scaffolding_20260714 — Implementation Plan

## Track Description

Core Project Scaffolding (TRACK-001) — Godot project setup, directory structure, autoload stubs, asset import settings, gd-tools toolchain initialization.

## Context

- **Spec:** [./spec.md](./spec.md)
- **ROADMAP:** `docs/ROADMAP.md` TRACK-001
- **TDD Reference:** Section 1 (Project Configuration), Section 2 (Directory Structure)
- **GDD Reference:** Section 1 (Executive Summary), Section 3 (Kenney Asset Mapping)

---

## Phase 1: Project Setup

- [x] Task: Initialize Godot project and configure `project.godot` (ad8f844)
    - [x] Create `project.godot` with Compatibility renderer, GDScript
    - [x] Configure display settings (1280x720 default, 960x540 minimum, windowed resizable)
    - [x] Configure pixel art settings (Nearest filter, snap 2D transforms, lossless compression, mipmaps off)
    - [x] Configure stretch mode (`canvas_items`, aspect `keep`)
    - [x] Register Kenney Future font as default project font
    - [x] Configure input map (`ui_accept`, `ui_cancel`, `ui_select`, `navigate_up/down/left/right`, `pause`)
- [x] Task: Create full directory tree per TDD Section 2 (4ef752c)
    - [x] Create `scenes/` with subdirs: `combat/`, `ui/screens/`, `ui/widgets/`, `lab/`
    - [x] Create `scripts/` with subdirs: `autoload/`, `data/`, `combat/`, `ai/states/`, `systems/`, `ui/screens/`
    - [x] Create `resources/` with subdirs: `parts/head/`, `parts/torso/`, `parts/arms/`, `parts/legs/`, `abilities/head/`, `abilities/torso/`, `abilities/arms/`, `abilities/legs/`, `abilities/combos/`, `behaviors/`, `starters/`
    - [x] Create `tests/` with subdirs: `data/`, `combat/`, `ai/`, `systems/`, `ui/`
    - [x] Create root scene `scenes/main.tscn` skeleton (empty root node)
- [x] Task: Conductor - User Manual Verification 'Phase 1: Project Setup' (Protocol in workflow.md)

> **Phase 1 Checkpoint:** e74e311 — Verified (automated: lint/format/headless boot passed; manual: user confirmed project opens correctly in Godot editor)

---

## Phase 2: Assets & Toolchain

- [x] Task: Apply asset import settings to all 5 Kenney packs (9f22270)
    - [x] Verify all 5 packs present in `assets/` (monster-builder, roguelike-rpg, ui-pack, ui-pack-rpg-expansion, particle-pack)
    - [x] Apply Nearest filter, lossless compression, mipmaps off to all PNG textures
- [x] Task: Create TileSet resource from Roguelike RPG pack (ada0152)
    - [x] Create TileSet from spritesheet (16x16 tiles, 1px margin)
    - [x] Save TileSet resource to `resources/`
- [x] Task: Initialize gd-tools toolchain (a048fcf)
    - [x] Run `gd-tools init` (installs GUT, coverage addon, generates `gd-tools.toml`, `.gutconfig.json`, `gdlintrc`, `gdformatrc`)
    - [x] Run `gd-tools doctor` and verify all 9 checks pass (exit 0)
- [x] Task: Conductor - User Manual Verification 'Phase 2: Assets & Toolchain' (Protocol in workflow.md)

> **Phase 2 Checkpoint:** 5eb624b — Verified (automated: lint/format/doctor 9/9 passed; manual: user confirmed TileSet loads, GUT plugin visible, asset import settings correct)

---

## Phase 3: Autoloads

- [x] Task: Create autoload stub scripts in correct load order (5a4944a)
    - [x] Create `scripts/autoload/event_bus.gd` (stub: prints "EventBus ready")
    - [x] Create `scripts/autoload/game_state.gd` (stub: prints "GameState ready")
    - [x] Create `scripts/autoload/save_manager.gd` (stub: prints "SaveManager ready")
    - [x] Create `scripts/autoload/combat_manager.gd` (stub: prints "CombatManager ready")
    - [x] Register all 4 autoloads in `project.godot` with correct load order: EventBus -> GameState -> SaveManager -> CombatManager
- [x] Task: Verify project boots without errors
    - [x] Run `gd-tools lint` and verify exit 0
    - [x] Run `gd-tools format --check` and verify exit 0
    - [x] Boot project in Godot and confirm autoload print order (EventBus -> GameState -> SaveManager -> CombatManager)
- [x] Task: Conductor - User Manual Verification 'Phase 3: Autoloads' (Protocol in workflow.md)
