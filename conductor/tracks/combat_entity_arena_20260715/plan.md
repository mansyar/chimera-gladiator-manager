<protect>

# Implementation Plan: TRACK-005 — Combat Entity & Arena Foundation

## Phase 1: Scenes & ChimeraSprite Composition

- [x] Task: Read spec.md and workflow.md to refresh context before starting Phase 1 implementation

- [x] Task: Extend CombatState with attack_range property [ecf4de7]
    - [x] Write failing test: `initialize()` snapshots `attack_range` from `ChimeraData.attack_range`
    - [x] Implement: add `attack_range: float` property to CombatState, update `initialize()` to snapshot it
    - [x] Run tests and verify all pass (including existing TRACK-002 CombatState tests)
    - [x] Verify coverage >= 80%

- [x] Task: Create ChimeraSprite composition script (`scripts/combat/chimera_sprite.gd`) [e75bfc4]
    - [x] Write failing tests: `STRAIN_TO_COLOR` mapping returns correct color names for all 7 strains; `get_sprite_path()` constructs correct paths from shape_id + strain
    - [x] Implement: `chimera_sprite.gd` with `STRAIN_TO_COLOR` dict, `get_sprite_path()`, 8-layer Sprite2D setup with z-order (Body=0 through Eyebrows=7)
    - [x] Run tests and verify pass
    - [x] Verify coverage >= 80%

- [x] Task: Create AIController interface stub (`scripts/combat/ai_controller.gd`) [0df381c]
    - [x] Write failing tests: `change_state()` does not error; `acquire_target()` returns null; `_process()` does not error
    - [x] Implement: `ai_controller.gd` with method signatures from TDD Section 7 returning defaults
    - [x] Run tests and verify pass

- [x] Task: Create AbilityComponent interface stub (`scripts/combat/ability_component.gd`) [8a8ec6a]
    - [x] Write failing tests: `is_off_cooldown()` returns false; `get_ready_abilities()` returns empty array; `initialize()` does not error
    - [x] Implement: `ability_component.gd` with method signatures from TDD Section 8 returning defaults
    - [x] Run tests and verify pass

- [x] Task: Create minimal stub scripts (no testable logic — TDD exempt) [05ab160]
    - [x] Implement: `scripts/combat/health_bar.gd` (class_name only)
    - [x] Implement: `scripts/combat/status_effects.gd` (class_name only)
    - [x] Implement: `scripts/combat/vfx_spawner.gd` (class_name only)
    - [x] Implement: `scripts/combat/combat_hud.gd` (class_name only, CanvasLayer stub)

- [x] Task: Create chimera_entity.tscn scene (`scenes/combat/chimera_entity.tscn`) [a42c823]
    - [x] Build CharacterBody2D scene tree per FR-2: ChimeraSprite (8 Sprite2Ds), AttackRange (Area2D + CircleShape2D), BodyCollision, HealthBar, StatusEffects, AIController, AbilityComponent, EffectComponent, VFXSpawner
    - [x] Configure collision layers per FR-5: entity layer 1 or 2 (set by team), AttackRange layer 4 masking opposing team
    - [x] Attach scripts to appropriate nodes
    - [x] Implement: `scripts/combat/chimera_entity.gd` with CombatState reference, EffectComponent tick in `_process`

- [x] Task: Create arena.tscn scene (`scenes/combat/arena.tscn`) [36a0a79]
    - [x] Build Arena (Node2D) scene tree per FR-1: TileMap, FormationGridPlayer, FormationGridEnemy, Entities, CombatHUD (CanvasLayer), ArenaController
    - [x] Configure TileMap with TRACK-001 Roguelike RPG TileSet
    - [x] Implement: `scripts/combat/arena_controller.gd` (scene-level setup, grid init placeholder)

- [x] Task: Conductor - User Manual Verification 'Phase 1: Scenes & ChimeraSprite Composition' (Protocol in workflow.md) [4774662]

## Phase 2: Movement & Damage

- [x] Task: Read spec.md and workflow.md to refresh context before starting Phase 2 implementation

- [x] Task: Implement movement system [0032ebf]
    - [ ] Write failing tests: `move_toward_target()` sets `velocity` to `direction * speed` without multiplying by delta
    - [ ] Implement: `move_toward_target(target_position: Vector2)` in `chimera_entity.gd` — calls `move_and_slide()`
    - [ ] Run tests and verify pass
    - [ ] Verify coverage >= 80%

- [x] Task: Implement damage resolution [ea8b70d]
    - [ ] Write failing tests: `calculate_damage()` normal case (atk - def, min 1); berserk attacker (+50% atk); berserk defender (-30% def); both berserk; EffectComponent modifiers applied to both attack and defense
    - [ ] Implement: `calculate_damage(attacker: ChimeraEntity, defender: ChimeraEntity) -> float` in `chimera_entity.gd`
    - [ ] Run tests and verify pass
    - [ ] Verify coverage >= 80%

- [x] Task: Implement attack cadence [63017fa]
    - [ ] Write failing tests: interval = `1.0 / (speed * ATTACK_RATE_CONSTANT)` with RATE=0.1; timer resets after firing
    - [ ] Implement: attack cadence timer in `chimera_entity.gd` with `ATTACK_RATE_CONSTANT = 0.1` and `MELEE_THRESHOLD = 48.0` constants
    - [ ] Run tests and verify pass
    - [ ] Verify coverage >= 80%

- [ ] Task: Conductor - User Manual Verification 'Phase 2: Movement & Damage' (Protocol in workflow.md)

## Phase 3: Arena & Formation Grid

- [ ] Task: Read spec.md and workflow.md to refresh context before starting Phase 3 implementation

- [ ] Task: Configure arena dimensions and background
    - [ ] Set arena play area to 640x360px (TileMap size, boundary walls)
    - [ ] Configure TileMap background with TRACK-001 Roguelike RPG TileSet (floor + wall tiles)
    - [ ] Add arena boundary StaticBody2D walls on layer 3

- [ ] Task: Implement formation grid mapping
    - [ ] Write failing tests: `grid_to_world()` returns correct Vector2 for all 9 player cells (BACK/MID/FRONT × LEFT/CENTER/RIGHT) and all 9 enemy cells (18 total positions)
    - [ ] Implement: `grid_to_world(row: int, col: int, is_player: bool) -> Vector2` as a static/pure function in `arena_controller.gd` (testable without scene instantiation)
    - [ ] Run tests and verify pass
    - [ ] Verify coverage >= 80%

- [ ] Task: Conductor - User Manual Verification 'Phase 3: Arena & Formation Grid' (Protocol in workflow.md)

</protect>
