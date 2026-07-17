<protect>
# Implementation Plan: TRACK-010 — Lab Hub & Roster Screens

> **Status:** Pending
> **Spec:** [./spec.md](./spec.md)
> **Workflow:** Conductor TDD (Red → Green → Refactor → Verify Coverage → Commit → Git Notes)

## Phase 1: ChimeraSprite Composition Node [checkpoint: c7ea495]

*Foundational reusable visual node. Roster (Phase 3) depends on it. Built first.*

- [x] Task: Read [./spec.md](./spec.md) and [../../workflow.md](../../workflow.md) to refresh context before starting this phase
- [x] Task: Write failing tests for ChimeraSprite composition (Red) [5464ed9]
    - [x] Test `get_sprite_path()` returns correct path per strain (all 7 strains incl. NEUTRAL→dark)
    - [x] Test `set_from_parts()` populates the 4 part-derived layers (Body←TORSO, Legs←LEGS, Arms←ARMS, Detail←HEAD) with the correct textures
    - [x] Test layer z-order: Body=0, Legs=1, Arms=2, Detail=3, Eyes=4, Mouth=5, Nose=6, Eyebrows=7
    - [x] Test cosmetic layers (Eyes/Mouth/Nose/Eyebrows) show no sprite when unset
    - [x] Test node works without `CombatState`/`ChimeraEntity` (pure visual, UI-usable)
- [x] Task: Implement ChimeraSprite composition node (Green) [5464ed9]
    - [x] Extend `scripts/combat/chimera_sprite.gd` (existing stub) — keep `STRAIN_TO_COLOR` + `get_sprite_path()`
    - [x] Add 8 `Sprite2D` children with fixed z-order (Body/Legs/Arms/Detail/Eyes/Mouth/Nose/Eyebrows)
    - [x] Implement `set_from_parts(chimera_data: ChimeraData) -> void` — loads each part layer's texture via `get_sprite_path(shape_id, strain)`
    - [x] Create `scenes/lab/chimera_sprite.tscn` scene packaging the node (matches TDD Section 2 intended location)
    - [x] Run tests, confirm Green
- [x] Task: Refactor ChimeraSprite for clarity (Optional) [5464ed9]
    - [x] Extract layer-name/z-order constants, deduplicate texture loading
    - [x] Rerun tests, confirm still Green
- [x] Task: Verify coverage for ChimeraSprite [5464ed9]
    - [x] Run `gd-tools test --coverage --min 80`, confirm ChimeraSprite ≥ 80%
- [x] Task: Commit & attach git note for ChimeraSprite [5464ed9]
    - [x] Stage changes, commit `feat(ui): Implement reusable ChimeraSprite composition node`
    - [x] Attach task summary git note to commit
    - [x] Mark task `[x]` with commit SHA in plan.md, commit plan update
- [ ] Task: Conductor - User Manual Verification 'ChimeraSprite Composition Node' (Protocol in workflow.md)

## Phase 2: Lab Hub Screen

*Main navigation hub. Independent of ChimeraSprite. Uses existing `chimera_card` widget + `GameState.roster`.*

- [ ] Task: Read [./spec.md](./spec.md) and [../../workflow.md](../../workflow.md) to refresh context before starting this phase
- [ ] Task: Write failing tests for Lab Hub (Red)
    - [ ] Test Lab Hub populates exactly 3 `chimera_card` widgets from `GameState.roster`
    - [ ] Test each card displays nickname + HP/Atk/Def/Spd + instability label matching its `ChimeraData`
    - [ ] Test all 7 navigation buttons call `change_screen()` with the correct screen name
    - [ ] Test Quick Match button calls `change_screen("arena_pre_match")`
    - [ ] Test Lab Hub does NOT instantiate its own Gold/Infamy labels (relies on TopBar)
    - [ ] Test navigation plays click sound (mock/verify `play_click` invoked)
- [ ] Task: Implement Lab Hub screen (Green)
    - [ ] Build full `scenes/ui/screens/lab_hub.tscn`: 3 chimera card slots, 7 nav buttons (Assembly, Black Market, Roster, Clinic, Tournament, Hall of Fame, Arena Pre-Match), Quick Match button
    - [ ] Implement `scripts/ui/screens/lab_hub.gd`: populate 3 `chimera_card` widgets from `GameState.roster` on `_ready()`
    - [ ] Wire each nav button's `pressed` signal → `play_click()` + `change_screen(<name>)`
    - [ ] Wire Quick Match → `change_screen("arena_pre_match")`
    - [ ] Run tests, confirm Green
- [ ] Task: Refactor Lab Hub for clarity (Optional)
    - [ ] Extract navigation button→screen mapping into a constant Dictionary
    - [ ] Rerun tests, confirm still Green
- [ ] Task: Verify coverage for Lab Hub
    - [ ] Run `gd-tools test --coverage --min 80`, confirm Lab Hub ≥ 80%
- [ ] Task: Commit & attach git note for Lab Hub
    - [ ] Stage changes, commit `feat(ui): Implement Lab Hub screen with roster cards and navigation`
    - [ ] Attach task summary git note to commit
    - [ ] Mark task `[x]` with commit SHA in plan.md, commit plan update
- [ ] Task: Conductor - User Manual Verification 'Lab Hub Screen' (Protocol in workflow.md)

## Phase 3: Roster Screen

*Detailed read-only chimera viewer. Depends on ChimeraSprite (Phase 1) + `GameState.roster`.*

- [ ] Task: Read [./spec.md](./spec.md) and [../../workflow.md](../../workflow.md) to refresh context before starting this phase
- [ ] Task: Write failing tests for Roster (Red)
    - [ ] Test Roster populates exactly 3 detailed cards from `GameState.roster`
    - [ ] Test each card's stat labels (HP/Atk/Def/Spd/Range) match `ChimeraData` derived stats
    - [ ] Test instability label matches distinct-strain count (1→Pure, 2→Stable Hybrid, 3→Volatile Hybrid, 4→Chaotic)
    - [ ] Test combo ability displayed when `ChimeraData.combo_ability != null` (2+ same-strain); absent otherwise
    - [ ] Test combo tier label (Basic/Enhanced/Ultimate) matches `combo_tier`
    - [ ] Test strain chips: exactly 4 chips, one per equipped part, colored per `STRAIN_TO_COLOR`
    - [ ] Test 4 equipped parts listed with slot label + strain + rarity
    - [ ] Test back button calls `change_screen("lab_hub")`
    - [ ] Test Roster performs no mutation on `ChimeraData`/`GameState` (view-only)
- [ ] Task: Implement Roster screen (Green)
    - [ ] Build full `scenes/ui/screens/roster.tscn`: 3 detailed card containers, each with ChimeraSprite preview area, part list, stat grid, instability label, strain chip row, decay/wins, abilities list, back button
    - [ ] Implement `scripts/ui/screens/roster.gd`: populate 3 cards from `GameState.roster` on `_ready()`
    - [ ] Integrate `ChimeraSprite` preview per card via `set_from_parts()`
    - [ ] Implement part list rendering (sprite + slot + strain + rarity per part)
    - [ ] Implement strain chip generation (4 chips colored per strain)
    - [ ] Implement abilities list (4 part abilities + combo if present, with tier label)
    - [ ] Wire back button → `change_screen("lab_hub")` + `play_click()`
    - [ ] Run tests, confirm Green
- [ ] Task: Refactor Roster for clarity (Optional)
    - [ ] Extract per-card population into a helper method; reuse instability label helper from `chimera_card`
    - [ ] Rerun tests, confirm still Green
- [ ] Task: Verify coverage for Roster
    - [ ] Run `gd-tools test --coverage --min 80`, confirm Roster ≥ 80%
- [ ] Task: Commit & attach git note for Roster
    - [ ] Stage changes, commit `feat(ui): Implement Roster screen with detailed chimera cards`
    - [ ] Attach task summary git note to commit
    - [ ] Mark task `[x]` with commit SHA in plan.md, commit plan update
- [ ] Task: Conductor - User Manual Verification 'Roster Screen' (Protocol in workflow.md)

## Phase 4: Track Verification & Definition of Done

*Cross-cutting quality gates across all new code for this track.*

- [ ] Task: Read [./spec.md](./spec.md) and [../../workflow.md](../../workflow.md) to refresh context before starting this phase
- [ ] Task: Run full quality gate suite
    - [ ] `gd-tools lint` exits 0
    - [ ] `gd-tools format --check` exits 0
    - [ ] `gd-tools test --coverage --min 80` exits 0 (all track tests + existing suite)
- [ ] Task: Verify DoD acceptance criteria
    - [ ] Confirm AC-1..AC-11 from spec.md are satisfied by tests/manual checks
- [ ] Task: Conductor - User Manual Verification 'Track Verification & DoD' (Protocol in workflow.md)
</protect>
