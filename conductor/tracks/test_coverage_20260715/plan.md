<protect>
# Implementation Plan: Increase Test Coverage

## Phase 1: Coverage Tool Configuration [checkpoint: bc0cde7]

- [x] Task: Read `spec.md` and `workflow.md` to re-establish context before starting this phase
- [x] Task: Update `gd-tools.toml` coverage settings [66a64a1]
    - [x] Set `[coverage] enabled = true`
    - [x] Set `[coverage] min_percent = 80`
    - [x] Add 5 exempt files to `[coverage] exclude` list: `scripts/data/enums.gd`, `scripts/data/part_data.gd`, `scripts/data/ability_data.gd`, `scripts/data/ability_effect.gd`, `scripts/data/behavior_module_data.gd`
- [x] Task: Run baseline coverage to verify exempt files are excluded [66a64a1]
    - [x] Run `gd-tools test --coverage --min 80` and confirm exempt files do not appear in coverage report
    - [x] Record baseline coverage percentage for each module
- [x] Task: Document configuration change in `tech-stack.md` [66a64a1]
    - [x] Add dated note explaining coverage exclusion for pure data/enum files
- [x] Task: Conductor - User Manual Verification 'Coverage Tool Configuration' (Protocol in workflow.md)

## Phase 2: Unit Test Expansion — Systems Modules [checkpoint: 083ebf2]

- [x] Task: Read `spec.md` and `workflow.md` to re-establish context before starting this phase
- [x] Task: Expand `test_economy.gd` for `scripts/systems/economy.gd` [ae4ea60]
    - [x] Write tests for untested branches (e.g., losing streak rubber-band bonus, edge cases for tier 0/invalid tier)
    - [x] Run tests and verify they pass (if any fail, document as source bug per NFR-3)
    - [x] Verify coverage for economy module is 95%+
- [x] Task: Expand `test_decay.gd` for `scripts/systems/decay.gd` [abf3f6f]
    - [ ] Write tests for untested branches (e.g., decay accumulation thresholds, repair cost edge cases, purebred immunity)
    - [ ] Run tests and verify they pass
    - [ ] Verify coverage for decay module is 95%+
- [x] Task: Expand `test_research.gd` for `scripts/systems/research.gd` [65e2800]
    - [ ] Write tests for untested branches (e.g., ascension branch unlocking, bonus stacking, prerequisite checks)
    - [ ] Run tests and verify they pass
    - [ ] Verify coverage for research module is 95%+
- [x] Task: Expand `test_market.gd` for `scripts/systems/market.gd` [c813b59]
    - [x] Write tests for untested branches (e.g., rotating stock refresh, rarity filtering, infamy-gated legendary parts)
    - [x] Run tests and verify they pass
    - [x] Verify coverage for market module is 95%+
- [x] Task: Expand `test_part_database.gd` for `scripts/systems/part_database.gd` [e647aec]
    - [x] Write tests for untested branches (e.g., lookup by shape_id+strain+rarity, missing part fallback, ability lookup by ability_id)
    - [x] Run tests and verify they pass
    - [x] Verify coverage for part_database module is 95%+
- [ ] Task: Conductor - User Manual Verification 'Unit Test Expansion — Systems Modules' (Protocol in workflow.md)

## Phase 3: Unit Test Expansion — Data & Combat Modules [checkpoint: 9f1575a]

- [x] Task: Read `spec.md` and `workflow.md` to re-establish context before starting this phase
- [x] Task: Expand `test_chimera_data.gd` for `scripts/data/chimera_data.gd` [2acbdba]
    - [ ] Write tests for untested branches (e.g., stat aggregation from equipped parts, instability calculation, combo ability lookup, part equip/unequip)
    - [ ] Run tests and verify they pass
    - [ ] Verify coverage for chimera_data module is 95%+
- [x] Task: Expand `test_combat_state.gd` for `scripts/combat/combat_state.gd` [c4ec9f3]
    - [ ] Write tests for untested branches (e.g., HP boundary conditions, berserk trigger/reset, cooldown management, effect application/removal)
    - [ ] Run tests and verify they pass
    - [ ] Verify coverage for combat_state module is 95%+
- [x] Task: Expand `test_active_effect.gd` for `scripts/combat/active_effect.gd` [5fefb5e]
    - [ ] Write tests for untested branches (e.g., effect tick processing, duration expiry, stat modification application/removal)
    - [ ] Run tests and verify they pass
    - [ ] Verify coverage for active_effect module is 95%+
- [x] Task: Expand `test_effect_component.gd` for `scripts/combat/effect_component.gd` [cdcfd20]
    - [ ] Write tests for untested branches (e.g., multiple simultaneous effects, effect stacking rules, component signal emissions)
    - [ ] Run tests and verify they pass
    - [ ] Verify coverage for effect_component module is 95%+
- [ ] Task: Conductor - User Manual Verification 'Unit Test Expansion — Data & Combat Modules' (Protocol in workflow.md)

## Phase 4: Unit Test Expansion — Autoload Modules (with Mocking) [checkpoint: 474fe51]

- [x] Task: Read `spec.md` and `workflow.md` to re-establish context before starting this phase [e6584f4]
- [x] Task: Expand `test_event_bus.gd` for `scripts/autoload/event_bus.gd`
    - [x] Write tests for untested branches (e.g., signal parameter validation, multi-signal emission sequences, disconnect cleanup)
    - [x] Run tests and verify they pass
    - [x] Verify coverage for event_bus module is 95%+
- [x] Task: Expand `test_game_state.gd` for `scripts/autoload/game_state.gd` using GUT doubling
    - [x] Set up GUT `double()` for SaveManager and EventBus dependencies
    - [x] Write tests for untested branches (e.g., gold/infamy modification, roster management, inventory operations, state persistence calls)
    - [x] Run tests and verify they pass
    - [x] Verify coverage for game_state module is 95%+
- [x] Task: Expand `test_save_manager.gd` for `scripts/autoload/save_manager.gd` using mocked file I/O [9464c76]
    - [x] Set up mocked file I/O for `user://saves/` operations
    - [x] Write tests for untested branches (e.g., save serialization, load deserialization, PartDatabase reconstruction, corrupt save handling)
    - [x] Run tests and verify they pass
    - [x] Verify coverage for save_manager module is 95%+
- [x] Task: Expand `test_combat_manager.gd` for `scripts/autoload/combat_manager.gd` using mocked combat entities
    - [x] Set up GUT doubles for CombatState and combat entities
    - [x] Write tests for untested branches (e.g., match start/end lifecycle, entity placement, reward distribution, signal emission)
    - [x] Run tests and verify they pass
    - [x] Verify coverage for combat_manager module is 95%+
- [x] Task: Conductor - User Manual Verification 'Unit Test Expansion — Autoload Modules' (Protocol in workflow.md)

## Phase 5: Integration Tests [checkpoint: 33935c4]

- [x] Task: Read `spec.md` and `workflow.md` to re-establish context before starting this phase
- [x] Task: Create `tests/integration/test_economy_flow.gd` [1952fe2]
    - [x] Write integration test: buy_part → gold deduction → inventory add → save → load → verify state
    - [x] Run test and verify it passes
- [x] Task: Create `tests/integration/test_assembly_flow.gd` [bfe814e]
    - [x] Write integration test: equip part → recalculate_stats → update instability → combo lookup → save
    - [x] Run test and verify it passes
- [x] Task: Create `tests/integration/test_combat_lifecycle.gd` [53366cb]
    - [x] Write integration test: start_match → entity placement → AI/combat execution → end_match → rewards → save
    - [x] Run test and verify it passes
- [ ] Task: Conductor - User Manual Verification 'Integration Tests' (Protocol in workflow.md)

## Phase 6: Edge Case Tests

- [x] Task: Read `spec.md` and `workflow.md` to re-establish context before starting this phase
- [x] Task: Write berserk edge case tests (in relevant test files or `tests/edge/test_berserk_edge_cases.gd`) [a248d23]
    - [ ] Test purebred immunity to berserk
    - [ ] Test event modifier accumulation and reset
    - [ ] Test 5s duration transition (berserk start → expire)
- [x] Task: Write decay edge case tests (in relevant test files or `tests/edge/test_decay_edge_cases.gd`) [a37f5ea]
    - [ ] Test decay accumulation across multiple matches
    - [ ] Test repair resets decay to zero
    - [ ] Test purebred immunity to decay
- [x] Task: Write combo tier edge case tests (in relevant test files or `tests/edge/test_combo_edge_cases.gd`) [f22d76e]
    - [ ] Test 2-strain combo = Basic
    - [ ] Test 3-strain combo = Enhanced
    - [ ] Test 4-strain combo = Ultimate
    - [ ] Test all-different strains = null (no combo)
- [ ] Task: Write save/load round-trip tests (in `tests/edge/test_save_load_edge_cases.gd`)
    - [ ] Test full state preservation through save → load cycle
    - [ ] Test PartDatabase reconstruction from saved references (shape_id + strain + rarity)
- [ ] Task: Write formation grid mapping tests (in `tests/edge/test_formation_edge_cases.gd`)
    - [ ] Test all 9 cells (3x3 grid) map to correct world positions
- [ ] Task: Conductor - User Manual Verification 'Edge Case Tests' (Protocol in workflow.md)

## Phase 7: Final Verification & Coverage Gate

- [ ] Task: Read `spec.md` and `workflow.md` to re-establish context before starting this phase
- [ ] Task: Run full verification suite
    - [ ] Run `gd-tools lint` and confirm exit 0
    - [ ] Run `gd-tools format --check` and confirm exit 0
    - [ ] Run `gd-tools test --coverage --min 80` and confirm exit 0
- [ ] Task: Verify stretch goal (95%+ coverage on testable files)
    - [ ] Review coverage report and identify any remaining gaps
    - [ ] If below 95%, add targeted tests for remaining uncovered branches
    - [ ] Re-run coverage to confirm 95%+ achieved (or document why 95% is impractical for specific modules)
- [ ] Task: Conductor - User Manual Verification 'Final Verification & Coverage Gate' (Protocol in workflow.md)
</protect>
