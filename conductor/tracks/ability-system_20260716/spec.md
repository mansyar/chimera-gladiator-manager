# Track Specification: TRACK-007 — Ability & Effect System

## Overview

This track implements the full ability execution engine for combat. It replaces the `AbilityComponent` stub (from TRACK-005) with a complete implementation, creates the `AbilitySystem` static class that executes all 11 effect types, implements passive ability application at combat start, and integrates strain combo ability lookup.

Abilities are data-driven and composable: each `AbilityData` resource contains one or more `AbilityEffect` resources. The `AbilitySystem` interprets and executes effects against targets. The `AbilityComponent` manages cooldowns, target resolution, and delegates to `AbilitySystem` for execution.

## Context

### Prior Track Dependencies (All Complete)
- **TRACK-002**: `AbilityData`, `AbilityEffect` (11 EffectType enum), `ActiveEffect`, `EffectComponent`, `CombatState`, `ChimeraData` (with `get_combo_ability()`, `part_abilities`, `combo_ability`)
- **TRACK-003**: 23 part ability .tres files, 18 strain combo .tres files, `PartDatabase` with `get_ability()` and `get_strain_combo()`
- **TRACK-005**: `AbilityComponent` stub, `ChimeraEntity` with component refs, `CombatContext` (entity registry with `get_enemies_of()`, `get_allies_of()`), `calculate_damage()` with berserk+effect modifiers
- **TRACK-006**: `AIController` with FSM, `UseAbilityState` calling `ability_component.execute_ability(ability.id)`, `AIController.get_next_ready_ability()` with priority filtering

### Existing Code to Modify
1. `scripts/combat/ability_component.gd` — Replace stub with full implementation
2. `scripts/combat/chimera_entity.gd` — Add `ability_component.update_cooldowns(delta)` call in `_process()`
3. `scripts/ai/states/use_ability_state.gd` — Change `execute_ability(ability.id)` to `execute_ability(ability, target)` (pass AbilityData + primary target)
4. `scripts/combat/effect_component.gd` — Add `absorb_damage(amount: float) -> float` method for SHIELD support

### New Code to Create
1. `scripts/systems/ability_system.gd` — Static class with `execute_effect()` for all 11 EffectTypes

## Functional Requirements

### FR-1: AbilityComponent — Initialization
- `initialize(combat_state: CombatState)` populates the `abilities` array from `combat_state.chimera_data`:
  - Collects 4 part abilities from `chimera_data.part_abilities`
  - Collects strain combo ability via `chimera_data.get_combo_ability()` (returns null if <2 same-strain)
  - Stores all abilities in `abilities: Array[AbilityData]`
  - Initializes `cooldowns: Dictionary` with all ability IDs set to 0.0
  - Calls `apply_passives(combat_state)` after population
- Stores reference to parent `ChimeraEntity` for accessing `combat_context`

### FR-2: AbilityComponent — Cooldown Management
- `is_off_cooldown(ability: AbilityData) -> bool`: Returns true if `cooldowns[ability.id] <= 0.0`
- `update_cooldowns(delta: float) -> void`: Decrements all cooldown values by delta, floored at 0.0
- `execute_ability(ability: AbilityData, primary_target: ChimeraEntity) -> void`:
  - Sets `current_ability_id = ability.id` (for ActiveEffect source tracking)
  - Sets `cooldowns[ability.id] = ability.cooldown`
  - Resolves targets based on `ability.targeting` field (see FR-3)
  - Calls `AbilitySystem.execute_effect()` for each `AbilityEffect` in `ability.effects`, passing source entity and resolved targets

### FR-3: AbilityComponent — Target Resolution
- Target resolution uses `ability.targeting` field (String) and `combat_context` (from parent ChimeraEntity):
  - `"SELF"`: Target is the source entity only
  - `"TARGET"`: Target is the primary_target passed by AI controller
  - `"AOE_ENEMIES"`: All living enemies within `ability.range` of primary_target
  - `"AOE_ALLIES"`: All living allies within `ability.range` of primary_target
  - `"ALL_ENEMIES"`: All living enemies (no range limit)
- Uses `CombatContext.get_enemies_of(team)` and `CombatContext.get_allies_of(team)` for AOE expansion
- Range filtering uses `global_position.distance_to(target.global_position)`

### FR-4: AbilityComponent — Ready Abilities
- `get_ready_abilities() -> Array[AbilityData]`: Returns all ACTIVE abilities (type != PASSIVE) where `is_off_cooldown()` is true
- The `get_next_ready_ability(priority)` stub method is not used by the AIController (which has its own implementation) and should be removed

### FR-5: AbilityComponent — Passive Application
- `apply_passives(combat_state: CombatState) -> void`:
  - Iterates all abilities where `ability.type == GameEnums.AbilityType.PASSIVE`
  - For each passive ability, calls `AbilitySystem.execute_effect()` for each effect, with source=self and targets=[self]
  - Passive effects modify the CombatState snapshot directly (e.g., +10% attack, HP regen)
  - Called once at combat start, after `CombatState.initialize()` snapshots base stats
  - Passives persist throughout combat, including during berserk state (GDD: "passives remain active")

### FR-6: AbilitySystem — Effect Execution (11 EffectTypes)
The `AbilitySystem` static class provides `execute_effect(effect: AbilityEffect, source: ChimeraEntity, targets: Array) -> void`:

| EffectType | Behavior |
|---|---|
| **DAMAGE** | `target.combat_state.take_damage(params["amount"] * source.combat_state.attack)` for each target |
| **HEAL** | `target.combat_state.heal(params["amount"])` for each target (capped at max_hp by existing heal()) |
| **BUFF_STAT** | Creates `ActiveEffect` (positive amount, stat_name=params["stat"], duration=params["duration"], source_id=current_ability_id). Added via `target.effect_component.add_effect()` |
| **DEBUFF_STAT** | Creates `ActiveEffect` (negative amount=-params["amount"], stat_name=params["stat"], duration=params["duration"], source_id=current_ability_id). Added via `target.effect_component.add_effect()` |
| **REPOSITION** | Pushes target along source-to-target direction vector by `params["distance"]` pixels. Modifies `target.global_position` directly. If targeting is SELF, pushes along source-to-nearest-enemy direction. |
| **SHIELD** | Creates `ActiveEffect` (effect_type=SHIELD, amount=params["amount"], duration=params["duration"]). Shield absorbs incoming damage before HP reduction. When shield amount reaches 0, it is removed. |
| **CLEANSE** | Calls `target.effect_component.cleanse()` for each target (removes all DEBUFF_STAT effects) |
| **REVIVE** | If target is dead (`is_dead == true`): sets `is_dead = false`, `current_hp = max_hp * params["hp_percent"]`. No effect on living targets. |
| **ENRAGE** | Calls `target.ai_controller.enter_berserk()` then overrides `target.combat_state.berserk_timer = params["duration"]`. Forces berserk regardless of instability. Reuses existing berserk state machine. |
| **STAT_MUTATION** | Permanently modifies `target.combat_state` stat (params["stat"]) by `params["amount"]`. No ActiveEffect, no duration, cannot be cleansed. Directly modifies the snapshot (e.g., `combat_state.attack += params["amount"]`). |
| **RANDOM_EFFECT** | Picks one AbilityEffect randomly from the other entries in the same ability's `effects` array (excluding the RANDOM_EFFECT entry itself). Executes the picked effect via `execute_effect()` with the same source and targets. Uses the picked effect's pre-defined params. |

### FR-7: Strain Combo Integration
- Combo ability is determined dynamically via `chimera_data.get_combo_ability()` (already implemented in TRACK-002):
  - Counts strains across 4 parts
  - If 2+ parts share a strain: `PartDatabase.get_strain_combo(strain, tier)` where tier = count - 1
  - Tier mapping: 2 same-strain = Basic (1), 3 = Enhanced (2), 4 = Ultimate (3)
  - All-different = null (no combo)
- AbilityComponent calls `get_combo_ability()` during `initialize()` and adds result to `abilities` array

### FR-8: ChimeraEntity Integration
- `ChimeraEntity._process()` must call `ability_component.update_cooldowns(delta)` each frame (alongside existing `effect_component.tick(delta)`)
- The `UseAbilityState` (TRACK-006) calls `ability_component.execute_ability(ability, target)` — signature changes from `(ability_id: String)` to `(ability: AbilityData, primary_target: ChimeraEntity)`

### FR-9: SHIELD Damage Absorption
- `EffectComponent` gains a new method: `absorb_damage(amount: float) -> float`
  - Iterates SHIELD-type ActiveEffects
  - Reduces each shield's `amount` by the incoming damage
  - Removes shields that reach 0 amount
  - Returns remaining damage after all shields consumed
- The damage application flow must call `absorb_damage()` before `take_damage()`:
  - `var damage = EffectComponent.absorb_damage(damage)` then `combat_state.take_damage(damage)`
- SHIELD effects are NOT removed by `cleanse()` (only DEBUFF_STAT is removed)

## Non-Functional Requirements

- **NFR-1: Test Coverage**: >=80% coverage for all new and modified source files with testable logic
- **NFR-2: Type Safety**: All variables, parameters, and return types must be explicitly typed (GDScript strict typing)
- **NFR-3: Static Class Pattern**: `AbilitySystem` must be a static utility class with pure functions (no state), consistent with `economy.gd`, `market.gd`, `decay.gd`, `research.gd`
- **NFR-4: Code Quality**: Must pass `gd-tools lint` and `gd-tools format --check`
- **NFR-5: Documentation**: All public functions must have `##` doc comments

## Acceptance Criteria

1. **DAMAGE** reduces target HP by `params["amount"] * source.attack`
2. **HEAL** increases HP, capped at max_hp
3. **BUFF_STAT** creates ActiveEffect with positive amount, visible in EffectComponent
4. **DEBUFF_STAT** creates ActiveEffect with negative amount, removable by cleanse
5. **SHIELD** creates SHIELD ActiveEffect that absorbs damage before HP reduction; removed when amount reaches 0
6. **CLEANSE** removes all DEBUFF_STAT effects from target
7. **REPOSITION** displaces target by `params["distance"]` pixels along source-to-target vector
8. **REVIVE** resurrects dead target at `params["hp_percent"]` of max_hp; no effect on living targets
9. **ENRAGE** forces berserk state for `params["duration"]` seconds via existing berserk system
10. **STAT_MUTATION** permanently modifies CombatState stat; no ActiveEffect; cannot be cleansed
11. **RANDOM_EFFECT** picks and executes a random effect from the ability's effect list (excluding itself)
12. `apply_passives()` modifies CombatState at combat start
13. Passives persist when `is_berserk == true`
14. Combo tiers: 2 same-strain = Basic, 3 = Enhanced, 4 = Ultimate, all-different = null
15. `is_off_cooldown()` returns false after `execute_ability()`, true after cooldown expires
16. `get_ready_abilities()` returns only ACTIVE abilities that are off cooldown
17. `update_cooldowns(delta)` decrements all cooldowns, floored at 0.0
18. Target resolution correctly expands AOE targets via CombatContext
19. `ChimeraEntity._process()` calls `ability_component.update_cooldowns(delta)`
20. `UseAbilityState` calls `execute_ability(ability, target)` with updated signature
21. SHIELD absorption: `EffectComponent.absorb_damage()` reduces shield amounts before HP

## Out of Scope

- .tres ability data file content (created in TRACK-003, complete)
- AI state machine logic (implemented in TRACK-006, complete)
- VFX for ability casts (TRACK-014)
- Combat HUD / status effect icons (TRACK-014)
- CombatManager match lifecycle (TRACK-008)
- Specific ability values, cooldowns, and balancing (deferred to .tres data files)
- Enemy generation (TRACK-008)
