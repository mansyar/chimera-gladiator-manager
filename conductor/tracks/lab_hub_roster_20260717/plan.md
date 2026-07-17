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

## Phase 2: Lab Hub Screen [checkpoint: 720fba4]

*Main navigation hub. Independent of ChimeraSprite. Uses existing `chimera_card` widget + `GameState.roster`.*

- [x] Task: Read [./spec.md](./spec.md) and [../../workflow.md](../../workflow.md) to refresh context before starting this phase
- [x] Task: Write failing tests for Lab Hub (Red) [c6f7a65]
    - [x] Test Lab Hub populates exactly 3 `chimera_card` widgets from `GameState.roster`
    - [x] Test each card displays nickname + HP/Atk/Def/Spd + instability label matching its `ChimeraData`
    - [x] Test all 7 navigation buttons call `change_screen()` with the correct screen name
    - [x] Test Quick Match button calls `change_screen("arena_pre_match")`
    - [x] Test Lab Hub does NOT instantiate its own Gold/Infamy labels (relies on TopBar)
    - [x] Test navigation plays click sound (mock/verify `play_click` invoked)
- [x] Task: Implement Lab Hub screen (Green) [c6f7a65]
    - [x] Build full `scenes/ui/screens/lab_hub.tscn`: 3 chimera card slots, 7 nav buttons (Assembly, Black Market, Roster, Clinic, Tournament, Hall of Fame, Arena Pre-Match), Quick Match button
    - [x] Implement `scripts/ui/screens/lab_hub.gd`: populate 3 `chimera_card` widgets from `GameState.roster` on `_ready()`
    - [x] Wire each nav button's `pressed` signal → `play_click()` + `change_screen(<name>)`
    - [x] Wire Quick Match → `change_screen("arena_pre_match")`
    - [x] Run tests, confirm Green
- [x] Task: Refactor Lab Hub for clarity (Optional) [c6f7a65]
    - [x] Skipped — nav button→screen mapping is in .tscn signal bindings, no code constant needed (DRY)
    - [x] Rerun tests, confirm still Green
- [x] Task: Verify coverage for Lab Hub [c6f7a65]
    - [x] Run `gd-tools test --coverage --min 80`, confirm Lab Hub ≥ 80% (89.9% lines, 92.5% branches)
- [x] Task: Commit & attach git note for Lab Hub [c6f7a65]
    - [x] Stage changes, commit `feat(ui): Implement Lab Hub screen with roster cards and navigation`
    - [x] Attach task summary git note to commit
    - [x] Mark task `[x]` with commit SHA in plan.md, commit plan update
- [x] Task: Conductor - User Manual Verification 'Lab Hub Screen' (Protocol in workflow.md)

## Phase 3: Roster Screen

*Detailed read-only chimera viewer. Depends on ChimeraSprite (Phase 1) + `GameState.roster`.*

- [x] Task: Read [./spec.md](./spec.md) and [../../workflow.md](../../workflow.md) to refresh context before starting this phase
- [x] Task: Write failing tests for Roster (Red) [3e83460]
    - [x] Test Roster populates exactly 3 detailed cards from `GameState.roster`
    - [x] Test each card's stat labels (HP/Atk/Def/Spd/Range) match `ChimeraData` derived stats
    - [x] Test instability label matches distinct-strain count (1→Pure, 2→Stable Hybrid, 3→Volatile Hybrid, 4→Chaotic)
    - [x] Test combo ability displayed when `ChimeraData.combo_ability != null` (2+ same-strain); absent otherwise
    - [x] Test combo tier label (Basic/Enhanced/Ultimate) matches `combo_tier`
    - [x] Test strain chips: exactly 4 chips, one per equipped part, colored per `STRAIN_TO_COLOR`
    - [x] Test 4 equipped parts listed with slot label + strain + rarity
    - [x] Test back button calls `change_screen("lab_hub")`
    - [x] Test Roster performs no mutation on `ChimeraData`/`GameState` (view-only)
- [x] Task: Implement Roster screen (Green) [3e83460]
    - [x] Build full `scenes/ui/screens/roster.tscn`: 3 detailed card containers, each with ChimeraSprite preview area, part list, stat grid, instability label, strain chip row, decay/wins, abilities list, back button
    - [x] Implement `scripts/ui/screens/roster.gd`: populate 3 cards from `GameState.roster` on `_ready()`
    - [x] Integrate `ChimeraSprite` preview per card via `set_from_parts()`
    - [x] Implement part list rendering (sprite + slot + strain + rarity per part)
    - [x] Implement strain chip generation (4 chips colored per strain)
    - [x] Implement abilities list (4 part abilities + combo if present, with tier label)
    - [x] Wire back button → `change_screen("lab_hub")` + `play_click()`
    - [x] Run tests, confirm Green
- [x] Task: Refactor Roster for clarity (Optional) [3e83460]
    - [x] Extract per-card population into a helper method; reuse instability label helper from `chimera_card`
    - [x] Rerun tests, confirm still Green
- [x] Task: Verify coverage for Roster [3e83460]
    - [x] Run `gd-tools test --coverage --min 80`, confirm Roster ≥ 80% (83.1% lines, 90.1% branches)
- [x] Task: Commit & attach git note for Roster [3e83460]
    - [x] Stage changes, commit `feat(ui): Implement Roster screen with detailed chimera cards`
    - [x] Attach task summary git note to commit
    - [x] Mark task `[x]` with commit SHA in plan.md, commit plan update
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
