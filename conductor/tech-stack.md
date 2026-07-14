# Technology Stack

## Engine & Runtime

- **Game Engine:** Godot 4.5+
- **Renderer:** Compatibility (OpenGL) — 2D-only game, widest hardware support, best 2D performance
- **Language:** GDScript

## Display Configuration

- **Default Resolution:** 1280x720 (windowed, resizable)
- **Minimum Resolution:** 960x540
- **Stretch Mode:** `canvas_items` with aspect `keep` (preserves pixel ratio on resize)

## Pixel Art Settings

- **Texture Filtering:** Nearest (no smoothing)
- **Snap 2D Transforms to Pixel:** Enabled
- **Default Texture Import:** Filter off, compression lossless
- **Mipmaps:** Off

## Testing & Quality Toolchain

- **CLI Tool:** gd-tools-cli (`pip install gd-tools-cli`)
- **Test Runner:** GUT 9.5+ (Godot Unit Test)
  - Godot version mapping: 4.5 -> GUT 9.5+, 4.6 -> 9.6+, 4.7 -> 9.7+
- **Linter:** gdlint (via `gd-tools lint`)
- **Formatter:** gdformat (via `gd-tools format --check`)
- **Coverage:** Coverage addon (via `gd-tools test --coverage --min 80`)
  - *Note (2026-07-15):* Coverage enabled with `min_percent = 80` in `gd-tools.toml`. Five pure data/enum source files are excluded from coverage calculation (they contain no testable logic per workflow rules): `scripts/data/enums.gd`, `scripts/data/part_data.gd`, `scripts/data/ability_data.gd`, `scripts/data/ability_effect.gd`, `scripts/data/behavior_module_data.gd`.
- **Doctor:** `gd-tools doctor` (9 environment checks, must exit 0)
- **Test Location:** `res://tests/` mirroring `scripts/` structure

## Data & Persistence

- **Data Definitions:** Godot Resource files (.tres) — editable in inspector
- **Save Format:** JSON at `user://saves/save_default.json`
- **Save Strategy:** Parts saved by reference (shape_id + strain + rarity), reconstructed via PartDatabase on load

## Architecture

- **Singleton/Autoload Pattern:** 4 autoloads (EventBus -> GameState -> SaveManager -> CombatManager)
- **Data Models:** Godot Resource subclasses (PartData, AbilityData, ChimeraData, etc.)
- **Combat Entities:** CharacterBody2D with composite nodes (AIController, AbilityComponent, EffectComponent, VFXSpawner)
- **AI:** Custom FSM pattern (AIState base class + state scripts)
- **System Utilities:** Static classes with pure functions (economy.gd, market.gd, decay.gd, research.gd)
- **Signal System:** Two-tier (EventBus global + direct local signals)
- **UI:** Control nodes, ScreenManager, NinePatchRect, Theme system

## Assets (Read-Only)

| Pack | Folder | Purpose |
|------|--------|---------|
| Monster Builder Pack | `kenney-monster-builder-pack/` | Chimera sprites (178 body/arm/leg/detail x 6 colors + cosmetics) |
| Roguelike RPG Pack | `kenney-roguelike-rpg-pack/` | Arena tiles (1700+ 16x16 tiles, 1px margin) |
| UI Pack | `kenney-ui-pack/` | Lab/management UI + Kenney Future font + sounds |
| UI Pack RPG Expansion | `kenney-ui-pack-rpg-expansion/` | Combat UI (HP bars, cursors, panels) |
| Particle Pack | `kenney-particle-pack/` | VFX (80 particle sprites, strain-themed) |

## Dependencies

- **Python:** Required for gd-tools-cli installation
- **Godot 4.5+:** Required engine version
- **GUT 9.5+:** Test framework (installed via `gd-tools init`)
- **Kenney Asset Packs:** Pre-existing in `assets/` directory (no download needed)
