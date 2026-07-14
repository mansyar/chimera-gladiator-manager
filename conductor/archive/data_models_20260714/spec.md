<protect>
# Track Specification: Data Models & Enums (TRACK-002)

## Overview

Implement the foundational data model layer for Chimera Gladiator Manager. This track creates all GDScript class definitions for game enums, resource-based data models (PartData, AbilityData, AbilityEffect, BehaviorModuleData, ChimeraData), and combat-state classes (CombatState, ActiveEffect, EffectComponent). A PartDatabase stub is also created with empty method signatures. These classes form the data backbone consumed by all subsequent tracks (database population, singleton architecture, combat, abilities, UI).

## Context Anchors (Traceability)

- **GDD Reference:** Section 2.1 (Modular Fusion — 4 slots, 6 strains, stat roles), Section 2.2 (Genetic Instability — 0-3 scale, purebred bonuses), Section 2.3 (Abilities — active/passive, 11 effect types, strain combo tiers), Section 2.4 (Behavior Modules — 7 modules, 6 targeting modes, 3 positioning tendencies)
- **TDD Reference:** Section 3 (Data Models — all class definitions, Stat Calculation Flow, PartDatabase stub)
- **ROADMAP:** TRACK-002, Milestone 2 (Data Layer & Core Infrastructure)
- **Dependencies:** TRACK-001 (Complete — project scaffolding, autoload stubs, gd-tools environment)

## Functional Requirements

### FR-1: GameEnums (`scripts/data/enums.gd`)

A `class_name GameEnums` script containing all shared enums used across the project:

- `enum Strain { UNDEAD, ROBOTIC, DRACONIC, BEAST, ELEMENTAL, ABERRANT, NEUTRAL }` (7 values)
- `enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }` (4 values)
- `enum PartSlot { HEAD, TORSO, ARMS, LEGS }` (4 values)
- `enum Instability { PURE, STABLE, VOLATILE, CHAOTIC }` (4 values)
- `enum AbilityType { ACTIVE, PASSIVE }` (2 values)
- `enum AbilityCategory { OFFENSE, MOBILITY, UTILITY, DEFENSE }` (4 values)
- `enum TargetingMode { NEAREST, WEAKEST_ACCESSIBLE, HIGHEST_THREAT, OPTIMAL_DISRUPT, ATTACKING_ALLIES, LOWEST_HP }` (6 values)
- `enum Positioning { FRONT, MID, BACK }` (3 values)

### FR-2: PartData (`scripts/data/part_data.gd`)

A `Resource` subclass representing a single equippable part:

- `@export var slot: GameEnums.PartSlot`
- `@export var shape_id: String`
- `@export var strain: GameEnums.Strain`
- `@export var rarity: GameEnums.Rarity`
- `@export var sprite_path: String`
- `@export var hp_bonus: float = 0.0`
- `@export var attack_bonus: float = 0.0`
- `@export var defense_bonus: float = 0.0`
- `@export var speed_bonus: float = 0.0`
- `@export var ability_id: String`
- `@export var behavior_module: BehaviorModuleData` (null for non-HEAD parts)
- `@export var attack_range: float = 32.0` (ARMS only — default melee)

### FR-3: AbilityData (`scripts/data/ability_data.gd`)

A `Resource` subclass defining a single ability (composable collection of effects):

- `@export var id: String`
- `@export var name: String`
- `@export var description: String`
- `@export var type: GameEnums.AbilityType`
- `@export var category: GameEnums.AbilityCategory`
- `@export var cooldown: float = 0.0`
- `@export var targeting: String` (SELF, TARGET, AOE_ENEMIES, AOE_ALLIES, ALL_ENEMIES)
- `@export var range: float = 0.0`
- `@export var effects: Array[AbilityEffect]`

### FR-4: AbilityEffect (`scripts/data/ability_effect.gd`)

A `Resource` subclass representing a single composable effect within an ability:

- `enum EffectType { DAMAGE, HEAL, BUFF_STAT, DEBUFF_STAT, REPOSITION, SHIELD, CLEANSE, REVIVE, ENRAGE, STAT_MUTATION, RANDOM_EFFECT }` (11 types)
- `@export var effect_type: EffectType`
- `@export var params: Dictionary`

### FR-5: BehaviorModuleData (`scripts/data/behavior_module_data.gd`)

A `Resource` subclass configuring an AI behavior module:

- `@export var module_name: String`
- `@export var detail_type: String`
- `@export var targeting: GameEnums.TargetingMode`
- `@export var ability_priority: Array[GameEnums.AbilityCategory]`
- `@export var positioning: GameEnums.Positioning`

### FR-6: ChimeraData (`scripts/data/chimera_data.gd`)

A `Resource` subclass representing a chimera in persistent campaign state:

**Exported Properties:**
- `@export var nickname: String`
- `@export var head: PartData`
- `@export var torso: PartData`
- `@export var arms: PartData`
- `@export var legs: PartData`

**Derived Stats (recalculated on part change):**
- `var max_hp: float`
- `var attack: float`
- `var defense: float`
- `var speed: float`
- `var attack_range: float` (from ARMS)
- `var instability: int` (0-3, from strain count)
- `var strain_count: int`
- `var dominant_strain: GameEnums.Strain`

**Abilities (derived from parts):**
- `var part_abilities: Array[AbilityData]` (4 abilities, one per part)
- `var combo_ability: AbilityData` (5th ability if 2+ same-strain)
- `var combo_tier: int` (0=none, 1=basic, 2=enhanced, 3=ultimate)

**Persistent State:**
- `var current_hp: float`
- `var decay_level: int = 0`
- `var match_wins: int = 0`

**Methods:**
- `get_parts() -> Array[PartData]` — returns [head, torso, arms, legs]
- `get_part(slot: GameEnums.PartSlot) -> PartData` — match on slot enum
- `recalculate_stats(research_bonuses: Dictionary = {}) -> void` — sums stats from 4 parts, applies purebred bonus (const multiplier if instability == 0), applies research bonuses (from optional dict), sets derived properties
- `calculate_instability() -> void` — counts distinct strains across 4 parts, sets instability (0-3), strain_count, dominant_strain
- `get_combo_ability() -> AbilityData` — counts strains, if 2+ share a strain determines tier (count-1), calls PartDatabase.get_strain_combo() (stub returns null in this track)

**Key Implementation Decision — Purebred Bonus:** Use a `const PUREBRED_STAT_MULTIPLIER: float = 1.2` (placeholder +20%). Applied to all four base stats when instability == 0. Tunable in TRACK-003.

**Key Implementation Decision — Research Bonuses:** `recalculate_stats()` accepts an optional `research_bonuses: Dictionary = {}` parameter. When empty (default), no research modifiers are applied. When populated (by GameState in TRACK-004), the dictionary contains stat multipliers keyed by stat name.

### FR-7: CombatState (`scripts/combat/combat_state.gd`)

A `RefCounted` class holding transient combat state (created at match start, destroyed at match end):

**Properties:**
- `var chimera_data: ChimeraData`
- `var current_hp: float`
- `var max_hp: float` (snapshot at combat start)
- `var attack: float` (snapshot)
- `var defense: float` (snapshot)
- `var speed: float` (snapshot)
- `var is_berserk: bool = false`
- `var berserk_timer: float = 0.0`
- `var berserk_check_timer: float = 0.0`
- `var berserk_modifiers: Dictionary = {}`
- `var ability_cooldowns: Dictionary = {}` ({ability_id: remaining_seconds})
- `var active_effects: Array[ActiveEffect] = []`
- `var is_dead: bool = false`
- `var team: int` (0=player, 1=enemy)

**Methods:**
- `initialize(data: ChimeraData, team_id: int) -> void` — snapshots stats from ChimeraData, sets current_hp = max_hp
- `take_damage(amount: float) -> void` — reduces current_hp (min 0), sets is_dead at 0
- `heal(amount: float) -> void` — increases current_hp (min max_hp)

### FR-8: ActiveEffect (`scripts/combat/active_effect.gd`)

A `RefCounted` class representing a single temporary status effect:

**Properties:**
- `var effect_type: AbilityEffect.EffectType`
- `var stat_name: String`
- `var amount: float` (positive for buff, negative for debuff)
- `var duration: float` (remaining seconds)
- `var source_id: String`

**Methods:**
- `tick(delta: float) -> bool` — decrements duration, returns true if expired (duration <= 0.0)

### FR-9: EffectComponent (`scripts/combat/effect_component.gd`)

A `Node` subclass that tracks, ticks, and cleans up ActiveEffects on a ChimeraEntity:

**Properties:**
- `var active_effects: Array[ActiveEffect] = []`
- `var stat_modifiers: Dictionary = {}` ({stat_name: total_modifier})

**Methods:**
- `add_effect(effect: ActiveEffect) -> void` — appends to active_effects, recalculates modifiers
- `tick(delta: float) -> void` — ticks all effects, removes expired ones, recalculates if any expired
- `recalculate_modifiers() -> void` — sums all BUFF_STAT and DEBUFF_STAT amounts per stat_name
- `get_modified_stat(stat_name: String, base_value: float) -> float` — returns base_value + modifier
- `cleanse() -> void` — removes all DEBUFF_STAT effects, recalculates modifiers

**Key Implementation Decision — Tick Lifecycle:** Only `tick(delta)` is exposed as a public method. No `_process()` override. The caller (ChimeraEntity in TRACK-005) is responsible for calling `tick()` each frame.

### FR-10: PartDatabase Stub (`scripts/systems/part_database.gd`)

A `class_name PartDatabase` static class with empty method signatures returning null/empty defaults:

- `static var part_templates: Dictionary = {}`
- `static var ability_templates: Dictionary = {}`
- `static func get_part(shape_id: String, strain: GameEnums.Strain, rarity: GameEnums.Rarity) -> PartData:` — returns null
- `static func get_ability(ability_id: String) -> AbilityData:` — returns null
- `static func get_base_stats(shape_id: String) -> Dictionary:` — returns {}
- `static func generate_random_part(slot: GameEnums.PartSlot, rarity_weights: Dictionary) -> PartData:` — returns null
- `static func get_strain_combo(strain: GameEnums.Strain, tier: int) -> AbilityData:` — returns null

**Key Implementation Decision — Stub Scope:** All methods return null/empty. Full implementation logic is TRACK-003.

## Non-Functional Requirements

### NFR-1: Godot Resource System Compatibility
- PartData, AbilityData, AbilityEffect, BehaviorModuleData, ChimeraData must extend `Resource` and be instantiable as `.tres` files in the Godot inspector.
- All editable properties must use `@export` with appropriate types.
- Part slots on ChimeraData must use 4 separate `@export var` (head/torso/arms/legs), NOT a typed Dictionary (Godot 4 inspector limitation).
- PartData references abilities by `ability_id: String` (looked up via PartDatabase), NOT embedded AbilityData resources.

### NFR-2: Architecture Compliance
- ChimeraData is a persistent `Resource` (campaign state). CombatState is a transient `RefCounted` (per-match). These must NOT mix persistent and combat state.
- EffectComponent is a `Node` (lives on ChimeraEntity in combat). ActiveEffect is `RefCounted` (lightweight, per-effect).
- PartDatabase is a static utility class with no instance state.

### NFR-3: Code Quality
- All public functions documented with `##` doc comments.
- Type safety enforced (typed variables, typed return types, typed arrays where applicable).
- `gd-tools lint` passes with zero errors.
- `gd-tools format --check` passes with zero errors.
- Test coverage >= 80% for source code with testable logic.

### NFR-4: TDD Compliance
- Pure data/enum definitions (GameEnums, PartData, AbilityData, AbilityEffect, BehaviorModuleData exports) are exempt from TDD per workflow rules.
- Classes with testable logic (ChimeraData methods, CombatState methods, ActiveEffect.tick, EffectComponent methods) MUST have corresponding tests.
- PartDatabase stub (returns null/empty) is exempt from testing.

## Acceptance Criteria

### AC-1: Inspector-Editable Resources
- Can create `.tres` instances of PartData, AbilityData, AbilityEffect, BehaviorModuleData in the Godot inspector.
- ChimeraData with 4 parts assigned shows correct derived stats in a test scene.

### AC-2: Automated Tests (from ROADMAP DoD)
Tests verify:
1. `recalculate_stats()` sums stats from 4 parts correctly
2. `calculate_instability()` returns 0 for 4 same-strain parts, 3 for 4 different-strain parts
3. `get_combo_ability()` returns correct tier for 2/3/4 same-strain parts (Basic/Enhanced/Ultimate), null for all-different
4. `CombatState.take_damage()` reduces HP and sets `is_dead` when HP reaches 0
5. `ActiveEffect.tick()` returns true when expired, false otherwise
6. `EffectComponent.add_effect()` updates `stat_modifiers` correctly
7. `EffectComponent.cleanse()` removes only debuffs (DEBUFF_STAT), keeps buffs (BUFF_STAT)
8. `CombatState.initialize()` correctly snapshots stats from ChimeraData
9. `CombatState.heal()` caps at `max_hp`
10. `EffectComponent.get_modified_stat()` returns correct modified value
11. Purebred bonus (instability == 0) applies the const multiplier to all stats
12. `recalculate_stats()` with research_bonuses parameter applies bonuses correctly

### AC-3: Quality Gates
- `gd-tools test --coverage --min 80` exits 0
- `gd-tools lint` exits 0
- `gd-tools format --check` exits 0

## Out of Scope

- `.tres` data file content (created in TRACK-003)
- PartDatabase implementation logic (stub only — full implementation in TRACK-003)
- Ability execution engine (created in TRACK-007)
- Combat integration / scene setup (TRACK-005)
- AI state machine (TRACK-006)
- GameState, EventBus, SaveManager, CombatManager autoloads (TRACK-004)
- Sprite path construction / ChimeraSprite composition (TRACK-005)
</protect>
