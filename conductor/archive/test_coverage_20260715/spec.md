<protect>
# Track Specification: Increase Test Coverage

## Overview

This track focuses on maximizing test coverage across the Chimera Gladiator Manager codebase. All 18 source `.gd` files have been reviewed: 13 already have corresponding test files, and 5 are exempt per workflow rules (pure data/enum definitions with no testable logic). This track will deepen existing unit tests, add integration tests for cross-system flows, add targeted edge case tests, and configure the coverage tool to exclude exempt files — pushing coverage as high as possible (minimum 80%, ideally above 95%).

## Context

- **Product Definition:** Success criteria requires 80%+ test coverage via gd-tools
- **Product Guidelines:** Defines three testing layers (unit, integration, edge cases)
- **Workflow:** TDD applies to `.gd` files with testable logic; pure data/enum definitions are exempt
- **Current State:** 18 source files, 13 test files, 5 exempt files without tests
- **Current gd-tools.toml:** Coverage is disabled (`enabled = false`, `min_percent = 0`); exempt files not in coverage exclude list

## Scope

### In Scope

1. **Configure coverage tool** — Update `gd-tools.toml`:
   - Enable coverage (`enabled = true`)
   - Set minimum percentage (`min_percent = 80`)
   - Add 5 exempt files to `[coverage] exclude` list:
     - `scripts/data/enums.gd`
     - `scripts/data/part_data.gd`
     - `scripts/data/ability_data.gd`
     - `scripts/data/ability_effect.gd`
     - `scripts/data/behavior_module_data.gd`
2. **Expand existing unit tests** — Deepen all 13 existing test files to cover untested branches, functions, and code paths in their corresponding source modules
3. **Add integration tests** — Create cross-system flow tests as described in product-guidelines.md:
   - Economy flow: buy_part → gold deduction → inventory add → save → load → verify
   - Assembly flow: equip part → recalculate_stats → update instability → combo lookup → save
   - Combat match lifecycle: start_match → entity placement → AI/combat execution → end_match → rewards → save
4. **Add edge case tests** — Targeted tests for:
   - Berserk: purebred immunity, event modifier accumulation/reset, 5s duration transition
   - Decay: accumulation across matches, repair resets, purebred immunity
   - Combo tiers: 2=Basic, 3=Enhanced, 4=Ultimate, null for all-different
   - Save/load: round-trip preserves all state, PartDatabase reconstruction works
   - Formation grid: all 9 cells map to correct world positions
5. **Autoload testing with mocks** — Use GUT doubling/mocking to test autoload singleton logic (EventBus, GameState, SaveManager, CombatManager) in isolation

### Out of Scope

- **Exempt files** (no testable logic, per workflow rules — excluded from coverage via `gd-tools.toml`):
  - `scripts/data/enums.gd` — pure enum definitions
  - `scripts/data/part_data.gd` — pure @export Resource
  - `scripts/data/ability_data.gd` — pure @export Resource
  - `scripts/data/ability_effect.gd` — enum + @export Resource
  - `scripts/data/behavior_module_data.gd` — pure @export Resource
- New features or source code changes (this track is test-only; if source bugs are discovered during testing, they are documented but fixed in a separate track)
- UI/scene testing (no scenes exist yet; UI tracks are TRACK-009 through TRACK-012)

## Functional Requirements

### FR-1: Coverage Tool Configuration
- Update `gd-tools.toml` `[coverage]` section: set `enabled = true`, `min_percent = 80`
- Add all 5 exempt files to `[coverage] exclude` list
- Verify `gd-tools test --coverage --min 80` correctly excludes exempt files from calculation
- Document the exclusion configuration change in `tech-stack.md`

### FR-2: Unit Test Expansion
- Every function with testable logic in all 13 tested source files must have test coverage
- Each test file must cover: success cases, failure cases, and edge/boundary cases
- Coverage per module should aim for 95%+ where practical

### FR-3: Integration Tests
- Integration test files created under `tests/integration/`
- Economy flow integration test validates: buy → gold deduction → inventory → save → load → verify state
- Assembly flow integration test validates: equip → recalculate → instability → combo → save
- Combat lifecycle integration test validates: start_match → combat execution → end_match → rewards → save

### FR-4: Edge Case Tests
- Berserk edge cases tested (purebred immunity, modifier accumulation, 5s duration, reset)
- Decay edge cases tested (accumulation, repair reset, purebred immunity)
- Combo tier edge cases tested (2-strain, 3-strain, 4-strain, all-different)
- Save/load round-trip tested (full state preservation, PartDatabase reconstruction)
- Formation grid mapping tested (all 9 cells)

### FR-5: Autoload Mocking
- GUT `double()` or equivalent mocking used to isolate autoload singleton logic
- EventBus signal emission/handling tested in isolation
- GameState state management tested with mocked dependencies
- SaveManager save/load tested with mocked file I/O
- CombatManager match lifecycle tested with mocked combat entities

## Non-Functional Requirements

### NFR-1: Coverage Gate
- Hard acceptance gate: `gd-tools test --coverage --min 80` must exit 0
- Stretch goal: achieve 95%+ overall coverage on files with testable logic
- Coverage measured only on files with testable logic (exempt files excluded via `gd-tools.toml`)

### NFR-2: Code Quality
- All new test files must pass `gd-tools lint` and `gd-tools format --check`
- Test files follow existing naming convention: `test_<script_name>.gd`
- Test files mirror `scripts/` structure under `tests/`
- Tests use GUT `describe`/`it` or `assert_eq` patterns consistent with existing tests

### NFR-3: No Source Changes
- This track modifies only test files and coverage/tool configuration
- If source bugs are discovered, document them as issues for a separate bug fix track

## Acceptance Criteria

1. `gd-tools.toml` has coverage enabled with `min_percent = 80` and all 5 exempt files in the exclude list
2. `gd-tools lint` exits 0
3. `gd-tools format --check` exits 0
4. `gd-tools test --coverage --min 80` exits 0
5. All 13 existing test files expanded with deeper coverage
6. Integration test files created under `tests/integration/` covering economy, assembly, and combat flows
7. Edge case tests covering berserk, decay, combo tiers, save/load, and formation grid
8. Autoload singletons tested using GUT mocking/doubling
9. Overall coverage on testable files is 80%+ (stretch: 95%+)
</protect>
