<protect>
# Implementation Plan: TRACK-007 — Ability & Effect System

## Phase 1: AbilityComponent Foundation [checkpoint: 02211ea]

Focus: Replace the TRACK-005 stub with a working AbilityComponent — initialization, cooldown tracking, and ready-ability querying.

- [x] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [x] Read `conductor/tracks/ability-system_20260716/spec.md`
    - [x] Read `conductor/workflow.md`

- [x] Task: Remove unused stub and add `current_ability_id` property [5a6142d]
    - [x] Remove `get_next_ready_ability(_priority: Array)` stub method (AIController has its own; this is dead code)
    - [x] Add `var current_ability_id: String` property to AbilityComponent (for ActiveEffect source tracking per TDD)
    - [x] Add `var abilities: Array[AbilityData] = []` and `var cooldowns: Dictionary = {}` properties
    - [x] Verify: `gd-tools lint` passes with no unused function warnings

- [x] Task: Implement `initialize(combat_state: CombatState)` [5a6142d]
    - [x] Write failing tests: test that initialize populates `abilities` from `chimera_data.part_abilities`, adds combo ability via `get_combo_ability()`, initializes `cooldowns` dict with all ability IDs set to 0.0
    - [x] Write failing test: test that combo ability is null when all 4 parts are different strains (all-different case)
    - [x] Implement: `initialize()` collects part abilities + combo, populates cooldowns dict, calls `apply_passives(combat_state)`
    - [x] Verify: all tests pass, `gd-tools test --coverage --min 80`

- [x] Task: Implement cooldown management methods [5a6142d]
    - [x] Write failing test: `is_off_cooldown()` returns true for fresh ability (cooldown 0.0), false after `execute_ability()` sets cooldown
    - [x] Write failing test: `is_off_cooldown()` returns true after cooldown expires via `update_cooldowns(delta)`
    - [x] Write failing test: `update_cooldowns(delta)` decrements all cooldowns, floors at 0.0
    - [x] Write failing test: `get_ready_abilities()` returns only ACTIVE-type abilities (not PASSIVE) that are off cooldown
    - [x] Implement: `is_off_cooldown(ability)`, `update_cooldowns(delta)`, `get_ready_abilities()`
    - [x] Verify: all tests pass, coverage >=80%

- [ ] Task: Conductor - User Manual Verification 'Phase 1: AbilityComponent Foundation' (Protocol in workflow.md)

## Phase 2: AbilitySystem Static Class — All 11 Effect Types [checkpoint: f452fa6]

Focus: Create the `AbilitySystem` static utility class with `execute_effect()` handling all 11 EffectType variants.

- [x] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [x] Read `conductor/tracks/ability-system_20260716/spec.md`
    - [x] Read `conductor/workflow.md`

- [x] Task: Create `ability_system.gd` and implement DAMAGE + HEAL [e37d97b]
    - [x] Write failing test: DAMAGE reduces target HP by `params["amount"] * source.combat_state.attack`
    - [x] Write failing test: HEAL increases HP, capped at max_hp (existing `heal()` handles cap)
    - [x] Implement: Create `scripts/systems/ability_system.gd` as static class, `execute_effect()` with match statement, DAMAGE and HEAL branches
    - [x] Verify: tests pass

- [x] Task: Implement BUFF_STAT + DEBUFF_STAT [e37d97b]
    - [x] Write failing test: BUFF_STAT creates ActiveEffect with positive amount, visible in `effect_component.active_effects`
    - [x] Write failing test: DEBUFF_STAT creates ActiveEffect with negative amount, `source_id` matches `current_ability_id`
    - [x] Implement: BUFF_STAT and DEBUFF_STAT branches — create ActiveEffect, add via `target.effect_component.add_effect()`
    - [x] Verify: tests pass

- [x] Task: Implement SHIELD + CLEANSE [e37d97b]
    - [x] Write failing test: SHIELD creates ActiveEffect with `effect_type=SHIELD`, amount from params, added to effect_component
    - [x] Write failing test: CLEANSE calls `target.effect_component.cleanse()`, removes all DEBUFF_STAT effects but leaves BUFF_STAT and SHIELD intact
    - [x] Implement: SHIELD and CLEANSE branches
    - [x] Verify: tests pass

- [x] Task: Implement REVIVE + ENRAGE [e37d97b]
    - [x] Write failing test: REVIVE sets `is_dead=false`, `current_hp = max_hp * params["hp_percent"]` on dead target; no effect on living
    - [x] Write failing test: ENRAGE calls `target.ai_controller.enter_berserk()`, overrides `berserk_timer` to `params["duration"]`
    - [x] Implement: REVIVE and ENRAGE branches
    - [x] Verify: tests pass

- [x] Task: Implement REPOSITION + STAT_MUTATION + RANDOM_EFFECT [e37d97b]
    - [x] Write failing test: REPOSITION displaces target by `params["distance"]` pixels along source-to-target direction vector
    - [x] Write failing test: REPOSITION with SELF targeting pushes along source-to-nearest-enemy direction
    - [x] Write failing test: STAT_MUTATION permanently modifies `combat_state` stat (e.g., attack += amount), no ActiveEffect created, not removable by cleanse
    - [x] Write failing test: RANDOM_EFFECT picks a random effect from the ability's `effects` array (excluding itself) and executes it with same source/targets
    - [x] Implement: REPOSITION, STAT_MUTATION, RANDOM_EFFECT branches. RANDOM_EFFECT requires passing the parent ability's effects array.
    - [x] Verify: all 11 effect types tested, coverage >=80%

- [ ] Task: Conductor - User Manual Verification 'Phase 2: AbilitySystem Static Class' (Protocol in workflow.md)

## Phase 3: Integration — Target Resolution & Execution [checkpoint: c355918]

Focus: Wire AbilityComponent to AbilitySystem via `execute_ability()`, implement target resolution, and update all callers.

- [x] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [x] Read `conductor/tracks/ability-system_20260716/spec.md`
    - [x] Read `conductor/workflow.md`

- [x] Task: Implement target resolution in AbilityComponent [34040f0]
    - [x] Write failing test: `"SELF"` targeting returns `[source_entity]`
    - [x] Write failing test: `"TARGET"` targeting returns `[primary_target]`
    - [x] Write failing test: `"AOE_ENEMIES"` returns all living enemies within `ability.range` of primary_target
    - [x] Write failing test: `"AOE_ALLIES"` returns all living allies within `ability.range` of primary_target
    - [x] Write failing test: `"ALL_ENEMIES"` returns all living enemies regardless of range
    - [x] Implement: `_resolve_targets(targeting: String, primary_target: ChimeraEntity) -> Array[ChimeraEntity]` using `combat_context`
    - [x] Verify: all tests pass

- [x] Task: Implement `execute_ability(ability, primary_target)` [34040f0]
    - [x] Write failing test: execute_ability sets `current_ability_id`, sets `cooldowns[ability.id] = ability.cooldown`, calls `AbilitySystem.execute_effect()` for each effect
    - [x] Write failing test: execute_ability with multiple effects executes all of them
    - [x] Implement: `execute_ability()` — sets current_ability_id, sets cooldown, resolves targets, iterates effects calling AbilitySystem
    - [x] Verify: tests pass, coverage >=80%

- [x] Task: Update ChimeraEntity and UseAbilityState callers [34040f0]
    - [x] Write failing test: ChimeraEntity._process() calls `ability_component.update_cooldowns(delta)` (verify cooldown decrements over frames)
    - [x] Update `chimera_entity.gd` `_process()`: add `ability_component.update_cooldowns(delta)` call
    - [x] Update `use_ability_state.gd`: change `execute_ability(ability.id)` to `execute_ability(ability, target)`
    - [x] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`

- [x] Task: Conductor - User Manual Verification 'Phase 3: Integration' (Protocol in workflow.md)

## Phase 4: Passives & SHIELD Damage Absorption

Focus: Implement passive ability application at combat start, verify berserk persistence, and add SHIELD damage absorption to EffectComponent.

- [x] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [x] Read `conductor/tracks/ability-system_20260716/spec.md`
    - [x] Read `conductor/workflow.md`

- [x] Task: Implement `apply_passives(combat_state)` [ad8e42e]
    - [x] Write failing test: apply_passives modifies CombatState snapshot (e.g., passive that buffs attack increases `combat_state.attack`)
    - [x] Write failing test: apply_passives only processes abilities where `type == PASSIVE`
    - [x] Write failing test: passive effects persist when `is_berserk == true` (passive stat modifiers still apply during berserk)
    - [x] Implement: `apply_passives()` iterates PASSIVE abilities, calls `AbilitySystem.execute_effect()` with source=self, targets=[self]
    - [x] Verify: tests pass, coverage >=80%

- [~] Task: Implement `EffectComponent.absorb_damage()` and integrate into damage flow
    - [ ] Write failing test: `absorb_damage(amount)` reduces SHIELD ActiveEffect amounts, returns remaining damage after shields consumed
    - [ ] Write failing test: `absorb_damage()` removes shields that reach 0 amount
    - [ ] Write failing test: `absorb_damage()` with no shields returns full amount unchanged
    - [ ] Write failing test: SHIELD effects are NOT removed by `cleanse()` (only DEBUFF_STAT removed)
    - [ ] Implement: `absorb_damage(amount: float) -> float` on EffectComponent — iterates SHIELD effects, reduces amounts, removes depleted shields
    - [ ] Integrate into damage flow: update `CombatState.take_damage()` or `ChimeraEntity.calculate_damage()` to call `absorb_damage()` before HP reduction
    - [ ] Verify: all tests pass, `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`

- [ ] Task: Conductor - User Manual Verification 'Phase 4: Passives & SHIELD Damage Absorption' (Protocol in workflow.md)
</protect>
