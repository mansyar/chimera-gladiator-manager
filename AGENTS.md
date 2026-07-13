# AGENTS.md

Pre-implementation Godot 4.5+ game project. No `project.godot` or source code exists yet — only design docs and assets. Implementation follows `docs/ROADMAP.md` track by track.

## Source of Truth

| Document | Role |
|----------|------|
| `docs/GDD.md` | Game design (pure design — no code, no node structures) |
| `docs/TDD.md` | Technical architecture, data models, system design |
| `docs/ROADMAP.md` | 16 implementation tracks across 6 milestones with DoD gates |

Every track references specific GDD/TDD sections for traceability. Don't deviate from these docs without explicit discussion. GDD.md must stay implementation-free.

## Toolchain

**gd-tools CLI** (`pip install gd-tools-cli`) wraps GUT, gdlint, gdformat, and coverage. Requires Godot 4.5+.

```
gd-tools init                    # one-time setup (TRACK-001): installs GUT, coverage addon, generates configs
gd-tools doctor                  # verify environment (9 checks, must exit 0)
gd-tools lint                    # gdlint on all .gd files
gd-tools format --check          # verify gdformat compliance (does NOT modify files)
gd-tools test --coverage --min 80  # run GUT tests with 80% coverage gate
```

Verification order per track DoD: `lint` -> `format --check` -> `test --coverage --min 80`.

Test files live in `res://tests/`, mirroring `scripts/` structure.

## Architecture Rules (from TDD — these were hard-won gap fixes)

- **ChimeraData vs CombatState:** ChimeraData is a persistent `Resource` (campaign state). CombatState is a transient `RefCounted` created/destroyed per match (HP, cooldowns, berserk, effects). Never mix persistent and combat state in one class.
- **Part slots:** Use 4 separate `@export var head/torso/arms/legs: PartData`. Do NOT use a typed Dictionary — Godot 4 inspector can't edit it.
- **PartData abilities:** Parts reference abilities by `ability_id: String` (looked up via PartDatabase). Do NOT embed AbilityData resources in PartData — causes duplication across 36 body variants.
- **Movement:** `velocity = direction * speed` then `move_and_slide()`. Do NOT multiply by `delta` — `move_and_slide` applies it internally (double-delta bug).
- **Autoload load order:** EventBus -> GameState -> SaveManager -> CombatManager. This order matters.
- **System scripts** (`scripts/systems/economy.gd`, `market.gd`, `decay.gd`, `research.gd`) are static utility classes with pure functions — no state. GameState calls them and stores results.
- **Signals:** EventBus (autoload) for global cross-system signals. Direct signals for local parent-child communication. Don't use EventBus for local node communication.
- **Saves:** JSON at `user://saves/` (not `res://`). Parts saved by reference (shape_id + strain + rarity), not full data.

## Assets

5 Kenney packs in `assets/` (read-only — set import settings, never modify pack contents):

| Pack | Used For |
|------|----------|
| `kenney-monster-builder-pack/` | Chimera sprites (individual PNGs, not spritesheet) |
| `kenney-roguelike-rpg-pack/` | Arena environment tiles (16x16, 1px margin, needs TileSet) |
| `kenney-ui-pack/` | Lab/management UI + Kenney Future font + UI sounds |
| `kenney-ui-pack-rpg-expansion/` | Combat UI (HP bars, cursors, panels) |
| `kenney-particle-pack/` | VFX (strain-themed: fire=Draconic, magic=Elemental, etc.) |

Monster Builder Pack has no separate head body part — the body sprite includes the head/face. HEAD slot uses `detail` sprites (horns, ears, antenna) layered on top.

Strain-to-color mapping is fixed: Undead=dark, Robotic=white, Draconic=red, Beast=green, Elemental=blue, Aberrant=yellow.

Pixel art import: Nearest filter, lossless compression, mipmaps off, snap 2D transforms enabled.

## Conductor Workflow

This project follows the Conductor methodology. Implementation happens in tracks defined in `docs/ROADMAP.md`. Each track has:
- Context anchors (GDD/TDD section references)
- Scope boundaries (in/out)
- DoD: manual checkpoint + automated tests (`gd-tools` commands) + conductor review

Milestone 4 (UI, tracks 009-012) can be developed in parallel with Milestone 3 (Combat, tracks 005-008) after TRACK-004 is complete.
