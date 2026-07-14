<protect>

# Track Specification: Singleton Architecture, Signals & Save System

## Overview

TRACK-004 implements the core singleton architecture, global signal system, and JSON-based save system. The 4 autoload stubs from TRACK-001 are transformed into functional systems:

1. **EventBus** — Global signal hub with all 13 signals
2. **GameState** — Persistent campaign state with full properties and methods
3. **SaveManager** — JSON serialization with save-by-reference reconstruction
4. **CombatManager** — Stub only (match_active=false)

Additionally, 4 system static utility classes are implemented as pure functions: `economy.gd`, `market.gd`, `decay.gd`, `research.gd`.

This track unblocks Milestones 3 (Combat) and 4 (UI).

## Context Anchors

- **GDD:** Section 4.1 (The Loop), 4.2 (Genetic Decay), 4.3 (Resources), 4.5 (Research Tracks), 4.6 (Fail State), 4.7 (Black Market)
- **TDD:** Section 4 (Singleton Architecture), Section 5 (Signal Architecture), Section 9 (Save System)
- **ROADMAP:** TRACK-004

## Functional Requirements

### FR-1: EventBus Autoload (Global Signal Hub)

EventBus extends Node. No state, no logic beyond signal declarations. All 13 signals:

1. `gold_changed(amount: int)`
2. `infamy_changed(amount: int)`
3. `part_purchased(part: PartData)`
4. `chimera_modified(chimera: ChimeraData)`
5. `chimera_decayed(chimera: ChimeraData, stat_lost: String)`
6. `match_started(player_roster: Array, enemy_roster: Array)`
7. `match_ended(result: Dictionary)`
8. `market_refreshed()`
9. `research_unlocked(branch: String, node: String, level: int)`
10. `chimera_ascended(chimera: ChimeraData)`
11. `screen_change_requested(screen: String)`
12. `berserk_triggered(chimera: ChimeraData)`
13. `combat_log(message: String)`

### FR-2: GameState Autoload (Persistent Campaign State)

GameState holds all persistent campaign data. System scripts are static utilities — GameState calls them and stores results.

**Properties:**
- `gold: int` (starts at 200, never below 0)
- `infamy: int` (starts at 0)
- `roster: Array[ChimeraData]` (always exactly 3)
- `inventory: Array[PartData]`
- `market_stock: Dictionary` — `{base: Array[PartData], rotating: Array[PartData]}`
- `research_progress: Dictionary` — `{branch: {node: level}}`
- `research_points: int`
- `hall_of_fame: Array[ChimeraData]`
- `current_tournament: Dictionary`
- `match_history: Array[Dictionary]`
- `losing_streak: int`

**Methods:**
- `add_gold(amount) -> void` — emits gold_changed
- `spend_gold(amount) -> bool` — returns false if insufficient (no negative Gold per GDD 4.6)
- `add_infamy(amount) -> void` — emits infamy_changed
- `get_chimera(index) -> ChimeraData`
- `replace_chimera(index, new_chimera) -> void` — emits chimera_modified, triggers save
- `add_part(part) -> void`
- `remove_part(part) -> void`
- `refresh_market() -> void` — generates new rotating stock via market.gd, emits market_refreshed, triggers save
- `buy_part(part) -> bool` — validates via market.gd, deducts gold, adds to inventory, emits part_purchased, triggers save
- `can_ascend(chimera) -> bool` — true if match_wins >= 10
- `ascend_chimera(chimera) -> int` — moves to hall_of_fame, grants 1 RP, replaces roster slot with free common starter, emits chimera_ascended, triggers save. Returns RP gained.
- `get_research_level(branch, node) -> int` — 0 if not unlocked
- `spend_research_point(branch, node) -> bool` — validates via research.gd, deducts point, increments level, emits research_unlocked, triggers save

**Initialization (auto-init on boot):**
- On `_ready()`, calls `SaveManager.load_game()`. If no save: new game with gold=200, infamy=0, roster=3 duplicated starters from PartDatabase, inventory=[], market_stock=market.gd.generate_initial_stock(), research_progress={}, research_points=0, hall_of_fame=[], match_history=[], losing_streak=0.
- Base stock: 24 common parts (4 slots x 6 strains, random shape variant each).
- Rotating stock: 6-10 parts with rarity weights (Common 50%, Uncommon 30%, Rare 15%, Legendary 5%).

### FR-3: System Static Utilities (pure functions, no state)

#### FR-3.1: economy.gd
- `calculate_match_reward(match_type, won, tournament_tier, losing_streak) -> Dictionary`
  - Regular win: `{gold: 30, infamy: 2}`
  - Regular loss: `{gold: 10, infamy: 0}`
  - Tournament win: `{gold: 50 * multiplier, infamy: 10 * multiplier}` (multiplier = 1/2/4/8 by tier)
  - Tournament loss: `{gold: 0, infamy: 0}`
- `calculate_tournament_entry_fee(tier) -> int` — [0, 100, 300, 1000]
- `get_tournament_multiplier(tier) -> int` — [1, 2, 4, 8]
- `get_tournament_infamy_threshold(tier) -> int` — [0, 50, 150, 400]

#### FR-3.2: market.gd
- `validate_purchase(part, gold, infamy) -> Dictionary` — checks gold >= price, infamy >= 50 for Legendary
- `calculate_price(part) -> int` — Common: rand(50,100), Uncommon: rand(150,300), Rare: rand(500,1000), Legendary: rand(1500,3000)
- `generate_initial_stock() -> Dictionary` — `{base: Array, rotating: Array}`. Base: 24 common parts (4 slots x 6 strains). Rotating: 6-10 parts with rarity weights.
- `generate_rotating_stock() -> Array[PartData]` — 6-10 random parts with rarity weights
- `apply_market_connections_discount(price, research_level) -> int` — -15% per level (max 2)

#### FR-3.3: decay.gd

Decay values per instability:

| Instability | Chance | Stat Loss | Repair Cost |
|-------------|--------|-----------|-------------|
| 0 (Pure) | 0% | 0% | 0G |
| 1 (Stable) | 15% | 5% | 50G |
| 2 (Volatile) | 30% | 10% | 100G |
| 3 (Chaotic) | 50% | 15% | 200G |

- `check_decay(chimera) -> Dictionary` — rolls against chance. Purebreds never decay.
- `apply_decay(chimera) -> String` — reduces ALL derived stats (max_hp, attack, defense, speed) by decay %. Increments decay_level.
- `calculate_repair_cost(chimera, research_level) -> int` — base cost per instability, -15% per Reinforced Genetics level
- `repair_chimera(chimera) -> void` — resets decay_level to 0, recalculates stats
- `apply_reinforced_genetics_reduction(base_chance, research_level) -> float` — -15% per level
- `salvage_chimera(chimera) -> Array[PartData]` — breaks to Neutral parts, retains base stats. All-Neutral = Pure.

#### FR-3.4: research.gd

Node structure:
- **Strain Mastery** (6 tracks, 3 levels each): +10% combo power, +5% part stats per level
- **Lab Engineering** (4 nodes, 2 levels each): -15% per level (Reinforced Genetics, Clinic Efficiency, Market Connections, Stability Serum)
- **Combat Doctrine** (4 nodes, 1 level each): Tactical AI (+10% decision weight), Ability Tuning (-10% cooldowns), Formation Mastery (+5% stats in correct row), Berserk Control (5s->3s)

- `can_unlock(branch, node, current_level, available_points) -> bool`
- `get_max_level(branch, node) -> int` — 3 for Strain Mastery, 2 for Lab Engineering, 1 for Combat Doctrine
- `get_effect_value(branch, node, level) -> float`
- `get_research_cost(branch, node, current_level) -> int` — 1 RP per level

### FR-4: SaveManager Autoload (JSON Serialization)

- `save_game() -> void` — serializes GameState to `user://saves/save_default.json`. Parts saved by reference (shape_id + strain + rarity + slot).
- `load_game() -> bool` — deserializes JSON, reconstructs parts via PartDatabase.get_part(). Calls `_migrate()` if version mismatches. Returns false if no save or invalid JSON.
- `has_save() -> bool`
- `delete_save() -> void`
- `_migrate(from_version, data) -> Dictionary` — stub (version 1, no-op). Future versions add switch logic.

**Save structure (TDD Section 9):** version, timestamp, game_state (gold, infamy, losing_streak, research_points, research_progress, roster[parts by ref], inventory[by ref], market_stock, hall_of_fame, match_history).

**6 Save Triggers:**
1. After every match (win or loss)
2. After every market purchase (buy_part succeeds)
3. After every assembly change (replace_chimera)
4. After every clinic repair (decay repair)
5. After every research purchase (spend_research_point succeeds)
6. On game exit (SaveManager._exit_tree)

### FR-5: CombatManager Stub
- `match_active: bool = false`
- `_process(delta)` — returns early if `!match_active`

### FR-6: Autoload Init Order
EventBus -> GameState -> SaveManager -> CombatManager (verified on boot).

## Balancing Values Summary

| Parameter | Value |
|-----------|-------|
| Starting Gold | 200G |
| Starting Infamy | 0 |
| Regular Win | 30G + 2 Infamy |
| Regular Loss | 10G + 0 Infamy |
| Tournament Base (per win) | 50G + 10 Infamy x multiplier |
| Tournament Multipliers | 1x/2x/4x/8x |
| Tournament Entry Fees | 0/100/300/1000G |
| Tournament Infamy Thresholds | 0/50/150/400 |
| Legendary Infamy Gate | 50 |
| Market Rarity Weights | C50%/U30%/R15%/L5% |
| Market Rotating Count | 6-10 parts |
| Decay: Stable | 15%/5%/50G |
| Decay: Volatile | 30%/10%/100G |
| Decay: Chaotic | 50%/15%/200G |
| Decay Stat Loss | All stats uniformly |
| Ascension Threshold | 10 wins |
| Ascension Reward | 1 RP + free common starter |
| Market Prices | C:50-100, U:150-300, R:500-1000, L:1500-3000 |
| Research: Strain Mastery | +10% combo/+5% stats per level (3 levels) |
| Research: Lab Engineering | 15% reduction per level (2 levels) |
| Research: Combat Doctrine | Flat bonuses (1 level) |
| Save Version | 1 |

## Acceptance Criteria

- [ ] AC-1: New game initializes with 200G, 0 Infamy, 3 starters, valid market stock
- [ ] AC-2: spend_gold fails on insufficient (no negative Gold), buy_part validates and updates gold+inventory
- [ ] AC-3: buy_part fails on insufficient Gold, Legendary blocked below 50 Infamy, refresh_market generates valid stock, prices within GDD ranges
- [ ] AC-4: Decay probability matches values per instability, repair cost matches, all stats reduced uniformly, purebreds never decay
- [ ] AC-5: can_ascend true at 10+ wins, ascend moves to hall_of_fame + grants 1 RP + replaces with starter
- [ ] AC-6: Save/load round-trip preserves all state, JSON valid per TDD Section 9, parts saved by reference, reconstructed via PartDatabase
- [ ] AC-7: spend_research_point unlocks + deducts, fails when no points, max levels correct (3/2/1)
- [ ] AC-8: EventBus signals fire on all state changes
- [ ] AC-9: Autoload order correct, GameState auto-inits new game when no save
- [ ] AC-10: System scripts pure static, lint passes, format passes, coverage >= 80%, all public functions documented

## Out of Scope

- CombatManager match logic (stub only) — TRACK-008
- UI screens — Milestone 4
- Enemy generation — TRACK-008
- Combat entity creation — TRACK-005
- Ability execution — TRACK-007
- Tournament bracket logic — TRACK-015
- Research effect consumption in combat (tracking + values defined here, applied in combat tracks)
- Rubber-band difficulty formula (losing_streak tracked here, formula in TRACK-008)

</protect>
