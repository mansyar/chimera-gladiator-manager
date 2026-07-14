<protect>

# Implementation Plan: Singleton Architecture, Signals & Save System

## Phase 1: EventBus, CombatManager Stub & System Utilities [checkpoint: a205b5d]

- [x] Task: Read spec.md and workflow.md before starting phase implementation
    - [x] Read `./spec.md` to review all functional requirements and acceptance criteria
    - [x] Read `conductor/workflow.md` to review TDD workflow and task lifecycle rules

- [x] Task: Implement EventBus with all 13 signals
    - [x] Write failing tests verifying all 13 signals can be emitted and connected
    - [x] Implement all 13 signal declarations in event_bus.gd
    - [x] Verify tests pass

- [x] Task: Implement CombatManager stub (7d25f7d)
    - [x] Set match_active property to false
    - [x] Implement _process() early return when !match_active
    - [x] Verify project boots without errors

- [x] Task: Implement economy.gd static utility (d049302)
    - [x] Write failing tests for calculate_match_reward (Regular win/loss, Tournament win/loss with multipliers)
    - [x] Write failing tests for calculate_tournament_entry_fee, get_tournament_multiplier, get_tournament_infamy_threshold
    - [x] Implement all economy.gd functions
    - [x] Verify tests pass

- [x] Task: Implement market.gd static utility (dfdc69f)
    - [x] Write failing tests for validate_purchase (sufficient gold, insufficient gold, Legendary Infamy gate)
    - [x] Write failing tests for calculate_price (within GDD ranges per rarity)
    - [x] Write failing tests for generate_initial_stock (24 base + 6-10 rotating)
    - [x] Write failing tests for generate_rotating_stock (6-10 valid parts, correct rarity weights)
    - [x] Write failing tests for apply_market_connections_discount
    - [x] Implement all market.gd functions
    - [x] Verify tests pass

- [x] Task: Implement decay.gd static utility (35ba222)
    - [x] Write failing tests for check_decay (purebreds never decay, probability per instability)
    - [x] Write failing tests for apply_decay (all stats reduced uniformly)
    - [x] Write failing tests for calculate_repair_cost (matches values per instability, reduced by research)
    - [x] Write failing tests for repair_chimera (resets decay_level, recalculates stats)
    - [x] Write failing tests for salvage_chimera (produces Neutral parts, all-Neutral = Pure)
    - [x] Implement all decay.gd functions
    - [x] Verify tests pass

- [x] Task: Implement research.gd static utility (fa96344)
    - [x] Write failing tests for can_unlock (insufficient points, at max level, valid unlock)
    - [x] Write failing tests for get_max_level (3 for Strain Mastery, 2 for Lab Engineering, 1 for Combat Doctrine)
    - [x] Write failing tests for get_effect_value (correct values per node/level)
    - [x] Write failing tests for get_research_cost (1 RP per level)
    - [x] Implement all research.gd functions including node definitions
    - [x] Verify tests pass

- [x] Task: Conductor - User Manual Verification 'Phase 1: EventBus, CombatManager Stub & System Utilities' (Protocol in workflow.md)

## Phase 2: GameState Full Implementation

- [ ] Task: Read spec.md and workflow.md before starting phase implementation
    - [ ] Read `./spec.md` to review all functional requirements and acceptance criteria
    - [ ] Read `conductor/workflow.md` to review TDD workflow and task lifecycle rules

- [ ] Task: Implement GameState properties and gold/infamy management
    - [ ] Write failing tests for add_gold (increases gold, emits gold_changed)
    - [ ] Write failing tests for spend_gold (returns false on insufficient, true on sufficient, no negative gold)
    - [ ] Write failing tests for add_infamy (increases infamy, emits infamy_changed)
    - [ ] Define all GameState properties (gold, infamy, roster, inventory, market_stock, research_progress, research_points, hall_of_fame, current_tournament, match_history, losing_streak)
    - [ ] Implement add_gold(), spend_gold(), add_infamy() with EventBus signal emissions
    - [ ] Verify tests pass

- [ ] Task: Implement GameState roster and inventory management
    - [ ] Write failing tests for get_chimera (returns correct chimera by index)
    - [ ] Write failing tests for replace_chimera (updates roster, emits chimera_modified)
    - [ ] Write failing tests for add_part and remove_part (inventory management)
    - [ ] Implement get_chimera(), replace_chimera(), add_part(), remove_part()
    - [ ] Verify tests pass

- [ ] Task: Implement GameState new game initialization
    - [ ] Write failing tests for new game state (200G, 0 Infamy, 3 starters from PartDatabase)
    - [ ] Write failing tests for market_stock initialization (24 base + 6-10 rotating)
    - [ ] Write failing tests for empty research_progress, hall_of_fame, match_history
    - [ ] Implement _ready() auto-init logic (calls SaveManager.load_game(), falls back to _init_new_game())
    - [ ] Implement _init_new_game() with starting state (calls market.gd.generate_initial_stock())
    - [ ] Verify tests pass

- [ ] Task: Implement GameState market delegation methods
    - [ ] Write failing tests for buy_part (validates via market.gd, deducts gold, adds to inventory, emits part_purchased)
    - [ ] Write failing tests for buy_part failure (insufficient gold, Legendary Infamy gate)
    - [ ] Write failing tests for refresh_market (generates new rotating stock, emits market_refreshed)
    - [ ] Implement buy_part() delegating to market.gd.validate_purchase and market.gd.calculate_price
    - [ ] Implement refresh_market() delegating to market.gd.generate_rotating_stock
    - [ ] Verify tests pass

- [ ] Task: Implement GameState ascension methods
    - [ ] Write failing tests for can_ascend (true at 10+ wins, false below)
    - [ ] Write failing tests for ascend_chimera (moves to hall_of_fame, grants 1 RP, replaces with starter, emits chimera_ascended)
    - [ ] Implement can_ascend() and ascend_chimera()
    - [ ] Verify tests pass

- [ ] Task: Implement GameState research methods
    - [ ] Write failing tests for get_research_level (returns 0 for unlocked, correct level for unlocked)
    - [ ] Write failing tests for spend_research_point (unlocks node, deducts point, emits research_unlocked, fails when no points)
    - [ ] Implement get_research_level() and spend_research_point() delegating to research.gd
    - [ ] Verify tests pass

- [ ] Task: Conductor - User Manual Verification 'Phase 2: GameState Full Implementation' (Protocol in workflow.md)

## Phase 3: Save System & Final Integration

- [ ] Task: Read spec.md and workflow.md before starting phase implementation
    - [ ] Read `./spec.md` to review all functional requirements and acceptance criteria
    - [ ] Read `conductor/workflow.md` to review TDD workflow and task lifecycle rules

- [ ] Task: Implement SaveManager JSON serialization
    - [ ] Write failing tests for save_game() creating valid JSON at user://saves/save_default.json
    - [ ] Write failing tests for save structure (version, timestamp, game_state with all fields)
    - [ ] Write failing tests for parts saved by reference (shape_id + strain + rarity + slot)
    - [ ] Write failing tests for load_game() returning false when no save exists
    - [ ] Write failing tests for load_game() reconstructing parts via PartDatabase.get_part()
    - [ ] Write failing tests for save/load round-trip preserving all state
    - [ ] Write failing tests for has_save() and delete_save()
    - [ ] Write failing tests for _migrate() stub (no-op for version 1)
    - [ ] Implement save_game() with JSON serialization
    - [ ] Implement serialize_part() and deserialize_part()
    - [ ] Implement load_game() with JSON deserialization and PartDatabase reconstruction
    - [ ] Implement _migrate() stub
    - [ ] Implement has_save() and delete_save()
    - [ ] Verify tests pass

- [ ] Task: Implement save triggers
    - [ ] Write failing tests for save trigger after buy_part succeeds
    - [ ] Write failing tests for save trigger after replace_chimera
    - [ ] Write failing tests for save trigger after refresh_market
    - [ ] Write failing tests for save trigger after ascend_chimera
    - [ ] Write failing tests for save trigger after spend_research_point
    - [ ] Write failing tests for save trigger on game exit (_exit_tree)
    - [ ] Add SaveManager.save_game() calls to GameState methods (buy_part, replace_chimera, refresh_market, ascend_chimera, spend_research_point)
    - [ ] Implement SaveManager._exit_tree() save trigger
    - [ ] Verify tests pass

- [ ] Task: Verify EventBus signal integration
    - [ ] Write integration tests for all signal emissions (gold_changed, infamy_changed, part_purchased, chimera_modified, market_refreshed, research_unlocked, chimera_ascended)
    - [ ] Wire EventBus signal emissions in all GameState methods
    - [ ] Verify integration tests pass

- [ ] Task: Final quality gate verification
    - [ ] Run gd-tools lint (must exit 0)
    - [ ] Run gd-tools format --check (must exit 0)
    - [ ] Run gd-tools test --coverage --min 80 (must exit 0)
    - [ ] Verify autoload init order on boot (EventBus -> GameState -> SaveManager -> CombatManager)
    - [ ] Verify GameState auto-inits new game when no save exists

- [ ] Task: Conductor - User Manual Verification 'Phase 3: Save System & Final Integration' (Protocol in workflow.md)

</protect>
