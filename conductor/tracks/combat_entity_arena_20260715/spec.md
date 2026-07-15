# Track Specification: TRACK-005 — Combat Entity & Arena Foundation

## Overview

TRACK-005 establishes the combat scene foundation for Chimera Gladiator Manager. It creates the arena scene (`arena.tscn`) and the chimera combat entity (`chimera_entity.tscn`) with all child nodes, sprite composition, movement, collision layers, damage resolution, and formation grid mapping. This track bridges the data layer (TRACK-002–004) and the AI/ability systems (TRACK-006–008) by providing the physical combat entities and arena that those systems will operate on.

**Track Type:** Feature  
**Milestone:** 3 — Combat Core  
**Dependencies:** TRACK-002 (Data Models & Enums)  
**Estimated Effort:** 3-4 Days

## Context Anchors

- **GDD Reference:** Section 2.4 (Combat Model — real-time free movement, Speed-governed; Attack Range from ARMS; Damage = Atk - Def min 1; 60s timer; HP% win condition; 3x3 formation grid pre-match only), Section 2.1 (stat roles: HP from TORSO, Attack from ARMS, Speed from LEGS, Defense from TORSO+HEAD), Section 3.1 (body includes head area, detail layered on top)
- **TDD Reference:** Section 6 (Combat System — Arena scene, ChimeraEntity node structure, Movement, Collision Layers, Damage Resolution, Attack Cadence, Win Condition), Section 10 (ChimeraSprite Composition — 8 layers, STRAIN_TO_COLOR)

## Functional Requirements

### FR-1: Arena Scene (`scenes/combat/arena.tscn`)
- **Arena (Node2D):** Root node
- **TileMap:** Background using TRACK-001 Roguelike RPG TileSet for floor and wall tiles
- **FormationGridPlayer (Node2D):** Visual grid for player-side pre-match positioning (9 cells)
- **FormationGridEnemy (Node2D):** Visual grid for enemy-side pre-match positioning (9 cells)
- **Entities (Node2D):** Container for spawned ChimeraEntity instances
- **CombatHUD (CanvasLayer):** Stub — minimal placeholder for TRACK-014
- **ArenaController (script):** Scene-level controller for arena setup (entity spawning, grid init). Does NOT manage match lifecycle — that is CombatManager's role (TRACK-008)

### FR-2: Chimera Entity Scene (`scenes/combat/chimera_entity.tscn`)
CharacterBody2D with composited nodes:
- **ChimeraSprite (Node2D):** 8 layered Sprite2D nodes (Body=0, Legs=1, Arms=2, Detail=3, Eyes=4, Mouth=5, Nose=6, Eyebrows=7). Sprite paths constructed from `shape_id` + `STRAIN_TO_COLOR`
- **AttackRange (Area2D):** Circle CollisionShape2D matching ARMS `attack_range`. Layer 4, masks opposing team's layer
- **BodyCollision (CollisionShape2D):** Physical collision. Layer 1 (Player) or 2 (Enemy) by team
- **HealthBar (Sprite2D):** Minimal stub — class_name only
- **StatusEffects (Node2D):** Minimal stub — class_name only
- **AIController (Node):** Interface stub with method signatures from TDD Section 7: `change_state(new_state: String) -> void`, `acquire_target() -> ChimeraEntity`, `_process(delta: float) -> void` — all returning defaults
- **AbilityComponent (Node):** Interface stub with method signatures from TDD Section 8: `initialize(abilities: Array[AbilityData]) -> void`, `is_off_cooldown(ability_id: String) -> bool`, `get_ready_abilities() -> Array[AbilityData]`, `execute_ability(ability_id: String) -> void`, `apply_passives(combat_state: CombatState) -> void`, `update_cooldowns(delta: float) -> void` — all returning defaults
- **EffectComponent (Node):** Full implementation — reused from TRACK-002 as-is. Ticked each frame by ChimeraEntity
- **VFXSpawner (Node2D):** Minimal stub — class_name only
- **CombatState (RefCounted):** Reference to transient combat state. Extended from TRACK-002 to include `attack_range` snapshot

### FR-3: ChimeraSprite Composition
- **STRAIN_TO_COLOR:** Undead=dark, Robotic=white, Draconic=red, Beast=green, Elemental=blue, Aberrant=yellow, Neutral=grey
- **Sprite path:** `res://assets/kenney-monster-builder-pack/PNG/Default/{shape_id}_{color}.png`
- **Z-order:** Body=0, Legs=1, Arms=2, Detail=3, Eyes=4, Mouth=5, Nose=6, Eyebrows=7
- Cosmetic layers (Eyes/Mouth/Nose/Eyebrows) are visual-only, no gameplay effect

### FR-4: Movement
- `move_toward_target(target_position: Vector2)` — sets `velocity = direction * speed`, calls `move_and_slide()`
- **No double-delta bug:** `move_and_slide()` applies delta internally. Do NOT multiply velocity by delta
- Speed comes from CombatState.speed (snapshotted from ChimeraData.speed, derived from LEGS part)

### FR-5: Collision Layers
| Layer | Name | Purpose |
|---|---|---|
| 1 | Player Chimeras | Player-side combat entities |
| 2 | Enemy Chimeras | Enemy-side combat entities |
| 3 | Arena Boundaries | Walls/edges |
| 4 | Attack Hitboxes | Area2D attack ranges |
- Entity uses layer 1 or 2 by team. AttackRange uses layer 4, masks opposing team. Boundaries use layer 3.

### FR-6: Damage Resolution
- **Formula:** `max(1.0, effective_attack - effective_defense)`
- **Berserk:** Attacker berserk → +50% attack. Defender berserk → -30% defense
- **Effects:** `EffectComponent.get_modified_stat()` applied to both attack and defense
- **Signature:** `calculate_damage(attacker: ChimeraEntity, defender: ChimeraEntity) -> float`

### FR-7: Attack Cadence
- **Interval:** `1.0 / (speed * ATTACK_RATE_CONSTANT)`
- **ATTACK_RATE_CONSTANT = 0.1** (speed=10 → 1 attack/sec)
- **MELEE_THRESHOLD = 48.0** (melee ≤48px, ranged >48px; cleanly separates 32px melee from 96px ranged parts)

### FR-8: CombatState Extension
- **New property:** `attack_range: float` — snapshotted from `ChimeraData.attack_range` in `initialize()`
- Updated `initialize()` to also snapshot attack_range alongside existing stats (max_hp, attack, defense, speed)
- All other CombatState properties/methods unchanged from TRACK-002

### FR-9: Arena Dimensions (Resolves TDD Gap 9)
- **Play area:** 640x360 pixels
- **Background:** TileMap using TRACK-001 Roguelike RPG TileSet

### FR-10: Formation Grid Mapping (Resolves TDD Gap 8)
- **Cell size:** 64x64px (accommodates ~64px chimera sprites)
- **Player grid:** Origin (32, 84). Spans x=32–224, y=84–276
- **Enemy grid:** Origin (416, 84). Spans x=416–608, y=84–276
- **Center engagement zone:** 192px wide (x=224–416)
- **Layout:** Row 0=BACK (top), Row 1=MID, Row 2=FRONT (bottom). Col 0=LEFT, Col 1=CENTER, Col 2=RIGHT
- **Function:** `grid_to_world(row: int, col: int, is_player: bool) -> Vector2` — returns cell center
- **Player cell centers:** y: BACK=116, MID=180, FRONT=244. x: LEFT=64, CENTER=128, RIGHT=192
- **Enemy cell centers:** y: BACK=116, MID=180, FRONT=244. x: LEFT=448, CENTER=512, RIGHT=576

## Non-Functional Requirements

### NFR-1: Performance
- No node instantiation in `_process`/`_physics_process`
- EffectComponent.tick() called once per frame per entity
- AttackRange uses circle shape (efficient overlap detection)

### NFR-2: Architecture Compliance
- ChimeraData (persistent) vs CombatState (transient) separation maintained
- Movement: `velocity = direction * speed` then `move_and_slide()` — no delta multiplication
- EffectComponent reused from TRACK-002 without modification
- Collision layers match TDD Section 6
- Autoload order unchanged: EventBus -> GameState -> SaveManager -> CombatManager

### NFR-3: Code Quality
- Strict typing on all new code. `##` doc comments on public functions. snake_case naming, class_name declarations
- Constants in SCREAMING_SNAKE_CASE: ATTACK_RATE_CONSTANT, MELEE_THRESHOLD

### NFR-4: Testability
- calculate_damage, move_toward_target, grid_to_world are unit-testable in isolation
- Formation grid mapping testable without scene instantiation

## Acceptance Criteria

1. `arena.tscn` loads with TileMap background, formation grids, entities container, ArenaController
2. `chimera_entity.tscn` instantiates as CharacterBody2D with all child nodes (ChimeraSprite with 8 Sprite2Ds, AttackRange, BodyCollision, HealthBar, StatusEffects, AIController, AbilityComponent, EffectComponent, VFXSpawner)
3. ChimeraSprite renders 8 layers in correct z-order with correct sprite paths per shape_id + strain color
4. `move_toward_target()` sets velocity without delta multiplication; entity moves via `move_and_slide()`
5. `calculate_damage()` returns max(1.0, atk - def) with berserk modifiers (+50% atk, -30% def) and EffectComponent modifiers
6. Collision layers: entity on 1/2 by team, AttackRange on 4 masking opposing, boundaries on 3
7. Attack cadence timer fires at interval = 1.0 / (speed * 0.1)
8. `CombatState.initialize()` snapshots attack_range from ChimeraData
9. Arena play area is 640x360px with TileMap background
10. `grid_to_world(row, col, is_player)` returns correct Vector2 for all 9 cells per side (18 total)
11. AIController and AbilityComponent stubs have method signatures matching TDD Sections 7 and 8, returning defaults
12. `gd-tools lint` and `gd-tools format --check` pass with zero errors

## Out of Scope

- AI state machine implementation (FSM states, transitions, targeting) — TRACK-006
- Ability execution engine (AbilitySystem, effect execution, cooldowns) — TRACK-007
- CombatManager match lifecycle (start_match, timer, win condition, end_match) — TRACK-008
- Combat HUD (HP bars, timer, status icons, combat log) — TRACK-014
- VFX system (CPUParticles2D, strain-themed particles) — TRACK-014
- Enemy generation — TRACK-008
- Pre-match formation UI — TRACK-013
- Specific ability/effect values — deferred to balancing
