<protect>
# Track Specification: Combat Manager & Match Flow (TRACK-008)

## Overview

Implements the CombatManager autoload's full match lifecycle, win condition evaluation, procedural enemy generation with rubber-band difficulty scaling, and post-match economy integration. This track transforms CombatManager from a stub into the central orchestrator of automated arena combat, tying together the combat entity (TRACK-005), AI FSM (TRACK-006), and ability system (TRACK-007) into a complete, playable match loop.

**Track Type:** Feature  
**Dependencies:** TRACK-004 (Singleton/Save), TRACK-005 (Combat Entity/Arena), TRACK-006 (AI FSM), TRACK-007 (Ability System)  
**Estimated Effort:** 2-3 Days  

### Context Anchors
- **GDD:** Section 2.4 (Combat Model — 60s timer, win conditions), Section 4.4 (Match Types — Regular/Tournament), Section 4.6 (Rubber-band difficulty, regular matches always free)
- **TDD:** Section 4 (CombatManager autoload), Section 6 (Win Condition, Enemy Generation)

---

## Functional Requirements

### FR-1: CombatManager Match Lifecycle

**start_match(player_roster: Array[ChimeraData], enemy_roster: Array[ChimeraData], formations: Array, match_type: String, tournament_tier: int) -> void**

- Creates one `ChimeraEntity` per chimera (3 player + 3 enemy = 6 total)
- Instantiates from `chimera_entity.tscn` PackedScene
- Initializes `CombatState` from each `ChimeraData` via `CombatState.initialize(data, team_id)`
- Applies passive abilities via `AbilityComponent.apply_passives()` after CombatState initialization
- Places each entity at its formation grid world position via `ArenaController.grid_to_world(row, col, is_player)`
- Registers each entity in `CombatContext`
- Connects each entity's `died` signal to `_on_entity_died()`
- Sets `match_active = true`, `timer = 60.0`
- Emits `EventBus.match_started(player_roster, enemy_roster)`
- Stores `match_type` and `tournament_tier` for post-match reward calculation
- Finds the arena's `Entities` node via scene tree; if not found, creates a temporary `Node2D` container (test mode)

**_process(delta: float) -> void**

- Returns early if `!match_active` (idle between matches)
- Decrements `timer` by `delta`
- Calls `check_win_condition()` every frame
- When `timer <= 0.0`: calls `_on_timer_expired()`

**end_match(result: Dictionary) -> void**

- Sets `match_active = false`
- Calculates rewards via `Economy.calculate_match_reward(match_type, won, tournament_tier, losing_streak)`
- Calls `GameState.record_match_result(won, match_type, rewards)` (new GameState method)
- Emits `EventBus.match_ended(result)` with full result dict
- Clears all combat state: `combat_entities`, `CombatContext.entities`, `player_formation`, `enemy_formation`, `timer`
- Frees all spawned ChimeraEntity nodes

### FR-2: Win Condition Evaluation

**check_win_condition() -> void**

Called after every entity death AND every frame in `_process()`:

1. Count alive entities per team via `CombatContext.get_enemies_of()` / alive filtering
2. If player team has 0 alive → enemy wins
3. If enemy team has 0 alive → player wins
4. If 60-second timer expires → side with higher total HP percentage wins
5. On any win condition met → call `end_match(result)` with match result dictionary

**Match result dictionary:**
```
{
  "winner": <int>,           # 0 = player, 1 = enemy
  "won": <bool>,             # true if player won
  "surviving_hp": <float>,    # Total surviving HP percentage of winning side
  "duration": <float>,        # Match duration in seconds
  "gold_earned": <int>,       # Gold reward from Economy
  "infamy_earned": <int>      # Infamy reward from Economy
}
```

### FR-3: Entity Death Handling

**_on_entity_died(entity: ChimeraEntity) -> void**

- Marks entity as dead (CombatState.is_dead already set by take_damage)
- Unregisters entity from `CombatContext`
- Calls `check_win_condition()` immediately (don't wait for next frame)

**_on_timer_expired() -> void**

- Calculates total HP% for both teams
- Determines winner by higher HP%
- Calls `end_match(result)`

### FR-4: CombatManager Idle State

- Between matches: `match_active = false`, `_process` returns early
- All combat state cleared in `end_match()`: entities freed, arrays cleared, context reset
- CombatManager remains loaded as an autoload but does nothing between matches

### FR-5: Enemy Generation (enemy_generator.gd)

**static func generate_enemy_roster(player_roster: Array[ChimeraData], match_type: String, losing_streak: int, tournament_tier: int) -> Array[ChimeraData]**

- Creates 3 enemy chimeras via `PartDatabase.generate_random_part()`
- **Regular matches:** Uses "normal" difficulty tier by default; shifts to "weak" when `losing_streak >= 3` (rubber-band per GDD 4.6)
- **Tournament matches:** Uses tier-based difficulty (tier 1-2 = "tough", tier 3-4 = "strong")
- Difficulty tier determines rarity weight distribution for generated parts
- Each enemy chimera gets 4 parts (head/torso/arms/legs) with appropriate rarity for the difficulty
- Enemy chimeras are ChimeraData resources (not saved — transient, generated per match)
- Calls `ChimeraData.recalculate_stats()` after assembly

**Difficulty Tier Rarity Weight Tables:**

| Tier | Use Case | COMMON | UNCOMMON | RARE | LEGENDARY |
|------|----------|--------|----------|------|-----------|
| weak | Regular, losing streak >=3 | 80 | 18 | 2 | 0 |
| normal | Regular, default | 60 | 30 | 9 | 1 |
| tough | Tournament tier 1-2 | 45 | 35 | 18 | 2 |
| strong | Tournament tier 3-4 | 30 | 40 | 25 | 5 |

### FR-6: Post-Match Economy Integration

**GameState.record_match_result(won: bool, match_type: String, rewards: Dictionary) -> void** (new method)

- Updates `losing_streak`: increment if lost, reset to 0 if won
- Appends to `match_history`: `{"result": "win"/"loss", "gold": rewards["gold"]}`
- Calls `add_gold(rewards["gold"])` and `add_infamy(rewards["infamy"])`
- Calls `refresh_market()` (market refreshes after every match per GDD 4.7)
- Calls `SaveManager.save_game()` (save trigger after match)

### FR-7: get_enemies_of Helper

**get_enemies_of(team: int) -> Array[ChimeraEntity]**

- Delegates to `CombatContext.get_enemies_of(team)`
- Provided as a convenience method on CombatManager for AI states that reference CombatManager directly

---

## Non-Functional Requirements

### NFR-1: Testability
- All CombatManager logic (win conditions, timer, entity lifecycle) must be unit-testable without the full arena scene
- Enemy generation must be testable without instantiating scenes
- Use dependency injection where possible (pass test containers, mock CombatContext)

### NFR-2: Performance
- `_process` must be lightweight when idle (early return on `!match_active`)
- Entity spawning happens once per match, not per frame
- Win condition check is O(n) where n = entity count (max 6)

### NFR-3: Architecture Compliance
- CombatManager remains an autoload, idle between matches
- No mixing of persistent (ChimeraData) and transient (CombatState) state
- System scripts (enemy_generator.gd) are static utility classes with pure functions
- EventBus for global signals (match_started, match_ended), direct signals for local (entity.died)
- Autoload order preserved: EventBus -> GameState -> SaveManager -> CombatManager

---

## Acceptance Criteria

1. **AC-1:** `start_match()` creates 6 ChimeraEntity instances (3 player, 3 enemy) with initialized CombatState, placed at correct formation grid positions
2. **AC-2:** 60-second timer decrements correctly and triggers win condition on expiry
3. **AC-3:** Match ends when all entities on one side are dead (tested for both player-win and enemy-win scenarios)
4. **AC-4:** Match ends on timer expiry with winner determined by higher total HP%
5. **AC-5:** `enemy_generator.gd` produces 3 valid ChimeraData with parts appropriate to difficulty tier
6. **AC-6:** Losing streak >= 3 produces weaker enemies (rubber-band) for Regular matches
7. **AC-7:** Tournament tier scaling produces appropriately stronger enemies
8. **AC-8:** `end_match()` clears all combat state and CombatManager goes idle
9. **AC-9:** Post-match rewards (Gold/Infamy) calculated via Economy and applied to GameState
10. **AC-10:** Market refreshes after match end
11. **AC-11:** Save triggers after match end
12. **AC-12:** `EventBus.match_started` and `EventBus.match_ended` signals emit correctly

---

## Out of Scope

- Combat HUD / floating HP bars / timer display (TRACK-014)
- Pre-match formation UI / interactive grid placement (TRACK-013)
- Tournament bracket logic / progression (TRACK-015)
- VFX / particle effects during combat (TRACK-014)
- Decay application post-match (decay risk roll happens in a future track or GameState.record_match_result extension)
- Scene loading / ScreenManager integration (TRACK-009)
- Pause / speed toggle functionality (TRACK-014)
</protect>
