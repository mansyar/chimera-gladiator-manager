<protect>
# Track Specification: AI System (FSM)

## Overview

Implement the combat AI Finite State Machine (FSM) for ChimeraEntity. Each chimera in combat is driven by an AIController node running a configurable state machine. The behavior module (from the HEAD part) provides targeting mode, ability priority ordering, and positioning tendency parameters. The FSM governs target acquisition, movement, attack cadence, ability usage, and the berserk override state.

This track builds on the TRACK-005 combat entity foundation (movement, damage resolution, attack cadence) and prepares the AI layer that TRACK-007 (Ability System) and TRACK-008 (CombatManager) will integrate with.

## Context Anchors

- **GDD Reference:** Section 2.4 (Behavior Modules — 7 modules table with targeting/priority/positioning; Targeting Definitions — 6 terms; Berserk — 5s duration, check every 5s, event modifiers, base probabilities, effects)
- **TDD Reference:** Section 7 (AI System — FSM architecture, state flow, positioning behavior code, target selection code, ability priority code, berserk state code)
- **Dependencies:** TRACK-005 (Combat Entity & Arena Foundation — complete)

## Functional Requirements

### FR-1: File Organization
- Move `AIController` from `scripts/combat/ai_controller.gd` to `scripts/ai/ai_controller.gd` (matches TDD Section 2 directory structure).
- Create `scripts/ai/ai_state.gd` — base state class with virtual methods `enter()`, `update(delta)`, `exit()`.
- Create 8 state scripts in `scripts/ai/states/`: `idle_state.gd`, `acquire_target_state.gd`, `move_to_target_state.gd`, `in_range_state.gd`, `attack_state.gd`, `use_ability_state.gd`, `berserk_state.gd`, `dead_state.gd`.
- Update `chimera_entity.tscn` to reference the new AIController path.

### FR-2: AIController Node
- Fields: `current_state: AIState`, `behavior_module: BehaviorModuleData`, `combat_state: CombatState`, `target: ChimeraEntity`, `states: Dictionary` (state_name → AIState instance).
- Reference to parent ChimeraEntity (via `@onready var entity: ChimeraEntity = get_parent()`).
- Reference to `combat_context: CombatContext` (set externally by the arena/match setup).
- Methods:
  - `change_state(new_state: String) -> void` — calls `current_state.exit()`, swaps, calls `new_state.enter()`.
  - `acquire_target() -> ChimeraEntity` — delegates to the targeting function specified by `behavior_module.targeting`.
  - `_process(delta: float) -> void` — calls `current_state.update(delta)`, ticks berserk check.
  - `get_move_position(target: ChimeraEntity) -> Vector2` — positioning logic (see FR-5).
  - `get_next_ready_ability() -> AbilityData` — delegates to AbilityComponent (see FR-6).

### FR-3: AIState Base Class
- Virtual methods: `enter() -> void`, `update(delta: float) -> void`, `exit() -> void`.
- Reference to `ai_controller: AIController` (set on instantiation).
- Each state script extends AIState and implements the transition logic for its state.

### FR-4: State Flow (8 States)

| State | Behavior | Transitions |
|-------|----------|-------------|
| **IDLE** | Brief pause (1-2 frames) before action | → ACQUIRE_TARGET |
| **ACQUIRE_TARGET** | Uses `behavior_module.targeting` to find target. If null → IDLE | → MOVE_TO_TARGET (target found) → IDLE (no target) |
| **MOVE_TO_TARGET** | Moves toward/away from target via `get_move_position()` | → IN_RANGE (when within attack_range) |
| **IN_RANGE** | Checks ability cooldowns by priority via `get_next_ready_ability()` | → USE_ABILITY (ability ready) → ATTACK (no ability ready) |
| **ATTACK** | Executes auto-attack via ChimeraEntity, resets attack timer | → ACQUIRE_TARGET (target dead/gone) → IN_RANGE (target alive) |
| **USE_ABILITY** | Executes highest-priority off-cooldown ability (delegates to AbilityComponent stub) | → ATTACK or → ACQUIRE_TARGET |
| **BERSERK** | Override — ignores module, targets nearest entity, +50% atk, -30% def. Lasts `BERSERK_DURATION` seconds | → ACQUIRE_TARGET (after duration expires) |
| **DEAD** | Stops all processing | terminal |

- BERSERK can trigger from any non-DEAD state (checked every frame in AIController._process).
- Initial state: IDLE.

### FR-5: Positioning Behavior
- `get_move_position(target: ChimeraEntity) -> Vector2` implements 3 positioning modes:
  - **FRONT**: Melee closes distance. Ranged kites (maintains distance, moves away if too close).
  - **MID**: Ranged holds at attack range. Melee approaches.
  - **BACK**: Ranged flees if approached, otherwise holds. Melee holds if front-line allies exist, otherwise approaches.
- Uses `MELEE_THRESHOLD` (48.0px, already on ChimeraEntity) to distinguish melee vs ranged.
- Per-module positioning tendencies match GDD Section 2.4 table.

### FR-6: Target Selection (6 Functions)
- `find_nearest(enemies) -> ChimeraEntity` — closest by distance.
- `find_lowest_hp_in_range(enemies, range) -> ChimeraEntity` — lowest current HP among enemies within attack_range.
- `find_highest_attack(enemies) -> ChimeraEntity` — highest current Attack stat.
- `find_highest_attack_targeting_ally(enemies) -> ChimeraEntity` — highest-Attack enemy currently targeting an ally.
- `find_enemy_attacking_ally(enemies) -> ChimeraEntity` — enemy currently dealing damage to any ally.
- `find_lowest_hp(enemies) -> ChimeraEntity` — lowest current HP (Stalker moves to reach them).
- All return null if no valid target.

### FR-7: Ability Priority
- `get_next_ready_ability() -> AbilityData` iterates `behavior_module.ability_priority` (Array[AbilityCategory]), checks each ability's category and cooldown via AbilityComponent.
- Returns the first off-cooldown ability matching the current priority category. Returns null if none ready.
- Delegates cooldown checking to AbilityComponent stub (interface adjusted — see FR-9).

### FR-8: Berserk System
- `check_berserk(delta: float) -> void` — called every frame from AIController._process.
- Purebreds (instability == 0) are immune — function returns immediately.
- `berserk_check_timer` accumulates delta. Every 5.0 seconds, rolls:
  - `chance = base_probability + sum(berserk_modifiers.values())`
  - Base: PURE=0%, STABLE=3%, VOLATILE=8%, CHAOTIC=15%.
  - If `randf() < chance` → `enter_berserk()`.
  - Modifiers cleared after roll regardless of outcome.
- Event modifiers accumulate in `combat_state.berserk_modifiers` Dictionary:
  - HP drops below 30%: +0.15 (checked when HP crosses threshold).
  - Hit by disruption ability: +0.10.
  - Landing a killing blow: +0.05.
- Ally death triggers an **immediate** berserk roll (separate from the 5s timer), using accumulated modifiers + base. Modifiers cleared after this roll too.
- `enter_berserk()`:
  - Sets `combat_state.is_berserk = true`.
  - Sets `combat_state.berserk_timer = BERSERK_DURATION`.
  - Overrides to BERSERK state via `change_state("BERSERK")`.
  - Emits `EventBus.berserk_triggered(chimera_data)`.
- BERSERK state `update(delta)`: decrements `berserk_timer`. When it reaches 0:
  - Sets `is_berserk = false`.
  - Transitions to ACQUIRE_TARGET (re-evaluates, does NOT restore previous state).
- `BERSERK_DURATION` is a constant (5.0) that can be overridden later by TRACK-016's research node.

### FR-9: AbilityComponent Stub Interface Adjustment
- Change `is_off_cooldown(_ability_id: String) -> bool` to `is_off_cooldown(ability: AbilityData) -> bool`.
- Add `get_next_ready_ability(priority: Array) -> AbilityData` — iterates abilities in priority order, returns first off-cooldown.
- Update existing stub body to match new signatures. Implementation remains stub (TRACK-007).

### FR-10: CombatContext (New Class)
- Create `scripts/combat/combat_context.gd` (RefCounted).
- Minimal entity registry:
  - `entities: Array[ChimeraEntity]` — all registered combat entities.
  - `register_entity(entity: ChimeraEntity) -> void`.
  - `unregister_entity(entity: ChimeraEntity) -> void`.
  - `get_enemies_of(team: int) -> Array[ChimeraEntity]` — entities where `team != given team` and `not is_dead`.
  - `get_allies_of(team: int) -> Array[ChimeraEntity]` — entities where `team == given team` and `not is_dead`.
- TRACK-008's CombatManager will hold and populate this context.

### FR-11: ChimeraEntity Integration
- Add `@onready var ai_controller: AIController` reference.
- Add `@onready var ability_component: AbilityComponent` reference.
- Add `var team: int` property (mirrors `combat_state.team` for convenient access by AI/targeting).
- Add `var combat_context: CombatContext` reference (set externally by arena/match setup).
- Add signal `died(entity: ChimeraEntity)` for ally-death berserk trigger.
- Wire AIController to receive `combat_context` and `behavior_module` during match setup (stub method `setup_ai(behavior_module, combat_state, combat_context)` on AIController).

## Non-Functional Requirements

- **NFR-1:** All GDScript files must pass `gd-tools lint` (exit 0).
- **NFR-2:** All GDScript files must pass `gd-tools format --check` (exit 0).
- **NFR-3:** Test coverage >= 80% for all new source files with testable logic.
- **NFR-4:** Strict typing enforced (all variables, parameters, return types typed).
- **NFR-5:** All public functions documented with `##` doc comments.
- **NFR-6:** FSM matches TDD Section 7 state flow diagram.
- **NFR-7:** Positioning tendencies match GDD Section 2.4 table.
- **NFR-8:** Berserk probabilities and modifiers match GDD Section 2.4 exactly.

## Acceptance Criteria

1. **FSM Transitions:** IDLE -> ACQUIRE_TARGET -> MOVE_TO_TARGET -> IN_RANGE -> ATTACK/USE_ABILITY cycle works correctly. ACQUIRE_TARGET returns null -> IDLE when no enemies.
2. **Positioning:** `get_move_position()` returns correct positions for FRONT melee, FRONT ranged (kite), MID ranged (hold), BACK ranged (flee), BACK melee (hold if allies in front).
3. **Targeting:** All 6 targeting functions return the correct entity from a set of candidates.
4. **Berserk Probability:** Base probabilities match GDD table (0/3/8/15%). Event modifiers accumulate and reset after roll. Purebreds never berserk.
5. **Berserk Duration:** BERSERK state lasts exactly BERSERK_DURATION (5.0s), then transitions to ACQUIRE_TARGET.
6. **Berserk Effects:** `is_berserk = true` during BERSERK state. Damage calculation (already in ChimeraEntity) applies +50% atk / -30% def.
7. **Ability Priority:** `get_next_ready_ability()` respects `behavior_module.ability_priority` ordering.
8. **Ally Death:** Triggers immediate berserk roll with accumulated modifiers.
9. **CombatContext:** `get_enemies_of()` and `get_allies_of()` return correct filtered lists.
10. **File Organization:** AIController and all state scripts in `scripts/ai/`. CombatContext in `scripts/combat/`.

## Out of Scope

- Ability execution engine (USE_ABILITY delegates to AbilityComponent stub — TRACK-007).
- CombatManager match lifecycle and win condition (TRACK-008).
- Visual berserk indicators / VFX (TRACK-014).
- Research node integration for berserk duration reduction (TRACK-016).
- Enemy generation logic (TRACK-008).
- Pre-match formation grid UI (TRACK-013).
- NavigationAgent2D pathfinding (arena is open field — direct movement only).
</protect>
