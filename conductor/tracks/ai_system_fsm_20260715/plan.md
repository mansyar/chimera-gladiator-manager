<protect>
# Implementation Plan: AI System (FSM)

## Phase 1: Foundation & FSM Framework

- [x] Task: Read spec.md and workflow.md to refresh context for Phase 1
    - [x] Read `conductor/tracks/ai_system_fsm_20260715/spec.md` (FRs, acceptance criteria)
    - [x] Read `conductor/workflow.md` (TDD rules, Phase Completion Verification Protocol)

- [x] Task: Move AIController to scripts/ai/ and create AIState base class [e82dd42]
    - [x] Move `scripts/combat/ai_controller.gd` to `scripts/ai/ai_controller.gd` (update class_name, keep stub signatures)
    - [x] Update `chimera_entity.tscn` to reference new AIController script path
    - [x] Create `scripts/ai/ai_state.gd` — AIState base class with virtual `enter()`, `update(delta)`, `exit()` and `ai_controller` reference
    - [x] Write tests for AIState base class (virtual method calls, ai_controller reference)
    - [x] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [x] Commit: `refactor(ai): Move AIController to scripts/ai/, create AIState base class`
    - [x] Attach git note with task summary
    - [x] Update plan.md: mark task complete with commit SHA

- [x] Task: Create CombatContext entity registry [2802eec]
    - [x] Write failing tests for CombatContext: register_entity, unregister_entity, get_enemies_of (filters by team, excludes dead), get_allies_of (filters by team, excludes dead)
    - [x] Create `scripts/combat/combat_context.gd` (RefCounted) with entities array, register/unregister/get_enemies_of/get_allies_of
    - [x] Run tests — confirm green
    - [x] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [x] Commit: `feat(combat): Create CombatContext entity registry`
    - [x] Attach git note with task summary
    - [x] Update plan.md: mark task complete with commit SHA

- [x] Task: Adjust AbilityComponent stub interface for AI integration [e1c250f]
    - [x] Write failing tests for new stub interface: is_off_cooldown(AbilityData) returns false, get_next_ready_ability(priority) returns null
    - [x] Update `scripts/combat/ability_component.gd`: change is_off_cooldown to accept AbilityData, add get_next_ready_ability(priority: Array) -> AbilityData
    - [x] Run tests — confirm green
    - [x] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [x] Commit: `refactor(combat): Adjust AbilityComponent stub interface for AI`
    - [x] Attach git note with task summary
    - [x] Update plan.md: mark task complete with commit SHA

- [x] Task: Update ChimeraEntity with AI/AbilityComponent/CombatContext references [eb91018]
    - [ ] Write failing tests for ChimeraEntity: ai_controller @onready reference, ability_component @onready reference, team property, combat_context property, died signal
    - [ ] Add to `scripts/combat/chimera_entity.gd`: @onready ai_controller, @onready ability_component, var team, var combat_context, signal died(entity)
    - [ ] Run tests — confirm green
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [ ] Commit: `feat(combat): Add AI/AbilityComponent/CombatContext references to ChimeraEntity`
    - [ ] Attach git note with task summary
    - [ ] Update plan.md: mark task complete with commit SHA

- [x] Task: Implement AIController FSM core (states dictionary, change_state, _process, setup_ai) [0ea823a]
    - [ ] Write failing tests for AIController: setup_ai sets behavior_module/combat_state/combat_context, change_state calls exit/enter, _process delegates to current_state.update, initial state is IDLE
    - [ ] Implement `scripts/ai/ai_controller.gd`: fields (current_state, behavior_module, combat_state, target, states dict, entity @onready), setup_ai(), change_state(), _process() (delegates to state + ticks berserk check stub)
    - [ ] Run tests — confirm green
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [ ] Commit: `feat(ai): Implement AIController FSM core with state management`
    - [ ] Attach git note with task summary
    - [ ] Update plan.md: mark task complete with commit SHA

- [ ] Task: Create 8 state scripts with transition logic
    - [ ] Write failing tests for FSM transition flow: IDLE->ACQUIRE_TARGET, ACQUIRE_TARGET null target->IDLE, ACQUIRE_TARGET found->MOVE_TO_TARGET, MOVE_TO_TARGET in range->IN_RANGE, IN_RANGE ability ready->USE_ABILITY, IN_RANGE no ability->ATTACK, ATTACK target dead->ACQUIRE_TARGET, ATTACK target alive->IN_RANGE, USE_ABILITY->ATTACK, BERSERK timer expired->ACQUIRE_TARGET, DEAD is terminal
    - [ ] Create `scripts/ai/states/idle_state.gd` — brief pause then ->ACQUIRE_TARGET
    - [ ] Create `scripts/ai/states/acquire_target_state.gd` — calls acquire_target(), ->MOVE_TO_TARGET or ->IDLE
    - [ ] Create `scripts/ai/states/move_to_target_state.gd` — calls move_toward_target(get_move_position()), ->IN_RANGE when in range
    - [ ] Create `scripts/ai/states/in_range_state.gd` — checks get_next_ready_ability(), ->USE_ABILITY or ->ATTACK
    - [ ] Create `scripts/ai/states/attack_state.gd` — executes attack, resets timer, ->ACQUIRE_TARGET or ->IN_RANGE
    - [ ] Create `scripts/ai/states/use_ability_state.gd` — delegates to AbilityComponent stub, ->ATTACK or ->ACQUIRE_TARGET
    - [ ] Create `scripts/ai/states/berserk_state.gd` — decrements berserk_timer, ->ACQUIRE_TARGET when expired
    - [ ] Create `scripts/ai/states/dead_state.gd` — terminal, no transitions
    - [ ] Run tests — confirm green
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [ ] Commit: `feat(ai): Implement 8 FSM state scripts with transition logic`
    - [ ] Attach git note with task summary
    - [ ] Update plan.md: mark task complete with commit SHA

- [ ] Task: Conductor - User Manual Verification 'Phase 1: Foundation & FSM Framework' (Protocol in workflow.md)

## Phase 2: Positioning & Targeting

- [ ] Task: Read spec.md and workflow.md to refresh context for Phase 2
    - [ ] Read `conductor/tracks/ai_system_fsm_20260715/spec.md` (FR-5, FR-6, acceptance criteria)
    - [ ] Read `conductor/workflow.md` (TDD rules, Phase Completion Verification Protocol)

- [ ] Task: Implement get_move_position() with 3 positioning modes
    - [ ] Write failing tests: FRONT melee returns target position, FRONT ranged kites away when too close, MID ranged holds at range, MID melee approaches, BACK ranged flees when approached, BACK ranged holds when safe, BACK melee holds if front-line allies exist, BACK melee approaches if no front-line allies
    - [ ] Implement `get_move_position(target: ChimeraEntity) -> Vector2` on AIController with FRONT/MID/BACK logic, melee/ranged distinction via MELEE_THRESHOLD, has_front_line_allies() helper
    - [ ] Run tests — confirm green
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [ ] Commit: `feat(ai): Implement positioning behavior with 3 modes and melee/ranged logic`
    - [ ] Attach git note with task summary
    - [ ] Update plan.md: mark task complete with commit SHA

- [ ] Task: Implement 6 targeting functions
    - [ ] Write failing tests: find_nearest returns closest, find_lowest_hp_in_range returns lowest HP in range, find_highest_attack returns highest attack, find_highest_attack_targeting_ally returns highest-attack enemy targeting ally, find_enemy_attacking_ally returns enemy attacking any ally, find_lowest_hp returns lowest HP overall, all return null for empty list
    - [ ] Implement 6 targeting functions on AIController, wire acquire_target() to dispatch via behavior_module.targeting match
    - [ ] Run tests — confirm green
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [ ] Commit: `feat(ai): Implement 6 targeting functions and acquire_target dispatch`
    - [ ] Attach git note with task summary
    - [ ] Update plan.md: mark task complete with commit SHA

- [ ] Task: Conductor - User Manual Verification 'Phase 2: Positioning & Targeting' (Protocol in workflow.md)

## Phase 3: Ability Priority & Berserk System

- [ ] Task: Read spec.md and workflow.md to refresh context for Phase 3
    - [ ] Read `conductor/tracks/ai_system_fsm_20260715/spec.md` (FR-7, FR-8, acceptance criteria)
    - [ ] Read `conductor/workflow.md` (TDD rules, Phase Completion Verification Protocol)

- [ ] Task: Implement get_next_ready_ability() with priority ordering
    - [ ] Write failing tests: returns first off-cooldown ability in priority order, returns null when none ready, respects behavior_module.ability_priority ordering, checks part_abilities + combo_ability
    - [ ] Implement `get_next_ready_ability() -> AbilityData` on AIController — iterates ability_priority, delegates to AbilityComponent.get_next_ready_ability(priority)
    - [ ] Run tests — confirm green
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [ ] Commit: `feat(ai): Implement ability priority ordering via get_next_ready_ability`
    - [ ] Attach git note with task summary
    - [ ] Update plan.md: mark task complete with commit SHA

- [ ] Task: Implement berserk check system (timer, probability, modifiers)
    - [ ] Write failing tests: purebreds never berserk (instability=0), base probabilities match GDD (STABLE=3%, VOLATILE=8%, CHAOTIC=15%), berserk_check_timer accumulates and triggers roll at 5.0s, event modifiers accumulate in dict, modifiers cleared after roll, HP<30% adds +0.15, disruption adds +0.10, killing blow adds +0.05, chance = base + sum(modifiers)
    - [ ] Implement `check_berserk(delta: float) -> void` on AIController — early return for purebreds, timer accumulation, probability calculation, modifier accumulation/reset, enter_berserk() call
    - [ ] Implement event modifier helper methods: on_hp_low(), on_disrupted(), on_killing_blow(), on_ally_death() (immediate roll)
    - [ ] Run tests — confirm green
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [ ] Commit: `feat(ai): Implement berserk check with timer, probability, and event modifiers`
    - [ ] Attach git note with task summary
    - [ ] Update plan.md: mark task complete with commit SHA

- [ ] Task: Implement enter_berserk() and berserk state lifecycle
    - [ ] Write failing tests: enter_berserk sets is_berserk=true, sets berserk_timer=BERSERK_DURATION, changes state to BERSERK, emits EventBus.berserk_triggered; BERSERK state decrements timer, transitions to ACQUIRE_TARGET at 0, sets is_berserk=false on exit; BERSERK_DURATION constant = 5.0; ally death triggers immediate roll with accumulated modifiers then clears
    - [ ] Implement `enter_berserk()` on AIController — sets is_berserk, berserk_timer, change_state("BERSERK"), emits signal
    - [ ] Update `scripts/ai/states/berserk_state.gd` — full lifecycle: decrement timer, clear is_berserk, ->ACQUIRE_TARGET on expiry
    - [ ] Run tests — confirm green
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`
    - [ ] Commit: `feat(ai): Implement berserk state lifecycle with 5s duration and signal emission`
    - [ ] Attach git note with task summary
    - [ ] Update plan.md: mark task complete with commit SHA

- [ ] Task: Conductor - User Manual Verification 'Phase 3: Ability Priority & Berserk System' (Protocol in workflow.md)
</protect>
