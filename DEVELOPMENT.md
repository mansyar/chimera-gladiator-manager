# Development Guide

This document contains development-focused information for contributors. For the player-facing game overview, see the [README](README.md).

## Tech Stack

- **Engine:** Godot 4.5+ (Compatibility renderer, OpenGL)
- **Language:** GDScript
- **Testing:** gd-tools CLI (`pip install gd-tools-cli`) — wraps GUT 9.5.0, gdlint, gdformat, coverage
- **Assets:** 5 Kenney asset packs (monster builder, roguelike RPG, UI, UI RPG expansion, particle)
- **Save System:** JSON at `user://saves/`
- **Architecture:** Singleton/autoload pattern, Resource-based data models (.tres)

## Source Documents

| Document | Role |
|----------|------|
| [docs/GDD.md](docs/GDD.md) | Game design (pure design — no code, no node structures) |
| [docs/TDD.md](docs/TDD.md) | Technical architecture, data models, system design |
| [docs/ROADMAP.md](docs/ROADMAP.md) | 16 implementation tracks across 6 milestones with DoD gates |

## Project Structure

```
chimera-gladiator-manager/
├── assets/                 # 5 Kenney asset packs (read-only)
├── conductor/               # Conductor methodology tracking
│   ├── product.md           # Product definition
│   ├── tech-stack.md        # Technology stack
│   ├── workflow.md          # Development workflow
│   ├── tracks.md            # Tracks registry
│   └── archive/             # Completed tracks
├── docs/                    # GDD, TDD, ROADMAP
├── resources/              # .tres data files
│   ├── abilities/           # Part abilities + strain combos
│   ├── behaviors/           # Behavior modules
│   ├── parts/               # Part templates (head/torso/arms/legs)
│   └── starters/            # Starter chimera definitions
├── scenes/                  # Godot scene files
├── scripts/
│   ├── ai/                  # AI FSM (TRACK-006)
│   ├── autoload/            # EventBus, GameState, SaveManager, CombatManager
│   ├── combat/              # Combat entities (TRACK-005+)
│   ├── data/                # Data model classes (PartData, AbilityData, etc.)
│   ├── systems/             # Static utility classes (PartDatabase, economy, market, etc.)
│   └── ui/                  # UI screens (TRACK-009+)
└── tests/                   # GUT test suites
    ├── autoload/            # Autoload singleton tests
    ├── combat/              # Combat state/effect tests
    ├── data/                # Data model tests
    ├── edge/                # Edge case tests (decay, berserk, combos, etc.)
    ├── integration/         # Cross-system integration tests
    └── systems/             # System utility tests
```

## Setup

### Prerequisites

- [Godot 4.5+](https://godotengine.org/)
- Python 3.10+ (for gd-tools CLI)

### Installation

```bash
# Install gd-tools CLI
pip install gd-tools-cli

# Verify environment (all 9 checks must pass)
gd-tools doctor
```

### Running Tests

```bash
# Lint
gd-tools lint

# Check formatting (does NOT modify files)
gd-tools format --check

# Run tests with 80% coverage gate
gd-tools test --coverage --min 80
```

Verification order per track DoD: `lint` -> `format --check` -> `test --coverage --min 80`.

Current status: 517 tests, 98.8% line coverage (589/596), 100% branch coverage (162/162).

## Development Workflow

This project follows the [Conductor methodology](conductor/workflow.md) for context-driven development. Implementation happens track-by-track per the [ROADMAP](docs/ROADMAP.md). Each track has:
- Context anchors (GDD/TDD section references)
- Scope boundaries (in/out)
- Definition of Done: manual checkpoint + automated tests + conductor review

## Current Status

| Track | Description | Status |
|-------|-------------|--------|
| TRACK-001 | Core Project Scaffolding | Complete |
| TRACK-002 | Data Models & Enums | Complete |
| TRACK-003 | Part Database & Data Definitions | Complete |
| TRACK-004 | Singleton Architecture, Signals & Save System | Complete |
| — | Test Coverage Initiative (Conductor) | Complete |
| TRACK-005 | Combat Entity & Arena Foundation | Complete |
| TRACK-006–008 | Combat Core (AI, Abilities, Match Flow) | Pending |
| TRACK-009–012 | UI & Management Screens | Pending |
| TRACK-013–014 | Arena & Match Flow | Pending |
| TRACK-015–016 | Progression & Meta Systems | Pending |

See [docs/ROADMAP.md](docs/ROADMAP.md) for the full 16-track roadmap across 6 milestones.

### What's Implemented

- **Project scaffolding** (TRACK-001): Godot 4.5+ project configured for pixel art, full directory tree, 4 autoloads registered, 5 Kenney asset packs imported, TileSet created, gd-tools initialized.
- **Data models** (TRACK-002): GameEnums, PartData, AbilityData, AbilityEffect, BehaviorModuleData, ChimeraData, CombatState, ActiveEffect, EffectComponent — all Resource/RefCounted classes with tested stat calculation, instability, and combat state logic.
- **Part database** (TRACK-003): PartDatabase static class with 74 `.tres` data files (23 part abilities, 18 strain combo abilities, 7 behavior modules, 23 part templates, 3 starter chimeras). Full rarity modifier system, sprite path construction, random part generation. 102 tests, 95.1% line coverage, 98.5% branch coverage.
- **Singleton architecture & save system** (TRACK-004): EventBus with all 13 global signals, GameState with full campaign state (gold, infamy, roster, inventory, market, research, ascension), SaveManager with JSON serialization (save-by-reference, 6 save triggers, migration stub), CombatManager stub. 4 static utility classes: economy.gd, market.gd, decay.gd, research.gd. 372 tests, 93.8% line coverage, 96.5% branch coverage.
- **Test coverage initiative** (Conductor track `test_coverage_20260715`): Expanded the test suite from 372 to 484 tests across 6 test directories (unit, integration, edge cases, autoload mocking). Coverage addon reconfigured for autoload instrumentation support. 98.8% line coverage (560/567), 100% branch coverage (156/156).
- **Combat entity & arena foundation** (TRACK-005): Arena scene (640×360px with TileMap background, boundary walls, formation grids) and ChimeraEntity scene (CharacterBody2D with 8-layer ChimeraSprite, AttackRange Area2D, collision layers, EffectComponent). Movement system (velocity = direction * speed, move_and_slide — no double-delta). Damage resolution with berserk modifiers and effect component integration. Attack cadence timer. Formation grid-to-world position mapping (3×3 per side). 517 tests, 98.8% line coverage, 100% branch coverage.
