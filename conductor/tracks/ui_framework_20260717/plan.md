<protect>
# Implementation Plan: UI Framework & Screen Manager (TRACK-009)

## Phase 1: UI Framework (ScreenManager, main.tscn, Theme, Stubs)

- [ ] Task: Read spec.md and workflow.md to refresh context before implementation
    - [ ] Read `conductor/tracks/ui_framework_20260717/spec.md`
    - [ ] Read `conductor/workflow.md`

- [ ] Task: Create Theme resource
    - [ ] Create `scenes/ui/default_theme.tres` with Kenney Future Regular font as default for all Control types
    - [ ] Configure Grey NinePatchRect StyleBoxTexture for Button (normal, hover, pressed states) using UI Pack grey button sprites
    - [ ] Configure Grey NinePatchRect StyleBoxTexture for Panel using UI Pack grey panel sprites
    - [ ] Assign Theme as default project theme in `project.godot` (`gui/theme/custom`)

- [ ] Task: Create 9 screen stub scenes and scripts
    - [ ] Create `scenes/ui/screens/lab_hub.tscn` + `scripts/ui/screens/lab_hub.gd` (centered "Lab Hub" label + 8 navigation buttons calling `ScreenManager.change_screen`)
    - [ ] Create `scenes/ui/screens/assembly.tscn` + `scripts/ui/screens/assembly.gd` (label + "Back to Lab Hub" button)
    - [ ] Create `scenes/ui/screens/black_market.tscn` + `scripts/ui/screens/black_market.gd` (label + back button)
    - [ ] Create `scenes/ui/screens/arena_pre_match.tscn` + `scripts/ui/screens/arena_pre_match.gd` (label + back button)
    - [ ] Create `scenes/ui/screens/arena_combat.tscn` + `scripts/ui/screens/arena_combat.gd` (label + back button)
    - [ ] Create `scenes/ui/screens/roster.tscn` + `scripts/ui/screens/roster.gd` (label + back button)
    - [ ] Create `scenes/ui/screens/clinic.tscn` + `scripts/ui/screens/clinic.gd` (label + back button)
    - [ ] Create `scenes/ui/screens/tournament.tscn` + `scripts/ui/screens/tournament.gd` (label + back button)
    - [ ] Create `scenes/ui/screens/hall_of_fame.tscn` + `scripts/ui/screens/hall_of_fame.gd` (label + back button)

- [ ] Task: Implement ScreenManager (TDD)
    - [ ] Write failing tests in `tests/ui/test_screen_manager.gd`: (1) `change_screen` loads correct PackedScene for all 9 screen names, (2) `change_screen` frees previous screen via `queue_free`, (3) Lab Hub is default initial screen on `_ready`
    - [ ] Run tests and confirm they fail (Red phase)
    - [ ] Implement `scripts/ui/screen_manager.gd`: `screens` Dictionary with 9 preloaded PackedScenes, `change_screen(screen_name)` method (free old, instantiate new, emit `screen_change_requested`), `current_screen` property, Lab Hub as initial screen
    - [ ] Run tests and confirm they pass (Green phase)
    - [ ] Verify coverage ≥ 80% for `screen_manager.gd`

- [ ] Task: Create main.tscn scene structure
    - [ ] Create `scenes/main.tscn`: root `Main` (Control) with `ScreenManager` (Control) and `TopBar` (Control) children
    - [ ] Configure layout: TopBar anchored to top, ScreenManager fills remaining space
    - [ ] Set `scenes/main.tscn` as project main scene in `project.godot`

- [ ] Task: Conductor - User Manual Verification 'Phase 1' (Protocol in workflow.md)

## Phase 2: Reusable Widgets

- [ ] Task: Read spec.md and workflow.md to refresh context before implementation
    - [ ] Read `conductor/tracks/ui_framework_20260717/spec.md`
    - [ ] Read `conductor/workflow.md`

- [ ] Task: Write failing tests for all 4 widgets (TDD Red phase)
    - [ ] Create `tests/ui/test_part_slot.gd`: test `part_data` set → correct sprite path via `PartDatabase.get_sprite_path()`, slot label displays correct slot name
    - [ ] Create `tests/ui/test_stat_display.gd`: test `stat_name` + `stat_value` render as "Name: Value"
    - [ ] Create `tests/ui/test_chimera_card.gd`: test `chimera` set → nickname + HP/Atk/Def/Spd displayed, instability label mapping (0=Pure, 1=Stable Hybrid, 2=Volatile Hybrid, 3=Chaotic)
    - [ ] Create `tests/ui/test_formation_grid.gd`: test 9 cells rendered in 3×3 layout, occupied cells highlighted when `grid_data` set
    - [ ] Run all widget tests and confirm they fail (Red phase)

- [ ] Task: Implement part_slot widget (TDD Green phase)
    - [ ] Create `scenes/ui/widgets/part_slot.tscn` + `scripts/ui/widgets/part_slot.gd` with `@export var part_data: PartData`, TextureRect for sprite, Label for slot type
    - [ ] Run `test_part_slot.gd` and confirm pass

- [ ] Task: Implement stat_display widget (TDD Green phase)
    - [ ] Create `scenes/ui/widgets/stat_display.tscn` + `scripts/ui/widgets/stat_display.gd` with `@export var stat_name: String`, `@export var stat_value: float`, renders as "Name: Value"
    - [ ] Run `test_stat_display.gd` and confirm pass

- [ ] Task: Implement chimera_card widget (TDD Green phase)
    - [ ] Create `scenes/ui/widgets/chimera_card.tscn` + `scripts/ui/widgets/chimera_card.gd` with `@export var chimera: ChimeraData`, displays nickname + HP/Atk/Def/Spd + instability label
    - [ ] Implement instability label helper: 0→"Pure", 1→"Stable Hybrid", 2→"Volatile Hybrid", 3→"Chaotic" (per GDD Section 2.2)
    - [ ] Run `test_chimera_card.gd` and confirm pass

- [ ] Task: Implement formation_grid widget (TDD Green phase)
    - [ ] Create `scenes/ui/widgets/formation_grid.tscn` + `scripts/ui/widgets/formation_grid.gd` with `@export var grid_data: Array`, renders 9 cells in 3×3 GridContainer, highlights occupied cells
    - [ ] Run `test_formation_grid.gd` and confirm pass

- [ ] Task: Verify widget coverage and refactor
    - [ ] Run `gd-tools test --coverage --min 80` and confirm all widget scripts ≥ 80% coverage
    - [ ] Refactor if needed (deduplicate, clarify names) — rerun tests

- [ ] Task: Conductor - User Manual Verification 'Phase 2' (Protocol in workflow.md)

## Phase 3: TopBar & UI Sounds

- [ ] Task: Read spec.md and workflow.md to refresh context before implementation
    - [ ] Read `conductor/tracks/ui_framework_20260717/spec.md`
    - [ ] Read `conductor/workflow.md`

- [ ] Task: Write failing tests for TopBar (TDD Red phase)
    - [ ] Create `tests/ui/test_top_bar.gd`: (1) Gold label updates when `EventBus.gold_changed` fires, (2) Infamy label updates when `EventBus.infamy_changed` fires, (3) initial values read from `GameState.gold` (200) and `GameState.infamy` (0) on `_ready`
    - [ ] Run tests and confirm they fail (Red phase)

- [ ] Task: Implement TopBar (TDD Green phase)
    - [ ] Create `scripts/ui/top_bar.gd`: Gold and Infamy Labels, connect to `EventBus.gold_changed` and `EventBus.infamy_changed` in `_ready()`, read initial values from `GameState`
    - [ ] Add TopBar node to `scenes/main.tscn` (replace placeholder)
    - [ ] Run `test_top_bar.gd` and confirm pass
    - [ ] Verify coverage ≥ 80% for `top_bar.gd`

- [ ] Task: Implement UI sound system
    - [ ] Create `scripts/ui/ui_sounds.gd` utility: load 6 OGG files (click ×2, switch ×2, tap ×2) from `assets/kenney-ui-pack/Sounds/` as AudioStream resources, `play_sound(sound_name: String)` method using an AudioStreamPlayer
    - [ ] Write tests for `ui_sounds.gd`: verify sound loading, verify `play_sound` calls AudioStreamPlayer
    - [ ] Wire 'switch' sound to `ScreenManager.change_screen()`
    - [ ] Wire 'click' sound to button presses (via Theme default or shared helper)
    - [ ] Run tests and confirm pass

- [ ] Task: Final verification and integration
    - [ ] Run `gd-tools lint` — must exit 0
    - [ ] Run `gd-tools format --check` — must exit 0
    - [ ] Run `gd-tools test --coverage --min 80` — must exit 0
    - [ ] Verify all 9 screens transition correctly, TopBar updates live, sounds play

- [ ] Task: Conductor - User Manual Verification 'Phase 3' (Protocol in workflow.md)
</protect>
