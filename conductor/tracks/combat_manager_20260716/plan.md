<protect>
# Implementation Plan: TRACK-008 — Combat Manager & Match Flow

## Phase 1: CombatManager Match Lifecycle

Focus: Transform the CombatManager stub into the central match orchestrator — entity spawning, timer management, win condition evaluation, and match end cleanup.

- [x] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [x] Read the confirmed track specification
    - [x] Read `conductor/workflow.md` TDD and checkpointing protocols

- [x] Task: Implement CombatManager properties and entity container resolution (e2ea334)
    - [x] Write failing test: CombatManager has `match_active`, `timer`, `combat_entities`, `combat_context`, `player_formation`, `enemy_formation`, `match_result` properties
    - [x] Write failing test: `_find_or_create_entities_container()` finds arena Entities node via scene tree group; creates temp Node2D if not found (test mode)
    - [x] Implement: Add all CombatManager properties per TDD Section 4
    - [x] Implement: `_find_or_create_entities_container()` — searches for node in `arena_entities` group, falls back to creating Node2D
    - [x] Verify: `gd-tools lint && gd-tools format --check`

- [x] Task: Implement `start_match()` — entity creation, placement, initialization (8254daa)
    - [x] Write failing test: `start_match()` creates 6 ChimeraEntity instances (3 player team=0, 3 enemy team=1)
    - [x] Write failing test: Each entity has initialized CombatState (HP=max_hp, stats snapshotted from ChimeraData)
    - [x] Write failing test: Each entity placed at correct world position via `ArenaController.grid_to_world()`
    - [x] Write failing test: All entities registered in CombatContext
    - [x] Write failing test: Each entity's `died` signal connected to `_on_entity_died`
    - [x] Write failing test: `match_active` set to true, `timer` set to 60.0
    - [x] Write failing test: `EventBus.match_started` emitted with player_roster and enemy_roster
    - [x] Write failing test: `match_type` and `tournament_tier` stored on CombatManager
    - [x] Implement: `start_match(player_roster, enemy_roster, formations, match_type, tournament_tier)` — instantiate chimera_entity.tscn per chimera, initialize CombatState, apply passives via AbilityComponent, place at grid positions, register in CombatContext, connect signals, set state
    - [x] Verify: all tests pass, `gd-tools test --coverage --min 80`

- [x] Task: Implement `_process()` timer decrement and win condition check (2a01069)
    - [ ] Write failing test: `_process()` returns early when `match_active == false` (idle state)
    - [ ] Write failing test: `_process()` decrements `timer` by delta when active
    - [ ] Write failing test: `_process()` calls `check_win_condition()` every frame when active
    - [ ] Write failing test: When `timer <= 0.0`, `_on_timer_expired()` is called
    - [ ] Implement: `_process(delta)` — early return guard, timer decrement, win condition check, timer expiry trigger
    - [ ] Verify: tests pass

- [x] Task: Implement `check_win_condition()` — all-dead and HP% evaluation (5473784)
    - [ ] Write failing test: Win for player when all enemy entities are dead (is_dead == true)
    - [ ] Write failing test: Win for enemy when all player entities are dead
    - [ ] Write failing test: No win triggered when both sides have alive entities
    - [ ] Write failing test: `check_win_condition()` calls `end_match()` with correct result dict when win condition met
    - [ ] Implement: `check_win_condition()` — count alive per team, trigger end_match on all-dead condition
    - [ ] Verify: tests pass

- [x] Task: Implement `_on_entity_died()` and `_on_timer_expired()` (54e4cdf)
    - [x] Write failing test: `_on_entity_died()` unregisters entity from CombatContext
    - [x] Write failing test: `_on_entity_died()` calls `check_win_condition()` immediately
    - [x] Write failing test: `_on_timer_expired()` calculates total HP% per team, winner = higher HP%
    - [x] Write failing test: `_on_timer_expired()` handles tie (equal HP%) — player wins ties
    - [x] Implement: `_on_entity_died(entity)` — unregister, check win. `_on_timer_expired()` — HP% calc, end_match
    - [x] Verify: tests pass

- [x] Task: Implement `end_match()` — state clear, emit signal (8555301)
    - [x] Write failing test: `end_match()` sets `match_active = false`
    - [x] Write failing test: `end_match()` clears `combat_entities`, `player_formation`, `enemy_formation` arrays
    - [x] Write failing test: `end_match()` clears `CombatContext.entities`
    - [x] Write failing test: `end_match()` frees all spawned ChimeraEntity nodes
    - [x] Write failing test: `end_match()` emits `EventBus.match_ended` with result dictionary containing winner, won, surviving_hp, duration, gold_earned, infamy_earned
    - [x] Implement: `end_match(result)` — set inactive, clear arrays, clear context, free entities, emit match_ended
    - [x] Verify: tests pass, coverage >=80%

- [x] Task: Implement `get_enemies_of()` helper (b2021f0)
    - [x] Write failing test: `get_enemies_of(0)` returns all alive enemy (team=1) entities
    - [x] Write failing test: `get_enemies_of(1)` returns all alive player (team=0) entities
    - [x] Implement: `get_enemies_of(team)` — delegates to `combat_context.get_enemies_of(team)`
    - [x] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`

- [ ] Task: Conductor - User Manual Verification 'Phase 1: CombatManager Match Lifecycle' (Protocol in workflow.md)

## Phase 2: Enemy Generation

Focus: Create `enemy_generator.gd` static utility class with rubber-band difficulty for Regular matches and tier-based scaling for Tournaments.

- [ ] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [ ] Read the confirmed track specification
    - [ ] Read `conductor/workflow.md` TDD and checkpointing protocols

- [ ] Task: Create `enemy_generator.gd` with difficulty tier rarity tables
    - [ ] Write failing test: `EnemyGenerator.DIFFICULTY_WEIGHTS` contains 4 tiers: weak, normal, tough, strong
    - [ ] Write failing test: weak tier weights = {COMMON: 80, UNCOMMON: 18, RARE: 2, LEGENDARY: 0}
    - [ ] Write failing test: normal tier weights = {COMMON: 60, UNCOMMON: 30, RARE: 9, LEGENDARY: 1}
    - [ ] Write failing test: tough tier weights = {COMMON: 45, UNCOMMON: 35, RARE: 18, LEGENDARY: 2}
    - [ ] Write failing test: strong tier weights = {COMMON: 30, UNCOMMON: 40, RARE: 25, LEGENDARY: 5}
    - [ ] Implement: Create `scripts/systems/enemy_generator.gd` as static class with `class_name EnemyGenerator`, define `DIFFICULTY_WEIGHTS` Dictionary constant
    - [ ] Verify: `gd-tools lint && gd-tools format --check`

- [ ] Task: Implement `_get_difficulty_tier()` difficulty selection logic
    - [ ] Write failing test: Regular match with losing_streak < 3 returns "normal"
    - [ ] Write failing test: Regular match with losing_streak >= 3 returns "weak" (rubber-band per GDD 4.6)
    - [ ] Write failing test: Tournament tier 1 returns "tough"
    - [ ] Write failing test: Tournament tier 2 returns "tough"
    - [ ] Write failing test: Tournament tier 3 returns "strong"
    - [ ] Write failing test: Tournament tier 4 returns "strong"
    - [ ] Implement: `_get_difficulty_tier(match_type, losing_streak, tournament_tier) -> String`
    - [ ] Verify: tests pass

- [ ] Task: Implement `_generate_enemy_chimera()` single enemy creation
    - [ ] Write failing test: Generated chimera has 4 parts (head, torso, arms, legs) — all non-null
    - [ ] Write failing test: Each part's slot matches its position (head=HEAD, torso=TORSO, etc.)
    - [ ] Write failing test: Part rarities follow the difficulty tier weight distribution (statistical or spot-check)
    - [ ] Write failing test: `recalculate_stats()` has been called (max_hp, attack, defense, speed are non-zero)
    - [ ] Write failing test: `calculate_instability()` has been called (instability is 0-3)
    - [ ] Implement: `_generate_enemy_chimera(rarity_weights: Dictionary) -> ChimeraData` — generate 4 parts via `PartDatabase.generate_random_part()`, assemble into ChimeraData, recalculate stats
    - [ ] Verify: tests pass

- [ ] Task: Implement `generate_enemy_roster()` public API
    - [ ] Write failing test: Returns array of exactly 3 ChimeraData
    - [ ] Write failing test: Regular match (losing_streak=0) produces enemies with "normal" difficulty parts
    - [ ] Write failing test: Regular match (losing_streak=5) produces weaker enemies ("weak" difficulty — higher common ratio)
    - [ ] Write failing test: Tournament tier 1 produces "tough" enemies
    - [ ] Write failing test: Tournament tier 4 produces "strong" enemies
    - [ ] Implement: `generate_enemy_roster(player_roster, match_type, losing_streak, tournament_tier) -> Array[ChimeraData]` — select difficulty, generate 3 enemies
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`

- [ ] Task: Conductor - User Manual Verification 'Phase 2: Enemy Generation' (Protocol in workflow.md)

## Phase 3: Economy Integration & Post-Match Flow

Focus: Add `GameState.record_match_result()`, wire CombatManager.end_match to calculate rewards via Economy, trigger market refresh and save.

- [ ] Task: Read `spec.md` and `workflow.md` to establish context for this phase
    - [ ] Read the confirmed track specification
    - [ ] Read `conductor/workflow.md` TDD and checkpointing protocols

- [ ] Task: Implement `GameState.record_match_result()`
    - [ ] Write failing test: Winning a match resets `losing_streak` to 0
    - [ ] Write failing test: Losing a match increments `losing_streak` by 1
    - [ ] Write failing test: Appends to `match_history` with `{"result": "win"/"loss", "gold": rewards["gold"]}`
    - [ ] Write failing test: Calls `add_gold(rewards["gold"])` — gold increases by reward amount
    - [ ] Write failing test: Calls `add_infamy(rewards["infamy"])` — infamy increases by reward amount
    - [ ] Write failing test: Calls `refresh_market()` — `EventBus.market_refreshed` emitted
    - [ ] Write failing test: Calls `SaveManager.save_game()` — save triggered
    - [ ] Implement: `record_match_result(won: bool, match_type: String, rewards: Dictionary) -> void` on GameState
    - [ ] Verify: tests pass

- [ ] Task: Wire `end_match()` to calculate rewards and call `GameState.record_match_result()`
    - [ ] Write failing test: `end_match()` calls `Economy.calculate_match_reward()` with stored match_type, won, tournament_tier, losing_streak
    - [ ] Write failing test: `end_match()` result dict includes `gold_earned` and `infamy_earned` from Economy calculation
    - [ ] Write failing test: `end_match()` calls `GameState.record_match_result()` with won, match_type, rewards
    - [ ] Implement: Update `end_match()` — calculate rewards via Economy, build full result dict, call GameState.record_match_result before clearing state
    - [ ] Verify: tests pass

- [ ] Task: Full match lifecycle integration test
    - [ ] Write integration test: Complete match flow — `start_match()` -> simulate deaths/timer -> `end_match()` -> verify rewards applied to GameState, market refreshed, save triggered, CombatManager idle
    - [ ] Write integration test: Player-win scenario (all enemies die) — rewards applied, losing_streak reset
    - [ ] Write integration test: Player-loss scenario (all players die) — consolation rewards, losing_streak incremented
    - [ ] Write integration test: Timer expiry scenario — HP% determines winner
    - [ ] Verify: `gd-tools lint && gd-tools format --check && gd-tools test --coverage --min 80`

- [ ] Task: Conductor - User Manual Verification 'Phase 3: Economy Integration & Post-Match Flow' (Protocol in workflow.md)
</protect>
