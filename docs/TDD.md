# Chimera Gladiator Manager
## Technical Architecture Document

> **Status:** Draft v2 — 7 significant gaps + 6 minor issues resolved. Implementation in progress (TRACK-001 through TRACK-009 complete).
> Last updated: 2026-07-17

---

## Table of Contents

1. [Project Configuration](#1-project-configuration)
2. [Directory Structure](#2-directory-structure)
3. [Data Models](#3-data-models)
4. [Singleton Architecture](#4-singleton-architecture)
5. [Signal Architecture](#5-signal-architecture)
6. [Combat System](#6-combat-system)
7. [AI System](#7-ai-system)
8. [Ability System](#8-ability-system)
9. [Save System](#9-save-system)
10. [UI Architecture](#10-ui-architecture)
11. [Asset Pipeline](#11-asset-pipeline)

---

## 1. Project Configuration

- **Engine:** Godot 4.5+ (minimum for gd-tools/GUT 9.5.0 compatibility)
- **Language:** GDScript
- **Renderer:** Compatibility (OpenGL) — 2D-only game, widest hardware support, best 2D performance
- **Display:** Windowed, resizable. Default 1280×720, minimum 960×540.
- **Pixel Art Settings:**
  - Texture filtering: Nearest (no smoothing)
  - Snap 2D transforms to pixel: Enabled
  - Default texture import: filter off, compression lossless
  - Stretch mode: `canvas_items` with aspect `keep` (preserves pixel ratio on resize)

### Testing & Quality Toolchain

- **gd-tools CLI** (`pip install gd-tools-cli`): wraps GUT (test runner), gdlint, gdformat, and coverage reporting.
  - `gd-tools init` — installs GUT, deploys coverage addon, generates `gd-tools.toml`, `.gutconfig.json`, `gdlintrc`, `gdformatrc`.
  - `gd-tools test --coverage --min 80` — runs GUT tests with minimum 80% coverage gate.
  - `gd-tools lint` — runs gdlint on all .gd files.
  - `gd-tools format --check` — verifies gdformat compliance without modifying files.
  - `gd-tools doctor` — verifies environment (Godot path, GUT install, coverage addon, config files, etc.).
- **Godot version mapping:** Godot 4.5 → GUT 9.5.0, 4.6 → 9.6.0, 4.7 → 9.7.0.
- Test files live in `res://tests/` with subdirectories mirroring `scripts/` structure, plus `integration/` (cross-system flow tests) and `edge/` (boundary condition tests).
- **Coverage addon:** The `_GDTCoverage` autoload (deployed by `gd-tools init`) is registered first in `project.godot` — before the four game autoloads — so it can instrument autoloads during their `_ready()`. Coverage is configured in `gd-tools.toml` with `min_percent = 80` and excludes data/enum files with no testable logic.

### Input Map

| Action | Keys |
|--------|------|
| ui_accept | Enter, Space |
| ui_cancel | Escape |
| ui_select | Left Mouse Button |
| navigate_up | W, Up Arrow |
| navigate_down | S, Down Arrow |
| navigate_left | A, Left Arrow |
| navigate_right | D, Right Arrow |
| pause | P |

Most game interaction is mouse-driven (clicking UI elements, dragging parts to slots). Keyboard provides navigation alternatives.

---

## 2. Directory Structure

```
res://
├── project.godot
├── assets/                          # Kenney asset packs (read-only)
│   ├── kenney-monster-builder-pack/
│   ├── kenney-roguelike-rpg-pack/
│   ├── kenney-ui-pack/
│   ├── kenney-ui-pack-rpg-expansion/
│   └── kenney-particle-pack/
├── scenes/                          # PackedScene files (.tscn)
│   ├── main.tscn                    # Root scene
│   ├── combat/
│   │   ├── arena.tscn               # Combat arena scene
│   │   └── chimera_entity.tscn      # Combat chimera node
│   ├── ui/
│   │   ├── screens/                 # One .tscn per screen
│   │   │   ├── lab_hub.tscn
│   │   │   ├── assembly.tscn
│   │   │   ├── black_market.tscn
│   │   │   ├── arena_pre_match.tscn
│   │   │   ├── arena_combat.tscn
│   │   │   ├── roster.tscn
│   │   │   ├── clinic.tscn
│   │   │   ├── tournament.tscn
│   │   │   └── hall_of_fame.tscn
│   │   └── widgets/                 # Reusable UI components
│   │       ├── part_slot.tscn
│   │       ├── stat_display.tscn
│   │       ├── chimera_card.tscn
│   │       └── formation_grid.tscn
│   └── lab/
│       └── chimera_sprite.tscn      # Composited chimera visual node
├── scripts/
│   ├── autoload/                    # Singleton scripts
│   │   ├── game_state.gd
│   │   ├── combat_manager.gd
│   │   ├── event_bus.gd
│   │   └── save_manager.gd
│   ├── data/                        # Resource class definitions
│   │   ├── part_data.gd
│   │   ├── chimera_data.gd
│   │   ├── ability_data.gd
│   │   ├── ability_effect.gd
│   │   ├── behavior_module_data.gd
│   │   └── enums.gd                 # Shared enums (Strain, Rarity, etc.)
│   ├── combat/
│   │   ├── arena.gd                 # Arena scene controller
│   │   ├── chimera_entity.gd        # Combat entity (CharacterBody2D)
│   │   ├── combat_state.gd          # Transient combat state (HP, cooldowns, effects)
│   │   ├── active_effect.gd         # Single temporary status effect instance
│   │   ├── effect_component.gd       # Tracks/ticks/cleans up ActiveEffects on ChimeraEntity
│   │   └── combat_context.gd        # Shared combat state (entity registry, timer)
│   ├── ai/
│   │   ├── ai_controller.gd         # FSM controller
│   │   ├── ai_state.gd              # Base state class (virtual)
│   │   └── states/                  # Individual state scripts
│   │       ├── idle_state.gd
│   │       ├── acquire_target_state.gd
│   │       ├── move_to_target_state.gd
│   │       ├── in_range_state.gd
│   │       ├── attack_state.gd
│   │       ├── use_ability_state.gd
│   │       ├── berserk_state.gd
│   │       └── dead_state.gd
│   ├── systems/
│   │   ├── ability_system.gd        # Ability execution engine
│   │   ├── part_database.gd         # Part template lookup & generation
│   │   ├── economy.gd               # Gold/Infamy logic
│   │   ├── market.gd                # Black market inventory & refresh
│   │   ├── decay.gd                 # Genetic decay logic
│   │   ├── research.gd              # Research progress
│   │   └── enemy_generator.gd       # Procedural enemy chimera creation
│   └── ui/
│       ├── screen_manager.gd
│       └── screens/                 # Screen controllers
│           ├── lab_hub.gd
│           ├── assembly.gd
│           └── ...
├── resources/                       # .tres data files (definitions)
│   ├── parts/                       # PartData .tres files (templates)
│   │   ├── head/
│   │   ├── torso/
│   │   ├── arms/
│   │   └── legs/
│   ├── abilities/                   # AbilityData .tres files
│   │   ├── head/                    # 7 abilities
│   │   ├── torso/                   # 6 abilities
│   │   ├── arms/                    # 5 abilities
│   │   ├── legs/                    # 5 abilities
│   │   └── combos/                  # 6 strains × 3 tiers = 18 combo abilities
│   ├── behaviors/                   # 7 BehaviorModuleData .tres files
│   └── starters/                    # Starter chimera definitions
├── tests/                            # GUT test files
│   ├── autoload/                     # Autoload singleton tests
│   ├── combat/
│   ├── data/
│   ├── ai/                           # (TRACK-006)
│   ├── systems/
│   ├── ui/                           # UI tests (TRACK-009)
│   ├── integration/                  # Cross-system flow tests
│   └── edge/                         # Boundary condition tests
├── saves/                           # Save files (runtime — actually in user://saves/, not res://)
└── docs/
    ├── GDD.md
    ├── TDD.md
    └── ROADMAP.md
```

---

## 3. Data Models

All game data definitions use Godot's `Resource` system. Definitions are stored as `.tres` files and editable in the inspector.

### Shared Enums (`scripts/data/enums.gd`)

```gdscript
class_name GameEnums

enum Strain { UNDEAD, ROBOTIC, DRACONIC, BEAST, ELEMENTAL, ABERRANT, NEUTRAL }
enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }
enum PartSlot { HEAD, TORSO, ARMS, LEGS }
enum Instability { PURE, STABLE, VOLATILE, CHAOTIC }
enum AbilityType { ACTIVE, PASSIVE }
enum AbilityCategory { OFFENSE, MOBILITY, UTILITY, DEFENSE }
enum TargetingMode { NEAREST, WEAKEST_ACCESSIBLE, HIGHEST_THREAT, OPTIMAL_DISRUPT, ATTACKING_ALLIES, LOWEST_HP }
enum Positioning { FRONT, MID, BACK }
```

### PartData (`scripts/data/part_data.gd`)

Represents a single equippable part. Each part instance in the game (inventory, market, equipped) is a PartData resource.

```gdscript
class_name PartData extends Resource

@export var slot: GameEnums.PartSlot
@export var shape_id: String          # e.g., "body_a", "horn_large", "arm_c"
@export var strain: GameEnums.Strain
@export var rarity: GameEnums.Rarity
@export var sprite_path: String        # Path to PNG in assets/

# Stats contributed by this part (already modified by rarity)
@export var hp_bonus: float = 0.0
@export var attack_bonus: float = 0.0
@export var defense_bonus: float = 0.0
@export var speed_bonus: float = 0.0

# Ability granted by this part (looked up by shape_id via PartDatabase)
@export var ability_id: String  # e.g., "body_a_ability", "horn_large_ability"

# HEAD parts only — which behavior module this head enables
@export var behavior_module: BehaviorModuleData  # null for non-HEAD parts

# Attack range (ARMS only — melee vs ranged)
@export var attack_range: float = 32.0  # Default melee range (pixels)
```

### AbilityData (`scripts/data/ability_data.gd`)

Defines a single ability. Composable — each ability is a collection of effects.

```gdscript
class_name AbilityData extends Resource

@export var id: String                # Unique identifier (e.g., "body_a_ability")
@export var name: String
@export var description: String
@export var type: GameEnums.AbilityType        # ACTIVE or PASSIVE
@export var category: GameEnums.AbilityCategory  # OFFENSE, MOBILITY, UTILITY, DEFENSE
@export var cooldown: float = 0.0               # Seconds (active abilities only)
@export var targeting: String                   # SELF, TARGET, AOE_ENEMIES, AOE_ALLIES, ALL_ENEMIES
@export var range: float = 0.0                  # Effective range (for active abilities)
@export var effects: Array[AbilityEffect]       # Composable effects
```

### AbilityEffect (`scripts/data/ability_effect.gd`)

A single composable effect within an ability. Abilities combine multiple effects.

```gdscript
class_name AbilityEffect extends Resource

enum EffectType {
    DAMAGE,           # Deal damage to target
    HEAL,             # Restore HP
    BUFF_STAT,        # Temporarily increase a stat
    DEBUFF_STAT,      # Temporarily decrease a stat
    REPOSITION,       # Move target to a position
    SHIELD,           # Add temporary HP buffer
    CLEANSE,          # Remove debuffs
    REVIVE,           # Briefly reanimate on death (Undead combo)
    ENRAGE,           # Self-buff on low HP (Draconic combo)
    STAT_MUTATION,    # Random stat change (Aberrant combo)
    RANDOM_EFFECT     # Random effect from a list (Aberrant combo)
}

@export var effect_type: EffectType
@export var params: Dictionary   # e.g., {"stat": "attack", "amount": 0.5, "duration": 3.0}
```

### BehaviorModuleData (`scripts/data/behavior_module_data.gd`)

Configuration for an AI behavior module. 7 instances total (one per HEAD detail type).

```gdscript
class_name BehaviorModuleData extends Resource

@export var module_name: String              # "Charger", "Caster", etc.
@export var detail_type: String              # "horn_large", "antenna_small", etc.
@export var targeting: GameEnums.TargetingMode
@export var ability_priority: Array[GameEnums.AbilityCategory]
@export var positioning: GameEnums.Positioning
```

### ChimeraData (`scripts/data/chimera_data.gd`)

Represents a chimera instance in the **persistent campaign state** (roster, inventory). Combat-only state is handled by `CombatState` (see below), created at match start and destroyed at match end.

```gdscript
class_name ChimeraData extends Resource

@export var nickname: String

# Equipped parts — 4 separate exports (Godot 4 doesn't support typed Dictionary exports)
@export var head: PartData
@export var torso: PartData
@export var arms: PartData
@export var legs: PartData

# Derived stats (recalculated when parts change)
var max_hp: float
var attack: float
var defense: float
var speed: float
var attack_range: float          # From ARMS shape (melee vs ranged)
var instability: int             # 0-3, derived from strain count
var strain_count: int
var dominant_strain: GameEnums.Strain  # Most common strain (for combo)

# Abilities (derived from parts — looked up via PartDatabase by ability_id)
var part_abilities: Array[AbilityData]   # 4 abilities (one per part)
var combo_ability: AbilityData           # 5th ability if 2+ same-strain parts
var combo_tier: int                      # 0 (none), 1 (basic), 2 (enhanced), 3 (ultimate)

# Persistent state
var current_hp: float
var decay_level: int = 0
var match_wins: int = 0

func get_parts() -> Array[PartData]:
    return [head, torso, arms, legs]

func get_part(slot: GameEnums.PartSlot) -> PartData:
    match slot:
        GameEnums.PartSlot.HEAD: return head
        GameEnums.PartSlot.TORSO: return torso
        GameEnums.PartSlot.ARMS: return arms
        GameEnums.PartSlot.LEGS: return legs
    return null

func recalculate_stats() -> void:
    # Sum base stats from all 4 parts, apply purebred bonuses, apply research bonuses
    pass

func calculate_instability() -> void:
    # Count distinct strains across 4 parts
    pass

func get_combo_ability() -> AbilityData:
    # Determine if 2+ parts share a strain, return appropriate combo
    pass
```

### CombatState (`scripts/combat/combat_state.gd`)

Transient combat state for a chimera during a match. Created when combat starts, destroyed when combat ends. Held by `ChimeraEntity`, not persisted.

```gdscript
class_name CombatState extends RefCounted

var chimera_data: ChimeraData    # Reference to persistent data

# Runtime combat values
var current_hp: float
var max_hp: float                # Snapshot at combat start (includes passive modifiers)
var attack: float                # Snapshot (includes passive modifiers)
var defense: float               # Snapshot
var speed: float                 # Snapshot
var attack_range: float          # Snapshot from ChimeraData (melee vs ranged)
var is_berserk: bool = false
var berserk_timer: float = 0.0
var berserk_check_timer: float = 0.0
var berserk_modifiers: Dictionary = {}
var ability_cooldowns: Dictionary = {}  # {ability_id: remaining_seconds}
var active_effects: Array[ActiveEffect] = []  # Temporary buffs/debuffs/shields
var is_dead: bool = false
var team: int                    # 0 = player, 1 = enemy

func initialize(data: ChimeraData, team_id: int) -> void:
    chimera_data = data
    team = team_id
    max_hp = data.max_hp
    current_hp = data.max_hp
    attack = data.attack
    defense = data.defense
    speed = data.speed
    attack_range = data.attack_range
    # Passive modifiers applied after initialize by AbilityComponent

func take_damage(amount: float) -> void:
    current_hp = max(0.0, current_hp - amount)
    if current_hp <= 0.0:
        is_dead = true

func heal(amount: float) -> void:
    current_hp = min(max_hp, current_hp + amount)
```

### ActiveEffect (`scripts/combat/active_effect.gd`)

Represents a single temporary status effect (buff, debuff, shield) applied during combat.

```gdscript
class_name ActiveEffect extends RefCounted

var effect_type: AbilityEffect.EffectType
var stat_name: String           # "attack", "defense", "speed", "hp" (for buffs/debuffs)
var amount: float              # Modifier amount (positive for buff, negative for debuff)
var duration: float            # Remaining seconds
var source_id: String          # Ability ID that created this effect

func tick(delta: float) -> bool:  # Returns true if expired
    duration -= delta
    return duration <= 0.0
```

### Stat Calculation Flow

1. Player assembles parts in Chimera Assembly screen
2. `ChimeraData.recalculate_stats()` is called on any part change
3. Stats are summed from all 4 equipped `PartData` resources (head, torso, arms, legs)
4. Purebred bonus applied if Instability = 0 (stat multiplier)
5. Research bonuses applied (from GameState)
6. Derived properties calculated (instability, combo ability, attack range)
7. At combat start, `CombatState.initialize()` snapshots stats from ChimeraData; passive modifiers are then applied by `AbilityComponent.apply_passives()`

### Part Database (`scripts/systems/part_database.gd`)

A static lookup service for part templates, abilities, behavior modules, strain combos, and starter chimeras. Loads all `.tres` resource files lazily on first access via `_ensure_loaded()` (idempotent — guarded by a `_loaded` flag). Maps shape_id → base stats, sprite path, and ability_id. Abilities are stored as separate `.tres` files in `resources/abilities/` — each PartData references its ability by `ability_id` string, and PartDatabase resolves the lookup. This avoids duplicating AbilityData across the 36 body parts (6 shapes × 6 colors) that share the same 6 body abilities.

Used by:
- Black Market generation (create parts from shape + strain + rarity)
- Save system (reconstruct parts from saved references)
- Starter chimera initialization
- Ability lookup (resolve `ability_id` → `AbilityData` resource)
- Strain combo lookup (resolve strain + tier → combo `AbilityData`)
- Behavior module lookup (resolve detail_type → `BehaviorModuleData`)

```gdscript
class_name PartDatabase

# Constants
const SPRITE_PATH_PREFIX := "res://assets/kenney-monster-builder-pack/PNG/Default/"
const STRAIN_TO_COLOR := { ... }          # GameEnums.Strain → Kenney color string (NEUTRAL="dark")
const STRAIN_NAMES := { ... }            # GameEnums.Strain → strain name string (excludes NEUTRAL)
const RARITY_STAT_MULTIPLIERS := { ... }  # GameEnums.Rarity → float (COMMON=1.0, UNCOMMON=1.25, RARE=1.5, LEGENDARY=2.0)

# Registered at startup from .tres files (lazy-loaded via _ensure_loaded())
static var part_templates: Dictionary = {}        # {shape_id: PartData (base template)}
static var ability_templates: Dictionary = {}      # {ability_id: AbilityData}
static var behavior_templates: Dictionary = {}    # {detail_type: BehaviorModuleData}
static var combo_templates: Dictionary = {}       # {"{strain}_{tier}": AbilityData}
static var starter_chimeras: Array[ChimeraData] = []
static var _loaded: bool = false

# Lookups
static func get_part(shape_id: String, strain: GameEnums.Strain, rarity: GameEnums.Rarity) -> PartData:
    # Duplicates template, applies rarity stat multipliers, constructs sprite_path
static func get_ability(ability_id: String) -> AbilityData:
static func get_ability_with_rarity(ability_id: String, rarity: GameEnums.Rarity) -> AbilityData:
    # Rare: -15% cooldown; Legendary: -25% cooldown + +20% effect amount
static func get_base_stats(shape_id: String) -> Dictionary:
    # Returns {hp_bonus, attack_bonus, defense_bonus, speed_bonus}
static func generate_random_part(slot: GameEnums.PartSlot, rarity_weights: Dictionary) -> PartData:
    # Weighted random rarity, random shape for slot, random playable strain (0-5)
static func get_strain_combo(strain: GameEnums.Strain, tier: int) -> AbilityData:
    # Returns null for NEUTRAL strain
static func get_behavior_module(detail_type: String) -> BehaviorModuleData:
static func get_starter_chimeras() -> Array[ChimeraData]:
static func get_sprite_path(shape_id: String, strain: GameEnums.Strain) -> String:
    # Handles two Kenney naming patterns: detail_{color}_{variant}.png vs {category}_{color}{Variant}.png
```

---

## 4. Singleton Architecture

Four autoloads registered in `project.godot` (in this load order — EventBus first so other autoloads can connect signals during their `_ready()`):

1. **EventBus** (signal hub — no dependencies)
2. **GameState** (persistent campaign state — connects to EventBus)
3. **SaveManager** (serialization — reads/writes GameState)
4. **CombatManager** (transient combat — idle between matches)

### GameState (`scripts/autoload/game_state.gd`)

Holds all persistent campaign data. The single source of truth for the campaign.

**System scripts** in `scripts/systems/` (`economy.gd`, `market.gd`, `decay.gd`, `research.gd`) are **static utility classes** — they contain pure logic functions with no state. GameState calls these utilities and stores the results. For example, `GameState.buy_part()` calls `Market.purchase_part()` (which validates cost and modifies stock), then GameState updates its `gold` and `inventory` fields. This separation keeps GameState lean while logic lives in testable static functions.

```
GameState
├── gold: int
├── infamy: int
├── roster: Array[ChimeraData]        # Always exactly 3
├── inventory: Array[PartData]        # Spare parts
├── market_stock: Dictionary          # {base: Array, rotating: Array}
├── research_progress: Dictionary     # {branch: {node: level}}
├── hall_of_fame: Array[ChimeraData]  # Retired champions
├── current_tournament: Dictionary    # Active tournament state (if any)
├── match_history: Array              # Recent results (for rubber-band difficulty)
├── losing_streak: int
└── methods:
    ├── add_gold(amount), spend_gold(amount) -> bool
    ├── add_infamy(amount)
    ├── get_chimera(index) -> ChimeraData
    ├── replace_chimera(index, new_chimera)
    ├── add_part(part), remove_part(part)
    ├── refresh_market()
    ├── buy_part(part) -> bool
    ├── can_ascend(chimera) -> bool
    ├── ascend_chimera(chimera) -> int  # returns research points, fills slot with free common-rarity starter
    ├── get_research_level(branch, node) -> int
    ├── spend_research_point(branch, node) -> bool  # validates via research.gd, deducts RP, emits research_unlocked
    └── record_match_result(won: bool, match_type: String, rewards: Dictionary)  # Updates losing_streak, appends to match_history, adds gold/infamy, refreshes market, triggers save
```

### CombatManager (`scripts/autoload/combat_manager.gd`)

Transient — only active during a match. As an autoload, it remains loaded but idle between matches (`match_active = false`). `_process()` returns early when not in combat. This avoids scene-switching overhead while keeping combat state accessible to all combat entities. All combat state is cleared in `end_match()`. The `end_match()` method is guarded with `if not match_active: return` to prevent double-calling (e.g., when a win condition and timer expiry occur in the same frame).

```
CombatManager
├── player_formation: Array               # Grid positions for player side
├── enemy_formation: Array                # Grid positions for enemy side
├── combat_entities: Array[ChimeraEntity] # All active entities (both sides)
├── combat_context: CombatContext          # Shared entity registry (null when idle)
├── timer: float                           # 60-second countdown
├── match_active: bool
├── match_result: Dictionary               # {winner, won, surviving_hp, duration, gold_earned, infamy_earned}
├── match_type: String                     # "regular" or "tournament"
├── tournament_tier: int                   # 1-4 for tournaments, 0 for regular
└── methods:
    ├── start_match(player_roster: Array[ChimeraData], enemy_roster: Array[ChimeraData],
    │               formations: Array, match_type: String, tournament_tier: int) -> void
    │     # Creates ChimeraEntity per chimera, initializes CombatState, places on grid,
    │     # connects died signal, begins 60s timer, emits match_started
    ├── _process(delta)  # Returns early if !match_active; otherwise tick timer, check win condition
    ├── check_win_condition()  # Checks alive counts; ends match when one side is wiped
    ├── _on_entity_died(entity)  # Unregisters from context, checks win condition
    ├── _on_timer_expired()  # Determines winner by total HP%; player wins ties
    ├── end_match(result)  # Guarded against double-call. Calculates rewards via Economy,
    │                       # calls GameState.record_match_result, emits match_ended,
    │                       # frees all entities, clears all state
    ├── get_enemies_of(team: int) -> Array[ChimeraEntity]  # Delegates to CombatContext
    ├── _spawn_entity(chimera_data, team_id, grid_pos, container)  # Instantiates entity, initializes combat state
    ├── _find_or_create_entities_container() -> Node2D  # Finds 'arena_entities' group or creates temp
    ├── _count_alive(team: int) -> int
    ├── _calc_team_hp_percent(team: int) -> float
    └── _build_result(winner: int, surviving_hp: float) -> Dictionary
```

### EventBus (`scripts/autoload/event_bus.gd`)

Global signal hub. Decouples systems — UI listens to economy changes without knowing about GameState internals.

```
EventBus (extends Node)
├── Signals:
│   ├── gold_changed(amount: int)
│   ├── infamy_changed(amount: int)
│   ├── part_purchased(part: PartData)
│   ├── chimera_modified(chimera: ChimeraData)
│   ├── chimera_decayed(chimera: ChimeraData, stat_lost: String)
│   ├── match_started(player_roster, enemy_roster)
│   ├── match_ended(result: Dictionary)
│   ├── market_refreshed()
│   ├── research_unlocked(branch, node, level)
│   ├── chimera_ascended(chimera: ChimeraData)
│   ├── screen_change_requested(screen: String)
│   ├── berserk_triggered(chimera: ChimeraData)
│   └── combat_log(message: String)
```

### SaveManager (`scripts/autoload/save_manager.gd`)

Handles serialization. Saves GameState to a JSON file in `user://saves/`.

```
SaveManager (extends Node)
├── SAVE_DIR := "user://saves"
├── SAVE_PATH := "user://saves/save_default.json"
├── CURRENT_VERSION := 1
└── methods:
    ├── save_game() -> void          # Serialize GameState to JSON
    ├── load_game() -> bool          # Deserialize JSON to GameState, calls _migrate() if version differs
    ├── has_save() -> bool
    ├── delete_save() -> void
    ├── _exit_tree() -> void         # Save on game exit
    └── _migrate(from_version, data) -> Dictionary  # Stub for version 1
```

---

## 5. Signal Architecture

Two-tier signal system:

### Global Signals (EventBus)

Used for cross-system communication. Systems emit events; UI and other systems subscribe.

```gdscript
# Economy system emits:
EventBus.gold_changed.emit(new_amount)

# UI subscribes:
func _ready():
    EventBus.gold_changed.connect(_on_gold_changed)
```

**Rule:** Any state change that affects multiple systems or UI screens goes through EventBus. This prevents tight coupling between GameState, CombatManager, and UI.

### Local Signals (Direct)

Used within scenes and components. Parent-child communication, UI button clicks, combat entity events.

```gdscript
# ChimeraEntity emits locally:
signal died(entity)
signal hp_changed(current, maximum)
signal berserk_started()
signal berserk_ended()

# Arena scene listens directly:
entity.died.connect(_on_entity_died)
```

**Rule:** Local signals stay local. If an event needs to reach another system (e.g., combat entity died → GameState needs to check for decay), the Arena controller relays it to EventBus.

---

## 6. Combat System

### Arena Scene (`scenes/combat/arena.tscn`)

```
Arena (Node2D)
├── TileMap / Sprite2D           # Arena background (Roguelike pack tiles)
├── FormationGridPlayer (Node2D) # Visual grid (pre-match only)
├── FormationGridEnemy (Node2D)
├── Entities (Node2D)            # Container for spawned ChimeraEntities
├── CombatHUD (CanvasLayer)      # HP bars, timer, status effects
└── ArenaController (script)     # Manages combat flow
```

### ChimeraEntity (`scenes/combat/chimera_entity.tscn`)

Each chimera in combat is a `CharacterBody2D` with composited sprite and attached components.

```
ChimeraEntity (CharacterBody2D)
├── ChimeraSprite (Node2D)       # Composited Sprite2D stack (body, arms, legs, head, cosmetics)
├── AttackRange (Area2D)          # Detects targets in range
│   └── CollisionShape2D          # Circle matching ARMS attack_range
├── BodyCollision (CollisionShape2D)  # Physical collision
├── HealthBar (Sprite2D)          # Floating HP bar (RPG UI pack)
├── StatusEffects (Node2D)        # Active effect icons
├── AIController (Node)           # FSM brain (see Section 7)
├── AbilityComponent (Node)       # Manages cooldowns and execution (see Section 8)
├── EffectComponent (Node)        # Tracks/ticks/cleans up ActiveEffects (see below)
├── VFXSpawner (Node2D)           # Particle effects on hit/ability
├── CombatState (RefCounted)      # Transient combat data (HP, cooldowns, effects) — see Section 3
└── ChimeraEntity.gd (script)     # Orchestrates components, handles damage/healing
```

### EffectComponent (`scripts/combat/effect_component.gd`)

Manages temporary status effects (buffs, debuffs, shields) on a ChimeraEntity. Effects are added by the AbilitySystem when abilities execute, and ticked down each frame.

```gdscript
class_name EffectComponent extends Node

var active_effects: Array[ActiveEffect] = []
var stat_modifiers: Dictionary = {}  # {stat_name: total_modifier} — recalculated on add/remove

func add_effect(effect: ActiveEffect) -> void:
    active_effects.append(effect)
    recalculate_modifiers()

func tick(delta: float) -> void:
    var expired = []
    for effect in active_effects:
        if effect.tick(delta):
            expired.append(effect)
    for effect in expired:
        active_effects.erase(effect)
    if not expired.is_empty():
        recalculate_modifiers()

func recalculate_modifiers() -> void:
    # Sum all active buff/debuff amounts per stat
    stat_modifiers.clear()
    for effect in active_effects:
        if effect.effect_type in [AbilityEffect.EffectType.BUFF_STAT, AbilityEffect.EffectType.DEBUFF_STAT]:
            stat_modifiers[effect.stat_name] = stat_modifiers.get(effect.stat_name, 0.0) + effect.amount

func get_modified_stat(stat_name: String, base_value: float) -> float:
    return base_value + stat_modifiers.get(stat_name, 0.0)

func cleanse() -> void:
    # Remove all debuffs (called by CLEANSE effect type)
    active_effects = active_effects.filter(func(e): return e.effect_type != AbilityEffect.EffectType.DEBUFF_STAT)
    recalculate_modifiers()

func absorb_damage(amount: float) -> float:
    # Absorb damage through SHIELD effects, removing depleted shields.
    # Returns remaining damage not absorbed. Called by attack_state.gd
    # and AbilitySystem before CombatState.take_damage().
    var remaining_damage = amount
    for effect in active_effects:
        if effect.effect_type == AbilityEffect.EffectType.SHIELD and remaining_damage > 0.0:
            if effect.amount > remaining_damage:
                effect.amount -= remaining_damage
                remaining_damage = 0.0
            else:
                remaining_damage -= effect.amount
                # Shield depleted — will be removed
    active_effects = active_effects.filter(func(e): return e.effect_type != AbilityEffect.EffectType.SHIELD or e.amount > 0.0)
    return remaining_damage
```

### Movement

Simple direct movement — no NavigationAgent2D needed for initial implementation. Arena is an open field.

```gdscript
func move_toward_target(target_position: Vector2) -> void:
    var direction = (target_position - global_position).normalized()
    velocity = direction * speed  # move_and_slide() applies delta internally
    move_and_slide()
```

If pathfinding around obstacles becomes necessary, upgrade to `NavigationAgent2D` with a `NavigationRegion2D` defining the walkable area.

### Collision Layers

| Layer | Name | Purpose |
|-------|------|---------|
| 1 | Player Chimeras | Player-side combat entities |
| 2 | Enemy Chimeras | Enemy-side combat entities |
| 3 | Arena Boundaries | Walls/edges |
| 4 | Attack Hitboxes | Area2D attack ranges |

ChimeraEntity uses layers 1 or 2 (depending on team). AttackRange Area2D uses layer 4 and masks the opposing team's layer.

### Damage Resolution

```gdscript
func calculate_damage(attacker: ChimeraEntity, defender: ChimeraEntity) -> float:
    var base_damage = attacker.combat_state.attack  # Snapshot includes passive modifiers
    if attacker.combat_state.is_berserk:
        base_damage *= 1.5  # +50% attack while berserk
    var defense = defender.combat_state.defense
    if defender.combat_state.is_berserk:
        defense *= 0.7  # -30% defense while berserk
    # Apply active effect modifiers (null-check for entities without EffectComponent)
    if attacker.effect_component:
        base_damage = attacker.effect_component.get_modified_stat("attack", base_damage)
    if defender.effect_component:
        defense = defender.effect_component.get_modified_stat("defense", defense)
    return max(1.0, base_damage - defense)
```

**SHIELD Damage Absorption:** Before `CombatState.take_damage()` is called, incoming damage is first routed through `EffectComponent.absorb_damage()`. This method consumes SHIELD-type ActiveEffects, reducing the damage by the shield's remaining amount. Any damage exceeding the total shield value passes through to `take_damage()`. This applies to both basic attacks (in `attack_state.gd`) and ability DAMAGE effects (in `AbilitySystem`). Ability DAMAGE uses `params["amount"] * source.combat_state.attack` and intentionally bypasses defense calculation and berserk modifiers per spec FR-6.

### Attack Cadence

Auto-attacks fire on a timer governed by Speed:
- Base interval = `1.0 / (speed * ATTACK_RATE_CONSTANT)` seconds
- Higher Speed → shorter interval → more attacks per second
- Active abilities have their own cooldowns (defined per AbilityData)

### Win Condition

CombatManager checks after every entity death and every frame:
1. If one side has zero surviving entities → other side wins
2. If 60-second timer expires → side with higher total HP% wins

```gdscript
func check_win_condition() -> void:
    var player_alive = get_alive_count(Team.PLAYER)
    var enemy_alive = get_alive_count(Team.ENEMY)
    
    if player_alive == 0:
        end_match({winner: Team.ENEMY, ...})
    elif enemy_alive == 0:
        end_match({winner: Team.PLAYER, ...})
```

### Enemy Generation (`scripts/systems/enemy_generator.gd`)

`class_name EnemyGenerator` — a static utility class with pure functions (no state). Enemy chimeras are generated procedurally for Regular Matches and Tournaments:

- **Difficulty tiers:** Four tiers (`weak`, `normal`, `tough`, `strong`), each with a weighted rarity distribution (`DIFFICULTY_WEIGHTS` constant). Higher tiers shift rarity toward Uncommon/Rare/Legendary.
- **Regular Matches:** Default tier is `normal`. Rubber-band: if `losing_streak >= 3`, tier drops to `weak` (GDD Section 4.6).
- **Tournaments:** Tier 1-2 → `tough`, Tier 3-4 → `strong`.
- **Generation:** `generate_enemy_roster(player_roster, match_type, losing_streak, tournament_tier)` produces 3 enemy chimeras. Each enemy gets 4 parts via `PartDatabase.generate_random_part()` with the tier's rarity weights, then `calculate_instability()` and `recalculate_stats()` are called.

---

## 7. AI System

### FSM Architecture

Each ChimeraEntity has an `AIController` node that runs a finite state machine. The FSM is **configurable** — the same state machine runs for all chimeras, with the behavior module providing parameters.

```
AIController (Node)
├── current_state: AIState
├── behavior_module: BehaviorModuleData  # Configuration
├── combat_state: CombatState           # Transient combat data (HP, cooldowns, effects)
├── combat_context: CombatContext        # Shared entity registry (enemies/allies lookup)
├── target: ChimeraEntity               # Current target
├── states: Dictionary                  # {state_name: AIState instance}
├── entity: ChimeraEntity               # @onready ref to parent entity
└── methods:
    ├── change_state(new_state: String)
    ├── _process(delta)  # Delegates to current_state.update(), then check_berserk()
    ├── acquire_target() -> ChimeraEntity
    ├── get_move_position(target: ChimeraEntity) -> Vector2
    ├── get_next_ready_ability() -> AbilityData
    ├── check_berserk(delta: float)
    └── enter_berserk()
```

### State Flow

```
IDLE → ACQUIRE_TARGET → MOVE_TO_TARGET → IN_RANGE → ATTACK
                                     ↘                ↗
                                       USE_ABILITY ←───
                                       
BERSERK (override — can trigger from any state)
DEAD (terminal)
```

| State | Behavior | Transitions |
|-------|----------|-------------|
| **IDLE** | Brief pause before action | → ACQUIRE_TARGET |
| **ACQUIRE_TARGET** | Uses behavior_module.targeting to find target. If no target found → check win condition | → MOVE_TO_TARGET (if target exists) → IDLE (if no target) |
| **MOVE_TO_TARGET** | Moves toward/away from target based on positioning tendency (see Positioning Behavior below) | → IN_RANGE (when in attack range) |
| **IN_RANGE** | Checks ability cooldowns by priority | → USE_ABILITY (if ability ready) → ATTACK (if no ability ready) |
| **ATTACK** | Executes auto-attack, resets attack timer | → ACQUIRE_TARGET (if target dead/gone) → IN_RANGE (if target still alive) |
| **USE_ABILITY** | Executes highest-priority off-cooldown ability | → ATTACK or → ACQUIRE_TARGET |
| **BERSERK** | Ignores module, targets nearest entity, +50% atk, -30% def | → ACQUIRE_TARGET (after 5s — re-evaluates, doesn't restore previous state) |
| **DEAD** | Stops all processing, plays death animation | terminal |

### Positioning Behavior

The behavior module's `positioning` field (FRONT/MID/BACK) and the ARMS part's `attack_range` (melee vs ranged) together determine how `MOVE_TO_TARGET` behaves:

```gdscript
func get_move_position(target: ChimeraEntity) -> Vector2:
    var distance = global_position.distance_to(target.global_position)
    var is_ranged = combat_state.attack_range > MELEE_THRESHOLD  # e.g., 48px
    
    match behavior_module.positioning:
        GameEnums.Positioning.FRONT:
            if is_ranged:
                # Kite: maintain distance, move away if too close
                if distance < combat_state.attack_range * 0.8:
                    return target.global_position + (global_position - target.global_position).normalized() * combat_state.attack_range
            # Melee: close distance
            return target.global_position
        
        GameEnums.Positioning.MID:
            if is_ranged:
                # Hold at attack range — don't chase, don't flee
                var desired = target.global_position + (global_position - target.global_position).normalized() * combat_state.attack_range * 0.9
                return desired
            # Melee mid: approach but don't overcommit
            return target.global_position
        
        GameEnums.Positioning.BACK:
            if is_ranged:
                # Stay far, flee if approached
                if distance < combat_state.attack_range * 0.7:
                    return global_position + (global_position - target.global_position).normalized() * 100.0
                return global_position  # Hold position, attack from range
            # Melee back: only approach when no front-line allies remain
            if has_front_line_allies():
                return global_position  # Hold back
            return target.global_position
```

**Positioning tendencies by module:**
- **Guardian** (FRONT, typically melee): Holds position near starting cell, only moves to intercept enemies approaching allies. Tanks, doesn't chase.
- **Sentinel** (FRONT, melee): Moves to intercept enemies currently attacking allies, then holds.
- **Charger** (FRONT, melee): Rushes toward nearest enemy, no kiting.
- **Skirmisher** (MID, melee or ranged): Hit-and-run — closes for attack, retreats between attacks.
- **Controller** (MID, typically ranged): Holds at range, casts debuffs.
- **Caster** (BACK, ranged): Maintains maximum distance, flees if approached.
- **Stalker** (BACK, melee): Moves around the flank to reach lowest-HP target, ignores front-line tanks.

### Target Selection

The behavior module's `targeting` field determines which function is called during `ACQUIRE_TARGET`:

```gdscript
func acquire_target() -> ChimeraEntity:
    var enemies = combat_context.get_enemies_of(team)
    match behavior_module.targeting:
        GameEnums.TargetingMode.NEAREST:
            return find_nearest(enemies)
        GameEnums.TargetingMode.WEAKEST_ACCESSIBLE:
            return find_lowest_hp_in_range(enemies, combat_state.attack_range)
        GameEnums.TargetingMode.HIGHEST_THREAT:
            return find_highest_attack(enemies)
        GameEnums.TargetingMode.OPTIMAL_DISRUPT:
            return find_highest_attack_targeting_ally(enemies)
        GameEnums.TargetingMode.ATTACKING_ALLIES:
            return find_enemy_attacking_ally(enemies)
        GameEnums.TargetingMode.LOWEST_HP:
            return find_lowest_hp(enemies)  # Stalker moves to reach them
    return null  # No target found
```

### Ability Priority

During `IN_RANGE` and `USE_ABILITY` states, the AI checks abilities in the order specified by `behavior_module.ability_priority`:

```gdscript
func get_next_ready_ability() -> AbilityData:
    for category in behavior_module.ability_priority:
        for ability in combat_state.chimera_data.part_abilities + [combat_state.chimera_data.combo_ability]:
            if ability and ability.category == category and is_off_cooldown(ability):
                return ability
    return null  # No ability ready
```

### Berserk State

Checked every 5 seconds (or on immediate triggers). When triggered, the FSM overrides to BERSERK state:

```gdscript
func check_berserk(delta: float) -> void:
    if combat_state.chimera_data.instability == 0:  # Purebreds immune
        return
    if combat_state.is_berserk:  # Don't roll while already berserk
        return
    
    combat_state.berserk_check_timer += delta
    if combat_state.berserk_check_timer >= 5.0:
        combat_state.berserk_check_timer = 0.0
        var chance = get_berserk_chance()
        combat_state.berserk_modifiers.clear()  # Reset after roll
        if randf() < chance:
            enter_berserk()

# Immediate trigger — called when an ally dies
func on_ally_death() -> void:
    if combat_state.chimera_data.instability == 0:  # Purebreds immune
        return
    if combat_state.is_berserk:  # Don't roll while already berserk
        return
    var chance = get_berserk_chance()
    combat_state.berserk_modifiers.clear()
    if randf() < chance:
        enter_berserk()
```

Berserk chance is calculated from the base probability (by instability level) plus any accumulated event modifiers (HP < 30%, hit by disruption, killing blow). Modifiers apply to the next check and reset after rolling.

---

## 8. Ability System

### Architecture

Abilities are **data-driven and composable**. Each ability is an `AbilityData` resource containing one or more `AbilityEffect` resources. An `AbilitySystem` service interprets and executes effects.

```
AbilityComponent (Node, on ChimeraEntity)
├── abilities: Array[AbilityData]     # All abilities (4 part + combo)
├── cooldowns: Dictionary              # {ability.id: remaining_seconds}
└── methods:
    ├── initialize(combat_state: CombatState)  # Populate from parts, apply passives
    ├── is_off_cooldown(ability: AbilityData) -> bool
    ├── get_ready_abilities() -> Array[AbilityData]
    ├── execute_ability(ability: AbilityData, target: ChimeraEntity) -> void
    ├── apply_passives(combat_state: CombatState) -> void   # Called at combat start
    └── update_cooldowns(delta) -> void
```

### Effect Execution

The `AbilitySystem` (static class or service) executes effects:

```gdscript
func execute_effect(effect: AbilityEffect, source: ChimeraEntity, targets: Array) -> void:
    match effect.effect_type:
        DAMAGE:
            for target in targets:
                target.combat_state.take_damage(effect.params.amount * source.combat_state.attack)
        HEAL:
            for target in targets:
                target.combat_state.heal(effect.params.amount)
        BUFF_STAT:
            for target in targets:
                var e = ActiveEffect.new()
                e.effect_type = effect.effect_type
                e.stat_name = effect.params.stat
                e.amount = effect.params.amount
                e.duration = effect.params.duration
                e.source_id = source.ability_component.current_ability_id
                target.effect_component.add_effect(e)
        DEBUFF_STAT:
            for target in targets:
                var e = ActiveEffect.new()
                e.effect_type = effect.effect_type
                e.stat_name = effect.params.stat
                e.amount = -effect.params.amount
                e.duration = effect.params.duration
                e.source_id = source.ability_component.current_ability_id
                target.effect_component.add_effect(e)
        SHIELD:
            for target in targets:
                # Shields are tracked as active effects with SHIELD type
                var e = ActiveEffect.new()
                e.effect_type = effect.effect_type
                e.amount = effect.params.amount
                e.duration = effect.params.duration
                target.effect_component.add_effect(e)
        CLEANSE:
            for target in targets:
                target.effect_component.cleanse()
        # ... etc
```

### Passive Abilities

Passives are applied at combat start and remain active throughout:

```gdscript
func apply_passives(combat_state: CombatState) -> void:
    for ability in abilities:
        if ability.type == GameEnums.AbilityType.PASSIVE:
            for effect in ability.effects:
                apply_passive_effect(effect, combat_state)
```

Passive effects modify the CombatState snapshot (e.g., +10% attack, thorns reflection, HP regen per second). These are applied once at combat start after `CombatState.initialize()` snapshots the base stats from ChimeraData.

### Strain Combo Abilities

Combo abilities are dynamically determined when a chimera is assembled. They are not pre-equipped — the `ChimeraData` calculates them based on strain distribution:

```gdscript
func get_combo_ability() -> AbilityData:
    var strain_counts = count_strains(get_parts())
    for strain in strain_counts:
        if strain_counts[strain] >= 2:
            var tier = strain_counts[strain] - 1  # 2→Basic(1), 3→Enhanced(2), 4→Ultimate(3)
            return PartDatabase.get_strain_combo(strain, tier)
    return null
```

Strain combo abilities are predefined as `.tres` files in `resources/abilities/combos/`, organized by strain and tier (6 strains × 3 tiers = 18 combo ability definitions).

---

## 9. Save System

### Format: JSON

Save data is serialized to a JSON file at `user://saves/save_default.json`. JSON is debuggable, extensible, and easy to version.

### Save Structure

```json
{
  "version": 1,
  "timestamp": "2026-07-13T12:00:00",
  "game_state": {
    "gold": 450,
    "infamy": 75,
    "losing_streak": 0,
    "research_points": 2,
    "research_progress": {
      "strain_mastery": {"undead": 1, "beast": 0},
      "lab_engineering": {"reinforced_genetics": 1, "clinic_efficiency": 0},
      "combat_doctrine": {"tactical_ai": 0}
    },
    "roster": [
      {
        "nickname": "Brute",
        "match_wins": 5,
        "decay_level": 0,
        "parts": {
          "head": {"shape_id": "horn_large", "strain": "BEAST", "rarity": "COMMON", "slot": "HEAD"},
          "torso": {"shape_id": "body_a", "strain": "BEAST", "rarity": "UNCOMMON", "slot": "TORSO"},
          "arms": {"shape_id": "arm_b", "strain": "BEAST", "rarity": "COMMON", "slot": "ARMS"},
          "legs": {"shape_id": "leg_a", "strain": "BEAST", "rarity": "COMMON", "slot": "LEGS"}
        }
      }
    ],
    "inventory": [
      {"shape_id": "horn_small", "strain": "UNDEAD", "rarity": "RARE", "slot": "HEAD"}
    ],
    "market_stock": {
      "base": [...],
      "rotating": [
        {"shape_id": "body_c", "strain": "DRACONIC", "rarity": "UNCOMMON", "slot": "TORSO"}
      ]
    },
    "hall_of_fame": [],
    "match_history": [{"result": "win", "gold": 30}]
  }
}
```

### Serialization Strategy

Parts are saved by **reference** (shape_id + strain + rarity), not by copying all stat data. When loading, the SaveManager reconstructs PartData resources by looking up base definitions in `PartDatabase` and applying rarity modifiers. This keeps save files small and allows stat rebalancing to apply to existing saves.

```gdscript
func serialize_part(part: PartData) -> Dictionary:
    return {
        "shape_id": part.shape_id,
        "strain": part.strain,
        "rarity": part.rarity,
        "slot": part.slot
    }

func deserialize_part(data: Dictionary) -> PartData:
    return PartDatabase.get_part(data.shape_id, data.strain, data.rarity)
```

### Save Triggers

- After every match (win or loss)
- After every market purchase
- After every assembly change
- After every clinic repair
- After every research purchase
- On game exit

---

## 10. UI Architecture

### Screen Manager

A `ScreenManager` handles loading and transitioning between the 9 screens. Each screen is a `PackedScene`.

```
Main (Control)
├── ScreenManager (Control)    # Loads/unloads screen scenes
├── TopBar (Control)           # Persistent Gold/Infamy display
└── EventBus listener
```

```gdscript
# screen_manager.gd
var current_screen: Control
var screens: Dictionary = {}  # {screen_name: PackedScene}

func change_screen(screen_name: String) -> void:
    if current_screen:
        current_screen.queue_free()
    var scene = screens[screen_name]
    current_screen = scene.instantiate()
    add_child(current_screen)
    EventBus.screen_change_requested.emit(screen_name)
```

### Screen Flow

```
Lab Hub (main hub — all screens accessible from here)
├── Chimera Assembly
├── Black Market
├── Roster
├── Clinic
├── Tournament Bracket
├── Hall of Fame
└── Arena Pre-Match → Arena Combat → (return to Lab Hub with results)
```

All screens return to Lab Hub. The Arena flow (Pre-Match → Combat) is a modal flow that returns to Lab Hub after the match ends.

### Screen Registration

```gdscript
# screen_manager.gd — _ready()
screens = {
    "lab_hub": preload("res://scenes/ui/screens/lab_hub.tscn"),
    "assembly": preload("res://scenes/ui/screens/assembly.tscn"),
    "black_market": preload("res://scenes/ui/screens/black_market.tscn"),
    "arena_pre_match": preload("res://scenes/ui/screens/arena_pre_match.tscn"),
    "arena_combat": preload("res://scenes/ui/screens/arena_combat.tscn"),
    "roster": preload("res://scenes/ui/screens/roster.tscn"),
    "clinic": preload("res://scenes/ui/screens/clinic.tscn"),
    "tournament": preload("res://scenes/ui/screens/tournament.tscn"),
    "hall_of_fame": preload("res://scenes/ui/screens/hall_of_fame.tscn"),
}
```

### Chimera Sprite Composition

The `ChimeraSprite` node composites multiple Sprite2D layers to display a chimera:

```
ChimeraSprite (Node2D)
├── Body (Sprite2D)        # body sprite (includes head area)
├── Arms (Sprite2D)        # arm sprite
├── Legs (Sprite2D)        # leg sprite
├── Detail (Sprite2D)      # head detail (horns/ears/antenna)
├── Eyes (Sprite2D)        # cosmetic
├── Mouth (Sprite2D)       # cosmetic
├── Nose (Sprite2D)        # cosmetic
└── Eyebrows (Sprite2D)    # cosmetic
```

Sprite paths are constructed from the part's shape_id and strain color:

```gdscript
const STRAIN_TO_COLOR = {
    GameEnums.Strain.UNDEAD: "dark",
    GameEnums.Strain.ROBOTIC: "white",
    GameEnums.Strain.DRACONIC: "red",
    GameEnums.Strain.BEAST: "green",
    GameEnums.Strain.ELEMENTAL: "blue",
    GameEnums.Strain.ABERRANT: "yellow",
    GameEnums.Strain.NEUTRAL: "grey",  # Salvaged parts
}

func get_sprite_path(shape_id: String, strain: GameEnums.Strain) -> String:
    var color_name = STRAIN_TO_COLOR[strain]
    return "res://assets/kenney-monster-builder-pack/PNG/Default/%s_%s.png" % [shape_id, color_name]
```

---

## 11. Asset Pipeline

### Import Settings

All Kenney assets use:
- **Filter:** Nearest (pixel art, no smoothing)
- **Compression:** Lossless
- **Mipmaps:** Off (2D game, no need)

### Roguelike Pack Slicing

The Roguelike/RPG pack comes as a single spritesheet (1,700+ tiles). Options:
1. **TileSet resource** — define tile regions for arena backgrounds (floors, walls)
2. **AtlasTexture** — reference individual tiles by region for decorative sprites (banners, furniture)
3. **Pre-slice** — use a script to extract individual PNGs if needed

Recommended: Use a `TileSet` for arena ground/walls, and `AtlasTexture` for individual decorative elements. The pack's 16×16 grid with 1px margin defines the atlas regions.

### Monster Builder Pack

Already comes as individual PNGs (no slicing needed). Organized by category in `PNG/Default/`:
```
PNG/Default/
├── body_a_blue.png, body_a_dark.png, ... (6 colors × 6 shapes = 36)
├── arm_a_blue.png, arm_a_dark.png, ... (6 colors × 5 shapes = 30)
├── leg_a_blue.png, leg_a_dark.png, ... (6 colors × 5 shapes = 30)
├── detail_antenna_lg_blue.png, ... (6 colors × 7 types = 42)
├── eyes_1.png, mouth_happy.png, ... (cosmetic, ~40 sprites)
```

Sprite filenames follow the pattern: `{category}_{variant}_{color}.png`. The `shape_id` in PartData maps directly to this naming convention.

### Particle Pack

Individual transparent PNGs (80 total). Import as-is. Used with `CPUParticles2D` (sufficient for this game's particle count):
- Create `ParticleProcessMaterial` per effect type
- Assign particle textures from the pack
- Configure emission, direction, spread per effect
- Map strain VFX: Undead→smoke, Robotic→spark/muzzle, Draconic→fire/flame, Beast→dirt/spark, Elemental→magic/twirl, Aberrant→star/twirl

### UI Pack

Individual PNGs organized by color. Import as-is. Use with `NinePatchRect` for scalable panels and buttons:
- Define `NinePatchRect` resources for each UI element (buttons, panels)
- Use the included Kenney Future font for all text

### Font Registration

Register Kenney Future as the default project font in `project.godot`:

```ini
[gui]
theme/default_font = "res://assets/kenney-ui-pack/Font/Kenney Future Regular.ttf"
```

### UI Sound Effects

6 OGG sounds from the UI Pack (click, switch, tap). Load as an `AudioStream` and play on UI interactions:

```gdscript
const UI_SOUNDS = {
    "click": preload("res://assets/kenney-ui-pack/Sounds/click1.ogg"),
    "switch": preload("res://assets/kenney-ui-pack/Sounds/switch1.ogg"),
    "tap": preload("res://assets/kenney-ui-pack/Sounds/tap1.ogg"),
}
```
