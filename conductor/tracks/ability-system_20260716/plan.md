<protect>
# Implementation Plan: TRACK-007 — Ability & Effect System

## Phase 1: AbilityComponent Foundation

Focus: Replace the TRACK-005 stub with a working AbilityComponent — initialization, cooldown tracking, and ready-ability querying.

- [ ] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [ ] Read `conductor/tracks/ability-system_20260716/spec.md`
    - [ ] Read `conductor/workflow.md`

- [ ] Task: Remove unused stub and add `current_ability_id` property
    - [ ] Remove `get_next_ready_ability(_priority: Array)` stub method (AIController has its own; this is dead code)
    - [ ] Add `var current_ability_id: String` property to AbilityComponent (for ActiveEffect source tracking per TDD)
    - [ ] Add `var abilities: Array[AbilityData] = []` and `var cooldowns: Dictionary = {}` properties
    - [ ] Verify: `gd-tools lint` passes with no unused function warnings

- [ ] Task: Implement `initialize(combat_state: CombatState)`
    - [ ] Write failing tests: test that initialize populates `abilities` from `chimera_data.part_abilities`, adds combo ability via `get_combo_ability()`, initializes `cooldowns` dict with all ability IDs set to 0.0
    - [ ] Write failing test: test that combo ability is null when all 4 parts are different strains (all-different case)
    - [ ] Implement: `initialize()` collects part abilities + combo, populates cooldowns dict, calls `apply_passives(combat_state)`
    - [ ] Verify: all tests pass, `gd-tools test --coverage --min 80`

- [ ] Task: Implement cooldown management methods
    - [ ] Write failing test: `is_off_cooldown()` returns true for fresh ability (cooldown 0.0), false after `execute_ability()` sets cooldown
    - [ ] Write failing test: `is_off_cooldown()` returns true after cooldown expires via `update_cooldowns(delta)`
    - [ ] Write failing test: `update_cooldowns(delta)` decrements all cooldowns, floors at 0.0
    - [ ] Write failing test: `get_ready_abilities()` returns only ACTIVE-type abilities (not PASSIVE) that are off cooldown
    - [ ] Implement: `is_off_cooldown(ability)`, `update_cooldowns(delta)`, `get_ready_abilities()`
    - [ ] Verify: all tests pass, coverage >=80%

- [ ] Task: Conductor - User Manual Verification 'Phase 1: AbilityComponent Foundation' (Protocol in workflow.md)

## Phase 2: AbilitySystem Static Class — All 11 Effect Types

Focus: Create the `AbilitySystem` static utility class with `execute_effect()` handling all 11 EffectType variants.

- [ ] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [ ] Read `conductor/tracks/ability-system_20260716/spec.md`
    - [ ] Read `conductor/workflow.md`

- [ ] Task: Create `ability_system.gd` and implement DAMAGE + HEAL
    - [ ] Write failing test: DAMAGE reduces target HP by `params["amount"] * source.combat_state.attack`
    - [ ] Write failing test: HEAL increases HP, capped at max_hp (existing `heal()` handles cap)
    - [ ] Implement: Create `scripts/systems/ability_system.gd` as static class, `execute_effect()` with match statement, DAMAGE and HEAL branches
    - [ ] Verify: tests pass

- [ ] Task: Implement BUFF_STAT + DEBUFF_STAT
    - [ ] Write failing test: BUFF_STAT creates ActiveEffect with positive amount, visible in `effect_component.active_effects`
    - [ ] Write failing test: DEBUFF_STAT creates ActiveEffect with negative amount, `source_id` matches `current_ability_id`
    - [ ] Implement: BUFF_STAT and DEBUFF_STAT branches — create ActiveEffect, add via `target.effect_component.add_effect()`
    - [ ] Verify: tests pass

- [ ] Task: Implement SHIELD + CLEANSE
    - [ ] Write failing test: SHIELD creates ActiveEffect with `effect_type=SHIELD`, amount from params, added to effect_component
    - [ ] Write failing test: CLEANSE calls `target.effect_component.cleanse()`, removes all DEBUFF_STAT effects but leaves BUFF_STAT and SHIELD intact
    - [ ] Implement: SHIELD and CLEANSE branches
    - [ ] Verify: tests pass

- [ ] Task: Implement REVIVE + ENRAGE
    - [ ] Write failing test: REVIVE sets `is_dead=false`, `current_hp = max_hp * params["hp_percent"]` on dead target; no effect on living
    - [ ] Write failing test: ENRAGE calls `target.ai_controller.enter_berserk()`, overrides `berserk_timer` to `params["duration"]`
    - [ ] Implement: REVIVE and ENRAGE branches
    - [ ] Verify: tests pass

- [ ] Task: Implement REPOSITION + STAT_MUTATION + RANDOM_EFFECT
    - [ ] Write failing test: REPOSITION displaces target by `params["distance"]` pixels along source-to-target direction vector
    - [ ] Write failing test: REPOSITION with SELF targeting pushes along source-to-nearest-enemy direction
    - [ ] Write failing test: STAT_MUTATION permanently modifies `combat_state` stat (e.g., attack += amount), no ActiveEffect created, not removable by cleanse
    - [ ] Write failing test: RANDOM_EFFECT picks a random effect from the ability's `effects` array (excluding itself) and executes it with same source/targets
    - [ ] Implement: REPOSITION, STAT_MUTATION, RANDOM_EFFECT branches. RANDOM_EFFECT requires passing the parent ability's effects array.
    - [ ] Verify: all 11 effect types tested, coverage >=80%

- [ ] Task: Conductor - User Manual Verification 'Phase 2: AbilitySystem Static Class' (Protocol in workflow.md)

## Phase 3: Integration — Target Resolution & Execution

Focus: Wire AbilityComponent to AbilitySystem via `execute_ability()`, implement target resolution, and update all callers.

- [ ] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [ ] Read `conductor/tracks/ability-system_20260716/spec.md`
    - [ ] Read `conductor/workflow.md`

- [ ] Task: Implement target resolution in AbilityComponent
    - [ ] Write failing test: `"SELF"` targeting returns `[source_entity]`
    - [ ] Write failing test: `"TARGET"` targeting returns `[primary_target]`
    - [ ] Write failing test: `"AOE_ENEMIES"` returns all living enemies within `ability.range` of primary_target
    - [ ] Write failing test: `"AOE_ALLIES"` returns all living allies within `ability.range` of primary_target
    - [ ] Write failing test: `"ALL_ENEMIES"` returns all living enemies regardless of range
    - [ ] Implement: `_resolve_targets(targeting: String, primary_target: ChimeraEntity) -> Array[ChimeraEntity]` using `combat_context`
    - [ ] Verify: all tests pass

- [ ] Task: Implement `execute_ability(ability, primary_target)`
    - [ ] Write failing test: execute_ability sets `current_ability_id`, sets `cooldowns[ability.id] = ability.cooldown`, calls `AbilitySystem.execute_effect()` for each effect
    - [ ] Write failing test: execute_ability with multiple effects executes all of them
    - [ ] Implement: `execute_ability()` — sets current_ability_id, sets cooldown, resolves targets, iterates effects calling AbilitySystem
    - [ ] Verify: tests pass, coverage >=80%

- [ ] Task: Update ChimeraEntity and UseAbilityState callers
    - [ ] Write failing test: ChimeraEntity._process() calls `ability_component.update_cooldowns(delta)` (verify cooldown decrements over frames)
    - [ ] Update `chimera_entity.gd` `_process()`: add `ability_component.update_cooldowns(delta)` call
    - [ ] Update `use_ability_state.gd`: change `execute_ability(ability.id)` to `execute_ability(ability, target)`
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`

- [ ] Task: Conductor - User Manual Verification 'Phase 3: Integration' (Protocol in workflow.md)

## Phase 4: Passives & SHIELD Damage Absorption

Focus: Implement passive ability application at combat start, verify berserk persistence, and add SHIELD damage absorption to EffectComponent.

- [ ] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [ ] Read `conductor/tracks/ability-system_20260716/spec.md`
    - [ ] Read `conductor/workflow.md`

- [ ] Task: Implement `apply_passives(combat_state)`
    - [ ] Write failing test: apply_passives modifies CombatState snapshot (e.g., passive that buffs attack increases `combat_state.attack`)
    - [ ] Write failing test: apply_passives only processes abilities where `type == PASSIVE`
    - [ ] Write failing test: passive effects persist when `is_berserk == true` (passive stat modifiers still apply during berserk)
    - [ ] Implement: `apply_passives()` iterates PASSIVE abilities, calls `AbilitySystem.execute_effect()` with source=self, targets=[self]
    - [ ] Verify: tests pass, coverage >=80%

- [ ] Task: Implement `EffectComponent.absorb_damage()` and integrate into damage flow
    - [ ] Write failing test: `absorb_damage(amount)` reduces SHIELD ActiveEffect amounts, returns remaining damage after shields consumed
    - [ ] Write failing test: `absorb_damage()` removes shields that reach 0 amount
    - [ ] Write failing test: `absorb_damage()` with no shields returns full amount unchanged
    - [ ] Write failing test: SHIELD effects are NOT removed by `cleanse()` (only DEBUFF_STAT removed)
    - [ ] Implement: `absorb_damage(amount: float) -> float` on EffectComponent — iterates SHIELD effects, reduces amounts, removes depleted shields
    - [ ] Integrate into damage flow: update `CombatState.take_damage()` or `ChimeraEntity.calculate_damage()` to call `absorb_damage()` before HP reduction
    - [ ] Verify: all tests pass, `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`

- [ ] Task: Conductor - User Manual Verification 'Phase 4: Passives & SHIELD Damage Absorption' (Protocol in workflow.md)
</protect>
