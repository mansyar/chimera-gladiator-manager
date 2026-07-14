<protect>
# Implementation Plan: Data Models & Enums (TRACK-002)

## Phase 1: Enums & Base Resource Classes [checkpoint: 835a82f]

> Data-only classes — exempt from TDD per workflow rules (pure enum declarations and `@export` variable definitions without logic). Dependency order: GameEnums → AbilityEffect → BehaviorModuleData → PartData → AbilityData → PartDatabase stub.

- [x] Task: Read context documents before starting Phase 1
    - [x] Read `conductor/tracks/data_models_20260714/spec.md`
    - [x] Read `conductor/workflow.md`

- [x] Task: Create GameEnums (`scripts/data/enums.gd`) [28b28bf]
    - [x] Implement `class_name GameEnums` with all 8 enums: Strain (7 values incl NEUTRAL), Rarity (4), PartSlot (4), Instability (4), AbilityType (2), AbilityCategory (4), TargetingMode (6), Positioning (3)
    - [x] Verify class compiles without errors

- [x] Task: Create AbilityEffect resource (`scripts/data/ability_effect.gd`) [28b28bf]
    - [x] Implement `class_name AbilityEffect extends Resource`
    - [x] Implement `enum EffectType` with 11 types: DAMAGE, HEAL, BUFF_STAT, DEBUFF_STAT, REPOSITION, SHIELD, CLEANSE, REVIVE, ENRAGE, STAT_MUTATION, RANDOM_EFFECT
    - [x] Implement `@export var effect_type: EffectType` and `@export var params: Dictionary`
    - [x] Verify class is inspector-editable (can create .tres instance)

- [x] Task: Create BehaviorModuleData resource (`scripts/data/behavior_module_data.gd`) [28b28bf]
    - [x] Implement `class_name BehaviorModuleData extends Resource`
    - [x] Implement @export vars: module_name (String), detail_type (String), targeting (GameEnums.TargetingMode), ability_priority (Array[GameEnums.AbilityCategory]), positioning (GameEnums.Positioning)
    - [x] Verify class is inspector-editable

- [x] Task: Create PartData resource (`scripts/data/part_data.gd`) [28b28bf]
    - [x] Implement `class_name PartData extends Resource`
    - [x] Implement @export vars: slot, shape_id, strain, rarity, sprite_path, hp_bonus, attack_bonus, defense_bonus, speed_bonus, ability_id, behavior_module (BehaviorModuleData), attack_range (float = 32.0)
    - [x] Verify class is inspector-editable

- [x] Task: Create AbilityData resource (`scripts/data/ability_data.gd`) [28b28bf]
    - [x] Implement `class_name AbilityData extends Resource`
    - [x] Implement @export vars: id, name, description, type (GameEnums.AbilityType), category (GameEnums.AbilityCategory), cooldown (float = 0.0), targeting (String), range (float = 0.0), effects (Array[AbilityEffect])
    - [x] Verify class is inspector-editable

- [x] Task: Create PartDatabase stub (`scripts/systems/part_database.gd`) [28b28bf]
    - [x] Implement `class_name PartDatabase` with static vars: part_templates (Dictionary = {}), ability_templates (Dictionary = {})
    - [x] Implement static methods returning null/empty: get_part() -> null, get_ability() -> null, get_base_stats() -> {}, generate_random_part() -> null, get_strain_combo() -> null
    - [x] Verify class compiles without errors

- [x] Task: Verify Phase 1 code quality [28b28bf]
    - [x] Run `gd-tools lint` — must exit 0
    - [x] Run `gd-tools format --check` — must exit 0

- [x] Task: Conductor - User Manual Verification 'Phase 1: Enums & Base Resource Classes' (Protocol in workflow.md) [835a82f]

## Phase 2: Chimera & Combat State

> Classes with testable logic — TDD applies. Class structure (properties) created first as data scaffolding with empty method stubs, then logic methods follow Red-Green TDD cycle. Dependency order: ChimeraData → ActiveEffect → CombatState.

- [x] Task: Read context documents before starting Phase 2
    - [x] Read `conductor/tracks/data_models_20260714/spec.md`
    - [x] Read `conductor/workflow.md`

- [x] Task: Implement ChimeraData with TDD (`scripts/data/chimera_data.gd`) [d037bff]
    - [x] Create class structure: `class_name ChimeraData extends Resource`, @export vars (nickname, head/torso/arms/legs as 4 separate PartData), derived stat declarations, ability declarations, persistent state, `const PUREBRED_STAT_MULTIPLIER: float = 1.2`, empty method stubs (get_parts, get_part, recalculate_stats, calculate_instability, get_combo_ability)
    - [x] Write failing tests (`tests/data/test_chimera_data.gd`) (Red phase):
        - get_parts() returns [head, torso, arms, legs]
        - get_part() returns correct PartData for each PartSlot value
        - recalculate_stats() sums hp/attack/defense/speed bonuses from 4 parts
        - recalculate_stats() applies PUREBRED_STAT_MULTIPLIER when instability == 0
        - recalculate_stats(research_bonuses) applies multipliers from Dictionary
        - calculate_instability() returns 0 for 4 same-strain (Pure)
        - calculate_instability() returns 3 for 4 different-strain (Chaotic)
        - calculate_instability() returns 1 for 2 same + 2 different
        - calculate_instability() sets dominant_strain to most common
        - get_combo_ability() sets combo_tier=1 for 2 same-strain (Basic)
        - get_combo_ability() sets combo_tier=2 for 3 same-strain (Enhanced)
        - get_combo_ability() sets combo_tier=3 for 4 same-strain (Ultimate)
        - get_combo_ability() returns null for all-different strains
    - [x] Implement logic methods to pass tests (Green phase): get_parts(), get_part() with match, calculate_instability() (count distinct strains, set instability/strain_count/dominant_strain), recalculate_stats() (sum stats, apply purebred bonus, apply research, set derived properties), get_combo_ability() (count strains, determine tier, call PartDatabase.get_strain_combo())
    - [x] Verify coverage > 80% for chimera_data.gd (DEFERRED — gd-tools coverage addon fails on autoload scripts; user will fix separately. 17/17 tests pass without --coverage flag.)

- [x] Task: Implement ActiveEffect with TDD (`scripts/combat/active_effect.gd`) [b540b78]
    - [x] Create class structure: `class_name ActiveEffect extends RefCounted`, properties (effect_type, stat_name, amount, duration, source_id), empty method stub (tick)
    - [x] Write failing tests (`tests/combat/test_active_effect.gd`) (Red phase):
        - tick() decrements duration by delta
        - tick() returns true when duration reaches 0 (expired)
        - tick() returns false when duration > 0 (not expired)
    - [x] Implement tick(delta) -> bool: decrement duration, return duration <= 0.0 (Green phase)
    - [x] Verify coverage > 80% for active_effect.gd (DEFERRED — coverage addon issue; user will fix separately)

- [x] Task: Implement CombatState with TDD (`scripts/combat/combat_state.gd`) [06c3770]
    - [x] Create class structure: `class_name CombatState extends RefCounted`, all properties (chimera_data, current_hp, max_hp, attack, defense, speed, is_berserk, berserk timers, berserk_modifiers, ability_cooldowns, active_effects, is_dead, team), empty method stubs (initialize, take_damage, heal)
    - [x] Write failing tests (`tests/combat/test_combat_state.gd`) (Red phase):
        - initialize() snapshots max_hp, attack, defense, speed from ChimeraData
        - initialize() sets current_hp = max_hp
        - initialize() sets team correctly
        - take_damage() reduces current_hp by amount
        - take_damage() sets is_dead when current_hp reaches 0
        - take_damage() does not reduce current_hp below 0
        - heal() increases current_hp by amount
        - heal() caps at max_hp
    - [x] Implement logic methods (Green phase): initialize(data, team_id), take_damage(amount), heal(amount)
    - [x] Verify coverage > 80% for combat_state.gd (DEFERRED — coverage addon issue; user will fix separately)

- [ ] Task: Verify Phase 2 code quality
    - [ ] Run `gd-tools lint` — must exit 0
    - [ ] Run `gd-tools format --check` — must exit 0
    - [ ] Run `gd-tools test --coverage --min 80` — must exit 0

- [ ] Task: Conductor - User Manual Verification 'Phase 2: Chimera & Combat State' (Protocol in workflow.md)

## Phase 3: Effect Component

> EffectComponent has testable logic (add_effect, tick, recalculate_modifiers, get_modified_stat, cleanse) — TDD applies. Depends on ActiveEffect (Phase 2) and AbilityEffect (Phase 1).

- [ ] Task: Read context documents before starting Phase 3
    - [ ] Read `conductor/tracks/data_models_20260714/spec.md`
    - [ ] Read `conductor/workflow.md`

- [ ] Task: Implement EffectComponent with TDD (`scripts/combat/effect_component.gd`)
    - [ ] Create class structure: `class_name EffectComponent extends Node`, properties (active_effects: Array[ActiveEffect], stat_modifiers: Dictionary), empty method stubs (add_effect, tick, recalculate_modifiers, get_modified_stat, cleanse)
    - [ ] Write failing tests (`tests/combat/test_effect_component.gd`) (Red phase):
        - add_effect() appends effect to active_effects
        - add_effect() updates stat_modifiers (BUFF_STAT with positive amount)
        - add_effect() updates stat_modifiers (DEBUFF_STAT with negative amount)
        - tick() removes expired effects from active_effects
        - tick() calls recalculate_modifiers() after removing expired effects
        - tick() does NOT recalculate when no effects expired
        - recalculate_modifiers() sums multiple buffs/debuffs for same stat
        - get_modified_stat() returns base_value + modifier
        - get_modified_stat() returns base_value when no modifier exists for stat
        - cleanse() removes only DEBUFF_STAT effects
        - cleanse() keeps BUFF_STAT effects in active_effects
        - cleanse() calls recalculate_modifiers() after removal
    - [ ] Implement logic methods (Green phase): add_effect(), tick(), recalculate_modifiers(), get_modified_stat(), cleanse()
    - [ ] Verify coverage > 80% for effect_component.gd

- [ ] Task: Final verification — full quality gate
    - [ ] Run `gd-tools lint` — must exit 0
    - [ ] Run `gd-tools format --check` — must exit 0
    - [ ] Run `gd-tools test --coverage --min 80` — must exit 0
    - [ ] Verify all 12 acceptance criteria tests from spec pass

- [ ] Task: Conductor - User Manual Verification 'Phase 3: Effect Component' (Protocol in workflow.md)
</protect>
