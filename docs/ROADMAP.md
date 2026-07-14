# Product Roadmap: Chimera Gladiator Manager

> **Methodology:** Context-Driven Development (CDD) via Conductor.
> **Purpose:** This document acts as the global architectural index mapping out our path from scaffolding to MVP. It serves as the single source of truth for generating discrete micro-plans.

---

## Global System Configuration & Context

Before initializing individual tracks, the following foundational context files must be present and updated in the repository:

*   **GDD Source:** `docs/GDD.md` (Defines game design, feature requirements, and player-facing logic. Serves as the PRD equivalent.)
*   **TDD Source:** `docs/TDD.md` (Defines architecture, system design, data schemas, and code patterns.)
*   **Tech Stack:** `conductor/tech-stack.md` (Defines pinned languages, frameworks, and tools.)
*   **Guidelines:** `conductor/product-guidelines.md` (Defines code style, patterns, and testing thresholds.)

**Dev Toolchain:** gd-tools CLI (`pip install gd-tools-cli`) provides test execution (wraps GUT), linting (gdlint), formatting (gdformat), and coverage reporting. All tracks use `gd-tools test`, `gd-tools lint`, `gd-tools format --check`, and `gd-tools coverage` as their verification commands. Project requires Godot 4.5+ (gd-tools minimum).

**Parallelization Notes:** Milestone 4 (UI & Management Screens) can be developed in parallel with Milestone 3 (Combat Core) once TRACK-004 is complete. TRACK-009 through TRACK-012 do not depend on combat tracks. Milestone 5 (Arena & Match Flow) depends on both combat and UI milestones.

---

## Milestone 1: Environment & Foundations

### TRACK-001: Core Project Scaffolding
*   **Status:** `Complete`
*   **Dependencies:** None
*   **Estimated Effort:** 1-2 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 1 (Executive Summary), Section 3 (Kenney Asset Mapping Index)
*   **TDD Reference:** `docs/TDD.md` Section 1 (Project Configuration), Section 2 (Directory Structure), Section 11 (Asset Pipeline)

#### Track Tech Stack
*   Godot 4.5+ (Compatibility renderer, OpenGL)
*   GDScript
*   gd-tools CLI (init, doctor)
*   Kenney asset packs (5 packs)

#### Scope Boundaries
*   **In Scope:**
    *   `project.godot` config: renderer (Compatibility), display (1280x720, min 960x540), pixel art settings (Nearest filter, snap 2D transforms, lossless compression), stretch mode (`canvas_items`, aspect `keep`)
    *   Input map: `ui_accept` (Enter/Space), `ui_cancel` (Escape), `ui_select` (LMB), `navigate_up/down/left/right` (WASD/arrows), `pause` (P only)
    *   Full directory tree creation matching TDD Section 2 exactly (scenes/, scripts/ with all subdirs, resources/ with all subdirs)
    *   Autoload registration with stub scripts: EventBus, GameState, SaveManager, CombatManager (load order: EventBus -> GameState -> SaveManager -> CombatManager)
    *   Asset import settings applied to all 5 Kenney packs (Nearest filter, lossless, mipmaps off)
    *   Kenney Future font registered as default project font in `project.godot`
    *   TileSet resource from Roguelike RPG pack spritesheet (16x16 tiles, 1px margin)
    *   `main.tscn` root scene skeleton
    *   `gd-tools init` executed (installs GUT, deploys coverage addon, generates `gd-tools.toml`, `.gutconfig.json`, `gdlintrc`, `gdformatrc`)
    *   `gd-tools doctor` passes all 9 checks
*   **Out of Scope:**
    *   Any gameplay logic (autoload stubs print ready confirmation only)
    *   Any .tres data files (content created in TRACK-003)
    *   Any scene files beyond main.tscn skeleton

#### High-Level Execution Vectors
*   **Phase 1 (Setup):** Create Godot project, configure project.godot (renderer, display, pixel art, stretch mode, input map, font), create full directory tree per TDD Section 2
*   **Phase 2 (Assets & Tools):** Copy/verify Kenney asset packs in assets/, apply import settings, create TileSet from Roguelike pack. Run `gd-tools init` to install GUT, coverage addon, and generate configs. Run `gd-tools doctor` to verify environment.
*   **Phase 3 (Autoloads):** Register 4 autoload stub scripts in correct load order, verify project boots without errors

#### Verification & Definition of Done (DoD)
*   [x] **Manual Checkpoint:** Project opens in Godot 4.5+ with zero errors. Directory structure matches TDD Section 2. Autoloads print confirmation in order on boot. Font renders as Kenney Future. Pixel art textures display with Nearest filtering. Stretch mode preserves aspect ratio on window resize.
*   [x] **Automated Tests:** `gd-tools doctor` exits 0 (all 9 checks pass). `gd-tools lint` exits 0. `gd-tools format --check` exits 0.
*   [x] **Conductor Review:** Project boots clean, directory tree verified against TDD, autoload order confirmed, gd-tools environment healthy.

---

## Milestone 2: Data Layer & Core Infrastructure

### TRACK-002: Data Models & Enums
*   **Status:** `Complete`
*   **Dependencies:** TRACK-001
*   **Estimated Effort:** 2-3 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 2.1 (Modular Fusion — 4 slots, 6 strains, stat roles), Section 2.2 (Genetic Instability — 0-3 scale, purebred bonuses), Section 2.3 (Abilities — active/passive, 11 effect types, strain combo tiers), Section 2.4 (Behavior Modules — 7 modules, 6 targeting modes, 3 positioning tendencies)
*   **TDD Reference:** `docs/TDD.md` Section 3 (Data Models — all class definitions: GameEnums, PartData, AbilityData, AbilityEffect, BehaviorModuleData, ChimeraData, CombatState, ActiveEffect, EffectComponent, PartDatabase, Stat Calculation Flow)

#### Track Tech Stack
*   GDScript, Godot Resource system (.tres-compatible classes)
*   gd-tools (test, lint, format)

#### Scope Boundaries
*   **In Scope:**
    *   `GameEnums` class: Strain (7 values incl NEUTRAL), Rarity (4), PartSlot (4), Instability (4), AbilityType (2), AbilityCategory (4), TargetingMode (6), Positioning (3)
    *   `PartData` Resource: slot, shape_id, strain, rarity, sprite_path, hp/attack/defense/speed bonuses, ability_id (String), behavior_module (HEAD only), attack_range (ARMS only)
    *   `AbilityData` Resource: id, name, description, type, category, cooldown, targeting, range, effects array
    *   `AbilityEffect` Resource: EffectType enum (11 types), params Dictionary
    *   `BehaviorModuleData` Resource: module_name, detail_type, targeting, ability_priority array, positioning
    *   `ChimeraData` Resource: nickname, 4 @export PartData vars (head/torso/arms/legs), derived stats, part_abilities, combo_ability, combo_tier, current_hp, decay_level, match_wins. Methods: get_parts(), get_part(slot), recalculate_stats(), calculate_instability(), get_combo_ability()
    *   `CombatState` RefCounted: chimera_data ref, HP/atk/def/spd snapshots, is_berserk, berserk timers, ability_cooldowns, active_effects, is_dead, team. Methods: initialize(), take_damage(), heal()
    *   `ActiveEffect` RefCounted: effect_type, stat_name, amount, duration, source_id, tick()
    *   `EffectComponent` Node: active_effects, stat_modifiers, add_effect(), tick(), recalculate_modifiers(), get_modified_stat(), cleanse()
*   **Out of Scope:**
    *   .tres data file content (created in TRACK-003)
    *   PartDatabase implementation logic (stub only — TRACK-003)
    *   Ability execution engine (created in TRACK-007)
    *   Combat/AI integration

#### High-Level Execution Vectors
*   **Phase 1 (Enums & Base Classes):** Create GameEnums, PartData, AbilityData, AbilityEffect, BehaviorModuleData. Verify inspector-editable.
*   **Phase 2 (Chimera & Combat State):** Create ChimeraData with stat calculation, CombatState, ActiveEffect. Verify recalculate_stats() and calculate_instability() produce correct values.
*   **Phase 3 (Effect Component):** Create EffectComponent. Write tests for stat modifier recalculation and effect expiration.

#### Verification & Definition of Done (DoD)
*   [x] **Manual Checkpoint:** Can create .tres instances of PartData, AbilityData, AbilityEffect, BehaviorModuleData in inspector. ChimeraData with 4 parts assigned shows correct derived stats in a test scene.
*   [x] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) recalculate_stats sums stats from 4 parts, (2) calculate_instability returns 0 for 4 same-strain, 3 for 4 different, (3) get_combo_ability returns correct tier for 2/3/4 same-strain, (4) CombatState.take_damage reduces HP and sets is_dead at 0, (5) ActiveEffect.tick returns true when expired, (6) EffectComponent.add_effect updates stat_modifiers, (7) EffectComponent.cleanse removes only debuffs.
*   [x] **Conductor Review:** All classes compile. Resource exports work in inspector. `gd-tools lint` and `gd-tools format --check` pass. Coverage >= 80%.

---

### TRACK-003: Part Database & Data Definitions
*   **Status:** `Complete`
*   **Dependencies:** TRACK-002
*   **Estimated Effort:** 4-5 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 2.1 (4 slots: 7+6+5+5=23 shape variants, 6 strains mapped to colors), Section 2.3 (23 part abilities + 18 combo abilities, ability themes per slot), Section 2.4 (7 behavior modules with targeting/priority/positioning), Section 4.1 (Starting State — 3 starter chimeras: tank/DPS/utility), Section 4.7 (4 rarity tiers: Common standard, Uncommon +25%, Rare +50%+enhanced, Legendary +100%+unique)
*   **TDD Reference:** `docs/TDD.md` Section 3 (PartDatabase class, sprite path construction), Section 11 (Monster Builder Pack naming: `{category}_{variant}_{color}.png`)

#### Track Tech Stack
*   GDScript, Godot Resource system (.tres files)
*   Kenney Monster Builder Pack (sprite references)

#### Scope Boundaries
*   **In Scope:**
    *   `PartDatabase` static class: part_templates, ability_templates Dictionaries, get_part(shape_id, strain, rarity), get_ability(ability_id), get_base_stats(shape_id), generate_random_part(slot, rarity_weights), get_strain_combo(strain, tier)
    *   23 part ability .tres files (7 head + 6 torso + 5 arms + 5 legs) with EffectType combinations matching GDD ability themes per slot
    *   18 strain combo ability .tres files (6 strains x 3 tiers) themed per GDD (Undead necrotic drain, Robotic overcharge, Draconic fury, Beast savagery, Elemental surge, Aberrant chaos)
    *   7 behavior module .tres files (Charger, Skirmisher, Caster, Controller, Sentinel, Guardian, Stalker — matching GDD Section 2.4 table)
    *   23 base part templates with correct sprite_path/ability_id/behavior_module/attack_range
    *   Rarity stat modifier system (Common x1.0, Uncommon x1.25, Rare x1.5, Legendary x2.0)
    *   3 starter chimera definitions (tank/DPS/utility roles, common rarity)
    *   Neutral strain support (no color, no combo, no bonuses, same-strain for instability)
*   **Out of Scope:**
    *   Market UI (TRACK-012), Enemy generation logic (TRACK-008), Save integration (TRACK-004)

#### High-Level Execution Vectors
*   **Phase 1 (Database):** Implement PartDatabase with template loading, lookups, generation. Write tests.
*   **Phase 2 (Abilities):** Create 23 part ability .tres files and 18 combo .tres files. Verify all load via get_ability().
*   **Phase 3 (Parts & Starters):** Create 7 behavior module .tres files, 23 base part templates, rarity system, 3 starter chimera definitions. Verify starter stats.

#### Verification & Definition of Done (DoD)
*   [x] **Manual Checkpoint:** PartDatabase loads all templates at startup. get_part("body_a", BEAST, COMMON) returns correct PartData. generate_random_part() produces valid parts. Starter chimeras instantiate with correct role-appropriate stats.
*   [x] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) get_part returns correct base stats, (2) rarity modifiers apply correctly, (3) get_ability returns all 23+18 abilities, (4) generate_random_part produces valid combinations, (5) get_strain_combo returns correct tier, (6) Neutral parts have no combo and count as same strain, (7) all 7 behavior modules match GDD Section 2.4 table values.
*   [x] **Conductor Review:** All .tres files load without errors. Sprite paths resolve to actual files. `gd-tools lint` and `gd-tools format --check` pass.

---

### TRACK-004: Singleton Architecture, Signals & Save System
*   **Status:** `Complete`
*   **Dependencies:** TRACK-002, TRACK-003
*   **Estimated Effort:** 3-4 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 4.1 (The Loop — continuous campaign, 200G start, 3 chimeras), Section 4.2 (Genetic Decay — repair costs per instability), Section 4.3 (Resources — Gold + Infamy), Section 4.5 (Research Tracks — 3 branches), Section 4.6 (Fail State — no negative Gold, salvage, rubber-band), Section 4.7 (Black Market — base+rotating stock, 4 rarity tiers, prices)
*   **TDD Reference:** `docs/TDD.md` Section 4 (Singleton Architecture — all 4 autoloads, system scripts as static utilities), Section 5 (Signal Architecture — two-tier), Section 9 (Save System — JSON, save-by-reference, triggers)

#### Track Tech Stack
*   GDScript, Godot Autoload system, JSON serialization
*   gd-tools (test, lint, format)

#### Scope Boundaries
*   **In Scope:**
    *   `EventBus` autoload: all 13 signals (gold_changed, infamy_changed, part_purchased, chimera_modified, chimera_decayed, match_started, match_ended, market_refreshed, research_unlocked, chimera_ascended, screen_change_requested, berserk_triggered, combat_log)
    *   `GameState` autoload: gold, infamy, roster (exactly 3), inventory, market_stock (base+rotating), research_progress, hall_of_fame, match_history, losing_streak. All methods (add/spend_gold, buy_part via Market utility, refresh_market, can_ascend, ascend_chimera, get_research_level). Starting state: 200G, 0 Infamy, 3 starters.
    *   System static utilities: `economy.gd` (match reward calc), `market.gd` (purchase validation, stock gen, price calc), `decay.gd` (probability/stat loss/repair cost per instability), `research.gd` (point spending, branch/node management)
    *   `SaveManager` autoload: save_game() to JSON at user://saves/, load_game() with PartDatabase reconstruction (save-by-reference), has_save(), delete_save(). Save structure per TDD Section 9. Version field with migration stub. 6 save triggers.
    *   Autoload init order verified: EventBus -> GameState -> SaveManager -> CombatManager
*   **Out of Scope:**
    *   CombatManager match logic (stub only — match_active=false)
    *   UI screens (Milestone 4), Enemy generator (TRACK-008)

#### High-Level Execution Vectors
*   **Phase 1 (Signals & State):** Implement EventBus with all signals. Implement GameState with all properties/methods. Verify starting state (200G, 0 Infamy, 3 starters).
*   **Phase 2 (System Utilities):** Implement economy.gd, market.gd, decay.gd, research.gd as pure static functions. Verify GameState delegates correctly.
*   **Phase 3 (Save System):** Implement SaveManager with JSON serialization and save-by-reference. Implement 6 save triggers. Test round-trip.

#### Verification & Definition of Done (DoD)
*   [x] **Manual Checkpoint:** New game initializes with 200G, 0 Infamy, 3 starter chimeras. buy_part deducts Gold and adds to inventory. spend_gold returns false when insufficient (no negative Gold). refresh_market generates base + 6-10 rotating parts. EventBus signals fire on all state changes.
*   [x] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) starting state correct, (2) spend_gold fails on insufficient, (3) buy_part validates via Market and updates gold+inventory, (4) refresh_market generates valid stock, (5) decay probability matches GDD 4.2 table, (6) repair cost matches GDD 4.2, (7) can_ascend true at 10+ wins, (8) ascend_chimera moves to hall_of_fame + returns 1 RP, (9) save/load round-trip preserves all state, (10) save file is valid JSON per TDD Section 9.
*   [x] **Conductor Review:** Autoload order correct. System scripts are pure static (no state). Save reconstructs via PartDatabase. `gd-tools lint` and `gd-tools format --check` pass.

---

## Milestone 3: Combat Core

### TRACK-005: Combat Entity & Arena Foundation
*   **Status:** `Pending`
*   **Dependencies:** TRACK-002
*   **Estimated Effort:** 3-4 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 2.4 (Combat Model — real-time free movement, Speed-governed; Attack Range from ARMS; Damage = Atk - Def min 1; 60s timer; HP% win condition; 3x3 formation grid pre-match only), Section 2.1 (stat roles: HP from TORSO, Attack from ARMS, Speed from LEGS, Defense from TORSO+HEAD), Section 3.1 (body includes head area, detail layered on top)
*   **TDD Reference:** `docs/TDD.md` Section 6 (Combat System — Arena scene, ChimeraEntity node structure, Movement, Collision Layers, Damage Resolution, Attack Cadence, Win Condition), Section 10 (ChimeraSprite Composition — 8 layers, STRAIN_TO_COLOR)

#### Track Tech Stack
*   GDScript, CharacterBody2D, Area2D, Sprite2D, CollisionShape2D
*   Kenney Monster Builder Pack, Roguelike RPG Pack

#### Scope Boundaries
*   **In Scope:**
    *   `arena.tscn`: Arena (Node2D) with TileMap background, FormationGridPlayer/Enemy (Node2D), Entities container, CombatHUD stub, ArenaController script
    *   `chimera_entity.tscn`: CharacterBody2D with ChimeraSprite (8 layered Sprite2Ds), AttackRange (Area2D), BodyCollision, HealthBar stub, StatusEffects stub, AIController stub, AbilityComponent stub, EffectComponent (full), VFXSpawner stub, CombatState ref
    *   ChimeraSprite: sprite path construction from shape_id + STRAIN_TO_COLOR, z-order (Body=0, Legs=1, Arms=2, Detail=3, Eyes=4, Mouth=5, Nose=6, Eyebrows=7), Default resolution
    *   Movement: `velocity = direction * speed` (move_and_slide applies delta — no double-delta bug)
    *   Collision layers: 1=Player, 2=Enemy, 3=Boundaries, 4=Attack Hitboxes. Entity uses 1 or 2 by team. AttackRange uses 4, masks opposing.
    *   Damage resolution: calculate_damage() with berserk modifiers (+50% atk, -30% def) and EffectComponent.get_modified_stat(). Min 1.
    *   Attack cadence: interval = 1.0 / (speed * ATTACK_RATE_CONSTANT)
    *   CombatState.initialize() snapshots from ChimeraData
    *   Arena dimensions: 640x360 pixel play area (resolves TDD gap 9)
    *   Formation grid cell-to-world position mapping for all 9 cells per side (resolves TDD gap 8)
*   **Out of Scope:**
    *   AI state machine (stub — TRACK-006), Ability execution (stub — TRACK-007), CombatManager lifecycle (TRACK-008), Combat HUD (TRACK-014), VFX (TRACK-014)

#### High-Level Execution Vectors
*   **Phase 1 (Scenes):** Create arena.tscn and chimera_entity.tscn with all child nodes. Configure collision layers. Implement ChimeraSprite composition with z-order.
*   **Phase 2 (Movement & Damage):** Implement move_toward_target() (no delta bug), calculate_damage() with berserk+effect modifiers, attack cadence timer.
*   **Phase 3 (Arena & Grid):** Define arena dimensions, tile background, implement formation grid-to-world mapping.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** 2 test ChimeraEntities render with correct 8-layer sprite composition. One moves toward the other at speed-based velocity. Damage calculation correct (Atk-Def, min 1). Berserk modifiers apply. Collision layers prevent friendly fire. Formation grid cells map to correct world positions.
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) calculate_damage normal, (2) calculate_damage with berserk modifiers, (3) EffectComponent.get_modified_stat, (4) CombatState.take_damage/heal, (5) move_toward_target sets velocity without double-delta, (6) all 9 grid cells map to correct Vector2.
*   [ ] **Conductor Review:** Scene trees match TDD Section 6. No delta bug. Arena dimensions defined. `gd-tools lint` and `gd-tools format --check` pass.

---

### TRACK-006: AI System (FSM)
*   **Status:** `Pending`
*   **Dependencies:** TRACK-005
*   **Estimated Effort:** 4-5 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 2.4 (Behavior Modules — 7 modules table with targeting/priority/positioning; Targeting Definitions — 6 terms; Berserk — 5s duration, check every 5s, event modifiers: HP<30% +15%, ally death immediate, disruption +10%, kill +5%; base probs: Pure 0%, Stable 3%, Volatile 8%, Chaotic 15%; effects: ignores module, nearest entity, +50% atk, -30% def, abilities random, passives active)
*   **TDD Reference:** `docs/TDD.md` Section 7 (AI System — FSM architecture, state flow, positioning behavior code, target selection code, ability priority code, berserk state code)

#### Track Tech Stack
*   GDScript, custom FSM pattern (AIState base + state scripts)
*   gd-tools (test, lint, format)

#### Scope Boundaries
*   **In Scope:**
    *   `AIController` node: current_state, behavior_module, combat_state, target, states Dictionary, change_state(), _process delegates, acquire_target()
    *   `AIState` base class: enter(), update(delta), exit()
    *   7 state scripts: idle, acquire_target (handles no-target->IDLE), move_to_target (positioning-aware), attack, use_ability (delegates to AbilityComponent stub), berserk (5s->ACQUIRE_TARGET), dead (terminal)
    *   Positioning behavior: get_move_position() with 3 modes (FRONT: melee close/ranged kite; MID: hold at range/hit-and-run; BACK: flee/hold). Per-module tendencies matching GDD Section 2.4.
    *   Target selection: 6 targeting functions (nearest, lowest_hp_in_range, highest_attack, highest_attack_targeting_ally, enemy_attacking_ally, lowest_hp)
    *   Ability priority: get_next_ready_ability() checks in ability_priority order (stub — delegates to AbilityComponent)
    *   Berserk: check_berserk() with 5s timer, base probability by instability, event modifiers (accumulate, reset after roll). enter_berserk() applies effects. 5s duration -> ACQUIRE_TARGET. Purebreds immune.
*   **Out of Scope:**
    *   Ability execution (USE_ABILITY delegates to stub — TRACK-007), CombatManager integration (TRACK-008), Visual berserk indicators (TRACK-014)

#### High-Level Execution Vectors
*   **Phase 1 (FSM Framework):** Create AIController, AIState base, 7 state scripts with transitions. Verify flow: IDLE->ACQUIRE_TARGET->MOVE->IN_RANGE->ATTACK->repeat.
*   **Phase 2 (Positioning & Targeting):** Implement get_move_position() with 3 modes + melee/ranged. Implement 6 targeting functions. Verify distinct behavior per module.
*   **Phase 3 (Berserk):** Implement check_berserk() with timer, probability, modifiers. Implement berserk state. Verify purebreds immune, probabilities match GDD, modifiers reset after roll.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** 3 chimeras with different modules show distinct behavior (Charger rushes, Caster maintains distance, Guardian holds position). Each acquires targets per its mode. Berserk triggers on unstable chimeras (not purebreds), lasts 5s, applies +50% atk/-30% def. Stalker flanks to reach lowest-HP target.
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) FSM transitions correctly, (2) ACQUIRE_TARGET returns null->IDLE when no enemies, (3-5) get_move_position for FRONT melee/ranged and BACK ranged, (6) all 6 targeting functions return correct entity, (7) berserk probability matches GDD table, (8) event modifiers accumulate+reset, (9) purebreds never berserk, (10) berserk->ACQUIRE_TARGET after 5s, (11) ability priority respects ordering.
*   [ ] **Conductor Review:** FSM matches TDD Section 7 flow diagram. Positioning tendencies match GDD Section 2.4 table. Berserk probabilities/modifiers match GDD exactly. `gd-tools lint` and `gd-tools format --check` pass.

---

### TRACK-007: Ability & Effect System
*   **Status:** `Pending`
*   **Dependencies:** TRACK-002, TRACK-003, TRACK-005
*   **Estimated Effort:** 2-3 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 2.3 (Abilities — 1 per part, active/passive mix, no cap, HEAD module determines priority; strain combos: 2+ same-strain unlocks 5th, Basic/Enhanced/Ultimate scaling, 6 themes), Section 2.4 (Berserk — passives remain active, active abilities fire randomly)
*   **TDD Reference:** `docs/TDD.md` Section 8 (Ability System — AbilityComponent, effect execution for 11 EffectTypes, passive application, strain combo dynamic lookup)

#### Track Tech Stack
*   GDScript, Godot Node system (AbilityComponent on ChimeraEntity)
*   gd-tools (test, lint, format)

#### Scope Boundaries
*   **In Scope:**
    *   `AbilityComponent` node: abilities array, cooldowns Dictionary (keyed by ability.id), initialize(), is_off_cooldown(), get_ready_abilities(), execute_ability(), apply_passives(), update_cooldowns()
    *   `AbilitySystem` static class: execute_effect() for all 11 EffectTypes (DAMAGE, HEAL, BUFF_STAT, DEBUFF_STAT, REPOSITION, SHIELD, CLEANSE, REVIVE, ENRAGE, STAT_MUTATION, RANDOM_EFFECT). Creates ActiveEffect instances or modifies CombatState directly.
    *   Passive application: apply_passives() at combat start after CombatState.initialize(). Modifies snapshots. Persists during berserk.
    *   Strain combo dynamic lookup: get_combo_ability() counts strains, determines dominant, looks up via PartDatabase.get_strain_combo(strain, tier). Tier = count-1 (2->Basic, 3->Enhanced, 4->Ultimate).
    *   Cooldown tracking: update_cooldowns(delta) ticks all. is_off_cooldown checks cooldowns[ability.id] <= 0.
    *   Ability priority integration: get_ready_abilities() filtered by behavior_module.ability_priority order.
*   **Out of Scope:**
    *   .tres ability data files (TRACK-003), AI state machine (TRACK-006), VFX (TRACK-014), specific values/balancing

#### High-Level Execution Vectors
*   **Phase 1 (Component & Cooldowns):** Implement AbilityComponent with initialize, is_off_cooldown, get_ready_abilities, update_cooldowns. Verify cooldowns tick and block execution.
*   **Phase 2 (Effect Execution):** Implement AbilitySystem.execute_effect() for all 11 EffectTypes. Verify each creates correct ActiveEffect or modifies CombatState.
*   **Phase 3 (Passives & Combos):** Implement apply_passives() at combat start. Implement strain combo lookup. Verify passives persist during berserk, combos unlock at correct thresholds.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** Chimera uses abilities in priority order during combat. Active abilities go on cooldown. Passives apply at combat start and persist. Strain combo unlocks at 2+ same-strain. Combo tier upgrades at 3/4 same-strain. BUFF_STAT creates visible modifier that expires.
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) DAMAGE reduces HP, (2) HEAL caps at max_hp, (3) BUFF_STAT creates ActiveEffect, (4) DEBUFF_STAT creates negative ActiveEffect, (5) SHIELD creates SHIELD effect, (6) CLEANSE removes debuffs, (7) apply_passives modifies CombatState, (8) passives persist when is_berserk, (9) combo tiers: 2=Basic, 3=Enhanced, 4=Ultimate, null for all-different, (10) is_off_cooldown false after execute, true after expiry, (11) get_ready_abilities respects priority.
*   [ ] **Conductor Review:** All 11 EffectTypes handled. Passives persist during berserk (GDD). Combo tiers match GDD Section 2.3. `gd-tools lint` and `gd-tools format --check` pass.

---

### TRACK-008: Combat Manager & Match Flow
*   **Status:** `Pending`
*   **Dependencies:** TRACK-005, TRACK-006, TRACK-007, TRACK-004
*   **Estimated Effort:** 2-3 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 2.4 (Combat Model — 60s timer, win: all dead OR timer+HP%; formation grid pre-match only, free movement after), Section 4.4 (Match Types — Regular always free small rewards; Tournaments bracket events), Section 4.6 (Regular Matches always free, rubber-band difficulty on losing streaks)
*   **TDD Reference:** `docs/TDD.md` Section 4 (CombatManager — start_match, _process, end_match, get_enemies_of), Section 6 (Win Condition code, Enemy Generation)

#### Track Tech Stack
*   GDScript, Godot Autoload system
*   gd-tools (test, lint, format)

#### Scope Boundaries
*   **In Scope:**
    *   `CombatManager` match lifecycle: start_match(creates ChimeraEntity per chimera, initializes CombatState, places at formation positions), _process(ticks 60s timer, checks win), end_match(clears state, emits match_ended)
    *   Win condition: 0 alive on one side -> other wins. 60s timer -> higher total HP% wins. Checked after every death and every frame.
    *   Match result: {winner, surviving_hp, duration, gold_earned, infamy_earned}
    *   `enemy_generator.gd`: generate_enemy_roster(player_roster, match_type, losing_streak). Regular: scales to roster + losing streak (rubber-band). Tournament: scales to tier. Creates 3 enemies via PartDatabase.generate_random_part().
    *   CombatManager idle: match_active=false between matches, _process returns early, state cleared in end_match()
    *   Post-match economy: rewards via economy.gd (Gold/Infamy based on match type + multipliers)
    *   Market refresh + save trigger after match
*   **Out of Scope:**
    *   Combat HUD (TRACK-014), Pre-match formation UI (TRACK-013), Tournament bracket (TRACK-015), VFX (TRACK-014)

#### High-Level Execution Vectors
*   **Phase 1 (Match Lifecycle):** Implement start_match, _process (timer+win check), end_match. Verify entity placement, timer countdown, win condition triggers.
*   **Phase 2 (Enemy Generation):** Implement enemy_generator.gd with rubber-band for Regular and tier scaling for Tournaments.
*   **Phase 3 (Economy Integration):** Implement post-match rewards via economy.gd. Trigger market refresh and save.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** Match starts with 6 entities at correct positions. 60s timer counts down. Chimeras fight using AI+abilities. Match ends on all-dead or timer. Result shows winner, HP, duration. Gold/Infamy awarded. Market refreshes. CombatManager goes idle. Save triggers.
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) start_match creates 6 entities with CombatState, (2) timer decrements, (3) win on all-enemies-dead, (4) win on all-players-dead, (5) win on timer+HP%, (6) enemy_generator produces 3 appropriate chimeras (weaker on losing streak), (7) end_match clears state, (8) rewards correct, (9) market refresh triggers, (10) save triggers.
*   [ ] **Conductor Review:** CombatManager idle between matches. Win conditions match GDD Section 2.4. Rubber-band matches GDD Section 4.6. Rewards match GDD Section 4.4. `gd-tools lint` and `gd-tools format --check` pass.

---

## Milestone 4: UI & Management Screens

### TRACK-009: UI Framework & Screen Manager
*   **Status:** `Pending`
*   **Dependencies:** TRACK-001, TRACK-004
*   **Estimated Effort:** 2-3 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 5 (UI/UX — 9 screens, Lab Hub as hub, Arena modal flow), Section 3.3 (UI Pack — buttons, panels, font, sounds), Section 3.4 (RPG Expansion — HP bars, panels, cursors)
*   **TDD Reference:** `docs/TDD.md` Section 10 (UI Architecture — ScreenManager, Screen Flow, Screen Registration, ChimeraSprite), Section 11 (UI Pack, Font, Sounds)

#### Track Tech Stack
*   GDScript, Control nodes, NinePatchRect, Theme system
*   Kenney UI Pack, UI Pack RPG Expansion

#### Scope Boundaries
*   **In Scope:**
    *   `main.tscn`: Main (Control) with ScreenManager (Control) + TopBar (Control)
    *   `ScreenManager`: change_screen(), current_screen, 9 preloaded PackedScenes. Frees previous, instantiates new, emits screen_change_requested.
    *   9 screen stub scenes (minimal Control with label — functional impl in subsequent tracks)
    *   Godot `Theme` resource (resolves TDD gap 12): Kenney Future font, NinePatchRect button/panel styles, color palette per GDD Section 3.6
    *   `TopBar`: persistent Gold/Infamy display, listens to EventBus.gold_changed/infamy_changed
    *   4 reusable widgets: part_slot.tscn, stat_display.tscn, chimera_card.tscn, formation_grid.tscn
    *   UI sounds: click/switch/tap OGG on interactions
    *   Screen flow: non-Arena screens return to Lab Hub. Arena: Pre-Match -> Combat -> Lab Hub with results.
*   **Out of Scope:**
    *   Individual screen implementations (stubs only — TRACK-010 through TRACK-014)
    *   Drag-and-drop (TRACK-011, TRACK-013), Combat HUD (TRACK-014)

#### High-Level Execution Vectors
*   **Phase 1 (Framework):** Create main.tscn with ScreenManager + TopBar. Implement ScreenManager with 9 stubs. Create Theme. Verify transitions.
*   **Phase 2 (Widgets):** Create 4 reusable widgets. Verify they accept/display correct data types.
*   **Phase 3 (TopBar & Sounds):** Implement TopBar with EventBus listening. Add UI sounds. Verify live Gold/Infamy updates.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** ScreenManager transitions between all 9 stubs. Lab Hub is default. TopBar shows Gold/Infamy (updates on EventBus). Theme applies Kenney Future + NinePatchRect consistently. Sounds play on interactions.
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) change_screen loads correct PackedScene, (2) frees previous screen, (3) TopBar updates on gold_changed, (4) TopBar updates on infamy_changed, (5) part_slot displays correct sprite, (6) chimera_card displays nickname+stats.
*   [ ] **Conductor Review:** Screen flow matches TDD Section 10. Theme consistent. All 9 screens registered. `gd-tools lint` and `gd-tools format --check` pass.

---

### TRACK-010: Lab Hub & Roster Screens
*   **Status:** `Pending`
*   **Dependencies:** TRACK-009, TRACK-004, TRACK-002
*   **Estimated Effort:** 2-3 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 5 (Lab Hub — roster overview, Gold/Infamy, navigation; Roster — view 3 chimeras, stats, decay, equipment, no bench), Section 4.1 (Starting State — 3 chimeras, 200G), Section 2.2 (Instability labels: Pure/Stable Hybrid/Volatile Hybrid/Chaotic)
*   **TDD Reference:** `docs/TDD.md` Section 10 (Screen Flow — Lab Hub as root)

#### Track Tech Stack
*   GDScript, Control nodes, chimera_card widget

#### Scope Boundaries
*   **In Scope:**
    *   `lab_hub.gd` + full lab_hub.tscn: 3 chimera summary cards (chimera_card widget), Gold/Infamy display, navigation buttons to all 7 screens, quick-start Regular Match button
    *   `roster.gd` + full roster.tscn: 3 detailed chimera cards — nickname, full ChimeraSprite preview, 4 equipped parts with sprites, derived stats (HP/Atk/Def/Spd/Range), instability label, strain distribution, decay level, match wins, abilities list (part + combo). View-only.
    *   ChimeraSprite integration: composited sprite from parts via STRAIN_TO_COLOR
*   **Out of Scope:**
    *   Part editing (TRACK-011), Market (TRACK-012), Clinic (TRACK-012), Tournament (TRACK-015)

#### High-Level Execution Vectors
*   **Phase 1 (Lab Hub):** Implement lab_hub.tscn with 3 chimera cards, navigation buttons, Gold/Infamy. Verify navigation to all screens.
*   **Phase 2 (Roster):** Implement roster.tscn with detailed cards. Verify stats, instability labels, decay, wins, abilities display correctly.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** Lab Hub shows 3 chimera cards with nicknames+stats. Gold=200G, Infamy=0 on new game. All 7 nav buttons work. Roster shows full detail: sprites, stats, instability labels, decay=0, abilities listed.
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) Lab Hub shows 3 cards from GameState.roster, (2) Gold/Infamy labels match GameState, (3) Roster stats match ChimeraData, (4) instability label matches strain count, (5) combo ability displayed when 2+ same-strain.
*   [ ] **Conductor Review:** Lab Hub matches GDD Section 5. Roster shows exactly 3 (no bench). Instability labels match GDD Section 2.2. `gd-tools lint` and `gd-tools format --check` pass.

---

### TRACK-011: Chimera Assembly Screen
*   **Status:** `Pending`
*   **Dependencies:** TRACK-009, TRACK-002, TRACK-003, TRACK-004
*   **Estimated Effort:** 3-4 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 2.1 (Modular Fusion — 4 slots, face elements cosmetic, assembling updates visual+stats), Section 2.2 (Instability meter, strain count), Section 2.3 (Abilities — live preview), Section 3.1 (sprite composition: body includes head area, detail on top), Section 5 (Assembly screen — 4 slots, cosmetic, stat preview, instability meter)
*   **TDD Reference:** `docs/TDD.md` Section 10 (ChimeraSprite — 8 layers, STRAIN_TO_COLOR, sprite path), Section 3 (Stat Calculation Flow — recalculate on part change)

#### Track Tech Stack
*   GDScript, Control nodes, drag-and-drop API
*   Kenney Monster Builder Pack (part sprites + cosmetics)

#### Scope Boundaries
*   **In Scope:**
    *   `assembly.gd` + full assembly.tscn: 4 equipment slots (HEAD/TORSO/ARMS/LEGS) with drag-and-drop from inventory, cosmetic face panel (eyes/mouth/nose/eyebrows — no stat effect), live stat preview (HP/Atk/Def/Spd/Range), instability meter (Pure/Stable/Volatile/Chaotic + strain color breakdown), ability preview (part abilities + combo)
    *   Inventory panel: scrollable spare parts from GameState.inventory, filterable by slot, draggable
    *   Drag-and-drop system (resolves TDD gap 13): inventory->slot, slot->slot, slot->inventory. Ghost sprite + slot highlight on hover.
    *   ChimeraSprite live update on part change with correct z-order (resolves TDD gap 14): Body=0, Legs=1, Arms=2, Detail=3, Eyes=4, Mouth=5, Nose=6, Eyebrows=7. Default resolution.
    *   Stat recalculation: recalculate_stats() on every part change, preview updates immediately
    *   Save trigger on assembly changes
*   **Out of Scope:**
    *   Market purchasing (TRACK-012), chimera creation/deletion (always 3), cosmetic unlocking (all available)

#### High-Level Execution Vectors
*   **Phase 1 (Layout & Slots):** Create assembly.tscn layout with 4 slots, inventory panel, cosmetic panel, stat preview, instability meter. Implement part_slot with drag-and-drop.
*   **Phase 2 (Drag-and-Drop & Sprite):** Implement drag-and-drop (inventory->slot, slot->slot). Implement ChimeraSprite live recomposition with z-order.
*   **Phase 3 (Stats & Instability):** Implement live stat preview via recalculate_stats(). Implement instability meter with strain breakdown. Implement ability preview. Verify save triggers.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** Drag part from inventory to HEAD slot. ChimeraSprite updates immediately. Stats update. Instability meter updates if strain changed. Ability list updates. Cosmetic changes have no stat effect. Changes persist after navigating away (save triggered).
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) equipping calls recalculate_stats, (2) equipping different strains updates instability, (3) instability label matches strain count, (4) combo appears at 2+ same-strain, (5) cosmetics don't affect stats, (6) save triggers after change, (7) ChimeraSprite correct sprite per shape_id+strain, (8) z-order renders correctly.
*   [ ] **Conductor Review:** 4 slots match GDD Section 2.1. Cosmetics have zero effect (GDD). Instability matches GDD Section 2.2. Stat flow matches TDD Section 3. `gd-tools lint` and `gd-tools format --check` pass.

---

### TRACK-012: Black Market & Clinic Screens
*   **Status:** `Pending`
*   **Dependencies:** TRACK-009, TRACK-004, TRACK-003
*   **Estimated Effort:** 3-4 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 4.7 (Black Market — base stock always available commons all slots/strains, rotating 6-10 parts refresh after each match, 4 rarity tiers with prices: Common 50-100G, Uncommon 150-300G, Rare 500-1000G, Legendary 1500-3000G+Infamy threshold; filtering by type/strain/price), Section 4.2 (Genetic Decay — repair costs per instability, purebreds never decay), Section 4.6 (Emergency Salvage — break to Neutral parts, lose strain, retain base stats, all-Neutral=Pure)
*   **TDD Reference:** `docs/TDD.md` Section 4 (GameState — buy_part, refresh_market; market.gd utility), Section 9 (market_stock serialization)

#### Track Tech Stack
*   GDScript, Control nodes
*   Kenney UI Pack (buttons, panels, sliders for filters)

#### Scope Boundaries
*   **In Scope:**
    *   `black_market.gd` + full black_market.tscn: Base stock section (commons, all 4 slots, all 6 strains), Rotating stock section (6-10 varied parts, refresh indicator), Part display cards (sprite/slot/strain/rarity/stats/ability/price), Filter panel (slot/strain/price/rarity), Purchase button (Gold validation via GameState.buy_part), Legendary Infamy gating, refresh indicator
    *   `clinic.gd` + full clinic.tscn: 3 chimera cards with decay status + stats lost, repair cost per chimera (per GDD 4.2), repair button (Gold validation, resets decay), purebred indicator (0 decay, 0 cost)
    *   Emergency Salvage: button when all chimeras severely decayed, breaks to Neutral parts (via PartDatabase), adds to inventory
    *   Save triggers: after purchase, repair, salvage
*   **Out of Scope:**
    *   Market refresh logic (GameState — TRACK-004), Enemy gen (TRACK-008), Match flow (TRACK-008)

#### High-Level Execution Vectors
*   **Phase 1 (Black Market):** Implement black_market.tscn with base+rotating stock, filtering, purchase. Verify Gold deduction, inventory add, save trigger.
*   **Phase 2 (Clinic):** Implement clinic.tscn with decay display, repair costs, repair. Verify Gold deduction, decay reset.
*   **Phase 3 (Salvage):** Implement emergency salvage. Verify Neutral parts produced, all-Neutral=Pure.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** Black Market shows base+rotating stock. Filters work. Purchase deducts Gold, adds to inventory, fails if insufficient. Legendary blocked below Infamy threshold. Clinic shows decay levels + costs. Purebred shows 0/0. Repair deducts Gold, resets decay. Salvage produces Neutral parts.
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) base stock has commons all slots/strains, (2) rotating has 6-10 with rarity distribution, (3) purchase deducts correct Gold per GDD 4.7, (4) purchase fails on insufficient Gold, (5) Legendary blocked below Infamy, (6) repair cost matches decay level per GDD 4.2, (7) repair resets decay, (8) salvage produces Neutral parts, (9) all-Neutral=Pure/instability 0, (10) save triggers.
*   [ ] **Conductor Review:** Prices match GDD Section 4.7. Rarity scaling matches GDD (x1.0/x1.25/x1.5/x2.0). Repair costs match GDD 4.2. Salvage matches GDD 4.6. No negative Gold. `gd-tools lint` and `gd-tools format --check` pass.

---

## Milestone 5: Arena & Match Flow

### TRACK-013: Arena Pre-Match Screen
*   **Status:** `Pending`
*   **Dependencies:** TRACK-009, TRACK-008, TRACK-003
*   **Estimated Effort:** 2-3 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 2.4 (Formation Grid — 3x3 per side, front/mid/back rows, left/center/right columns; Enemy Scouting — full intel before positioning), Section 5 (Arena Pre-Match screen)
*   **TDD Reference:** `docs/TDD.md` Section 6 (Arena — FormationGridPlayer/Enemy nodes), Section 10 (formation_grid.tscn widget)

#### Track Tech Stack
*   GDScript, Control nodes, formation_grid widget

#### Scope Boundaries
*   **In Scope:**
    *   `arena_pre_match.gd` + full arena_pre_match.tscn: Enemy intel panel (3 enemy chimeras — sprites, parts, stats, behavior module), Enemy formation grid (3x3 showing placement), Player formation grid (3x3 interactive — click to place), Player chimera selection (3 cards), Row/column labels (FRONT/MID/BACK, LEFT/CENTER/RIGHT), Confirm button (launches combat)
    *   Formation grid interaction (resolves TDD gap 13): click-to-select, click-to-place, visual feedback, reposition before confirm, all 3 must be placed
    *   Formation data output: {chimera, grid_pos} array passed to CombatManager.start_match(). grid_pos maps to world position via TRACK-005 mapping.
*   **Out of Scope:**
    *   Combat simulation (TRACK-008), Combat HUD (TRACK-014), Tournament bracket (TRACK-015)

#### High-Level Execution Vectors
*   **Phase 1 (Enemy Intel):** Implement enemy intel panel with full composition. Verify correct data from generated roster.
*   **Phase 2 (Formation Grid):** Implement interactive player 3x3 grid. Verify click-to-place, all 3 required, visual feedback.
*   **Phase 3 (Confirm & Launch):** Implement confirm -> CombatManager.start_match with formation data. Verify world position mapping.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** Enemy intel shows 3 chimeras with full detail. Enemy formation grid shows placement. Player places 3 in 3x3 via click. Confirm disabled until 3 placed. Confirming launches combat with correct spawn positions (front closer to center).
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) enemy intel displays correct data, (2) grid accepts exactly 3 placements, (3) confirm disabled when <3, (4) formation data has correct grid_pos, (5) grid_pos maps to correct world position, (6) CombatManager.start_match receives correct formation.
*   [ ] **Conductor Review:** Full enemy intel per GDD Section 2.4. 3x3 per side per GDD. All 3 fielded (no bench). `gd-tools lint` and `gd-tools format --check` pass.

---

### TRACK-014: Arena Combat & HUD
*   **Status:** `Pending`
*   **Dependencies:** TRACK-008, TRACK-009
*   **Estimated Effort:** 3-4 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 2.4 (Combat Model — real-time, 60s timer), Section 5 (Arena Combat — HP bars, status effects, instability events), Section 3.5 (Particle Pack — VFX categories), Section 3.6 (Color Palette — strain VFX mapping: Undead smoke, Robotic spark/muzzle, Draconic fire/flame, Beast dirt/spark, Elemental magic/twirl, Aberrant star/twirl)
*   **TDD Reference:** `docs/TDD.md` Section 6 (CombatHUD — HP bars, timer, status effects), Section 11 (Particle Pack — CPUParticles2D, strain VFX), Section 5 (combat_log signal)

#### Track Tech Stack
*   GDScript, Control nodes, CPUParticles2D, ParticleProcessMaterial
*   Kenney UI Pack RPG Expansion (HP bars, panels), Kenney Particle Pack (80 sprites)

#### Scope Boundaries
*   **In Scope:**
    *   CombatHUD (CanvasLayer): floating HP bars per chimera (RPG UI Pack bars — red enemy, green/blue player), 60s countdown timer, status effect icons (from EffectComponent), berserk indicator, combat log panel (toggle, displays EventBus.combat_log)
    *   VFX system: VFXSpawner on ChimeraEntity, CPUParticles2D + ParticleProcessMaterial per effect, strain-themed VFX per GDD Section 3.6
    *   Combat event VFX: melee hit (slash/scratch), ability cast (strain-themed), death (smoke), berserk (distortion), heal (sparkle)
    *   Combat end screen: match result (winner, HP%, duration), rewards (Gold, Infamy), return to Lab Hub
    *   Optional: pause (P), speed toggle (1x/2x)
*   **Out of Scope:**
    *   Pre-match formation (TRACK-013), Combat logic/AI/abilities (TRACK-005 through TRACK-008), Post-match economy (TRACK-008)

#### High-Level Execution Vectors
*   **Phase 1 (HUD):** Implement CombatHUD with HP bars, timer, status icons, berserk indicator. Verify real-time updates.
*   **Phase 2 (VFX):** Implement VFXSpawner with CPUParticles2D for all combat events. Verify strain-themed VFX per GDD 3.6.
*   **Phase 3 (Combat End):** Implement combat end screen with results and rewards. Verify return to Lab Hub.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** HP bars float above chimeras, update real-time. Timer counts down. Status icons appear/disappear. Berserk visually indicated. VFX play on hits, ability casts, deaths. Combat end shows winner, rewards, returns to Lab Hub.
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) HP bar width matches HP ratio, (2) timer matches CombatManager.timer, (3) status icons match EffectComponent count, (4) berserk indicator visible when is_berserk, (5) VFXSpawner correct type for melee hit, (6) strain-themed VFX for ability cast, (7) combat end shows correct result, (8) return to Lab Hub.
*   [ ] **Conductor Review:** HUD matches GDD Section 5. VFX mapping matches GDD Section 3.6. Timer 60s per GDD 2.4. Return to Lab Hub per TDD Section 10. `gd-tools lint` and `gd-tools format --check` pass.

---

## Milestone 6: Progression & Meta Systems

### TRACK-015: Tournament System
*   **Status:** `Pending`
*   **Dependencies:** TRACK-008, TRACK-004, TRACK-009
*   **Estimated Effort:** 3-4 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 4.4 (Tournament Tiers — 4 tiers: Underground Brawls 0 Infamy/free/4-bracket/1x, Provincial Arena 50/100G/4-bracket/2x, Grand Colosseum 150/300G/8-bracket/4x, Champion's Circle 400/1000G/8-bracket/8x; Regular always free; Tournaments Infamy-gated + Gold entry; reward multiplier on both Gold+Infamy)
*   **TDD Reference:** `docs/TDD.md` Section 4 (GameState — current_tournament), Section 6 (Enemy Generation — Tournament scaling by tier)

#### Track Tech Stack
*   GDScript, Control nodes
*   Kenney UI Pack (brackets, buttons, panels)

#### Scope Boundaries
*   **In Scope:**
    *   Tournament logic: 4 tiers with Infamy thresholds + Gold entry fees (matching GDD 4.4 table), bracket generation (4 or 8 participant single-elimination), sequential match progression, reward calculation with multipliers (both Gold+Infamy), Infamy gating, Gold fee deduction
    *   Tier-scaled enemy generation: enemy_generator.gd creates opponents scaled to tournament tier
    *   `tournament.gd` + full tournament.tscn: Tier selection (4 tiers with requirements display), bracket visualization (tree with participants/matchups), current position, upcoming match, enter button (validates Infamy+Gold), bracket progression (win->advance, lose->eliminated), results (placement, total rewards)
    *   Regular Match quick-start: separate button (no fee, rubber-band difficulty)
    *   Integration with CombatManager: tournament matches use same combat flow with tier-scaled enemies + reward multipliers
*   **Out of Scope:**
    *   Combat simulation (TRACK-008), Pre-match formation (TRACK-013, reused), Research/ascension (TRACK-016)

#### High-Level Execution Vectors
*   **Phase 1 (Tournament Logic):** Implement tier definitions, bracket generation, entry validation, reward calculation. Verify all 4 tiers gate correctly.
*   **Phase 2 (Enemy Scaling):** Implement tier-scaled enemy generation. Verify higher tiers = stronger opponents.
*   **Phase 3 (Tournament UI):** Implement tournament.tscn with tier selection, bracket, progression, results. Verify end-to-end flow.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** All 4 tiers display correct requirements (Infamy threshold, entry fee, format, multiplier). Tiers gate by Infamy. Entry fee deducted. Bracket generates with correct participant count (4 or 8). Enemies scale to tier. Rewards multiplied correctly. Bracket progresses on win, eliminates on loss. Regular Match quick-start works (free, rubber-band).
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) Underground Brawls: 0 Infamy, free, 4-bracket, 1x, (2) Provincial Arena: 50 Infamy, 100G, 4-bracket, 2x, (3) Grand Colosseum: 150 Infamy, 300G, 8-bracket, 4x, (4) Champion's Circle: 400 Infamy, 1000G, 8-bracket, 8x, (5) entry blocked below Infamy threshold, (6) entry fee deducted, (7) bracket generates correct participant count, (8) rewards multiplied correctly, (9) bracket progression: win->advance, lose->eliminated, (10) Regular Match: no fee, rubber-band difficulty.
*   [ ] **Conductor Review:** All 4 tiers match GDD Section 4.4 table exactly. Reward multipliers apply to both Gold+Infamy. Regular Matches always free. `gd-tools lint` and `gd-tools format --check` pass.

---

### TRACK-016: Research & Ascension System
*   **Status:** `Pending`
*   **Dependencies:** TRACK-004, TRACK-009, TRACK-002
*   **Estimated Effort:** 3-4 Days

#### Context Anchors (Traceability)
*   **GDD Reference:** `docs/GDD.md` Section 4.5 (Research Tracks — Ascension: 10 wins eligible, retire -> 1 RP -> Hall of Fame, free common-rarity replacement starter chimera; 3 branches: Strain Mastery 6 tracks x 3 levels, Lab Engineering 4 nodes x 2 levels, Combat Doctrine 4 nodes x 1 level; bonus progress for same-strain retirement; effects: decay reduction, repair cost reduction, market prices, berserk chance reduction, berserk duration 5s->3s, cooldown reduction, formation bonus)
*   **TDD Reference:** `docs/TDD.md` Section 4 (GameState — can_ascend, ascend_chimera, get_research_level, research_progress)

#### Track Tech Stack
*   GDScript, Control nodes
*   Kenney UI Pack (panels, buttons)

#### Scope Boundaries
*   **In Scope:**
    *   Ascension system: can_ascend (10+ match wins), ascend_chimera (retire -> 1 RP -> Hall of Fame, roster slot filled with free common-rarity replacement starter chimera per GDD 4.5)
    *   Research system: 3 branches, RP spending UI. Strain Mastery (6 tracks x 3 levels, strain-specific combo/stat enhancements, bonus progress for same-strain retirement). Lab Engineering (4 nodes x 2 levels: Reinforced Genetics, Clinic Efficiency, Market Connections, Stability Serum). Combat Doctrine (4 nodes x 1 level: Tactical AI, Ability Tuning, Formation Mastery, Berserk Control).
    *   Research effect integration: decay rate reduction, repair cost reduction, market price reduction, berserk chance reduction, berserk duration 5s->3s (Berserk Control), cooldown reduction (Ability Tuning), formation stat bonus (Formation Mastery), improved AI decisions (Tactical AI)
    *   `hall_of_fame.gd` + full hall_of_fame.tscn: Retired champions display, research track progress per branch, RP spending interface, research node descriptions + effect display
*   **Out of Scope:**
    *   New chimera creation (player assembles from market parts — TRACK-011+TRACK-012)
    *   Specific research values (starting values for balancing per GDD)

#### High-Level Execution Vectors
*   **Phase 1 (Ascension):** Implement can_ascend (10 wins), ascend_chimera (retire -> 1 RP -> Hall of Fame, roster slot filled with free common-rarity replacement starter). Verify chimera moves to hall_of_fame, RP awarded, new starter added to roster.
*   **Phase 2 (Research System):** Implement 3 branches with all nodes/levels. Implement RP spending. Verify same-strain retirement gives bonus progress. Verify research effects apply correctly.
*   **Phase 3 (Hall of Fame UI):** Implement hall_of_fame.tscn with retired champions, research progress, spending interface. Verify all nodes display correct effects.

#### Verification & Definition of Done (DoD)
*   [ ] **Manual Checkpoint:** Chimera with 10+ wins can be ascended. Retiring moves to Hall of Fame, grants 1 RP, roster refilled with free common-rarity replacement starter chimera. All 3 research branches functional. RP spendable on nodes. Research effects apply in combat/economy (berserk duration reduced to 3s with Berserk Control, decay reduced with Reinforced Genetics, etc.). Hall of Fame shows retired champions + research progress. Same-strain retirement gives bonus Strain Mastery progress.
*   [ ] **Automated Tests:** `gd-tools test --coverage --min 80` exits 0. Tests verify: (1) can_ascend false at 9 wins, true at 10, (2) ascend_chimera moves to hall_of_fame + returns 1 RP, (3) ascend_chimera fills roster slot with common-rarity replacement starter (roster stays at 3), (4) Strain Mastery: 6 tracks x 3 levels, (5) Lab Engineering: 4 nodes x 2 levels, (6) Combat Doctrine: 4 nodes x 1 level, (7) same-strain retirement gives bonus progress, (8) Berserk Control reduces duration 5s->3s, (9) Reinforced Genetics reduces decay rate, (10) Clinic Efficiency reduces repair cost, (11) Market Connections reduces prices, (12) Stability Serum reduces berserk chance, (13) Ability Tuning reduces cooldowns, (14) Formation Mastery gives stat bonus when correctly positioned, (15) RP spending decrements points + increments node level.
*   [ ] **Conductor Review:** Ascension at 10 wins per GDD 4.5. Free common-rarity replacement starter maintains roster at 3. 3 branches match GDD structure exactly (Strain Mastery 6x3, Lab Engineering 4x2, Combat Doctrine 4x1). Berserk Control = 3s per GDD 4.5. All research effects match GDD descriptions. `gd-tools lint` and `gd-tools format --check` pass.

---

## Cross-Cutting Concerns

The following GDD features are distributed across multiple tracks rather than having a dedicated track:

### Fail State & Recovery (GDD Section 4.6)
*   **No negative Gold:** Implemented in TRACK-004 (GameState.spend_gold returns false on insufficient)
*   **Regular Matches always free:** Implemented in TRACK-008 (CombatManager) and TRACK-015 (Tournament System)
*   **Rubber-band difficulty:** Implemented in TRACK-008 (enemy_generator.gd losing streak modifier)
*   **Emergency Salvage to Neutral:** Implemented in TRACK-012 (Clinic screen, PartDatabase Neutral generation from TRACK-003)

### TDD Deferred Moderate Gaps (resolved in tracks)
*   Gap 8 (Formation grid -> world mapping): TRACK-005 + TRACK-013
*   Gap 9 (Arena dimensions): TRACK-005
*   Gap 11 (Save migration): TRACK-004 (version field + migration stub)
*   Gap 12 (UI Theme): TRACK-009
*   Gap 13 (Drag-and-drop): TRACK-011 (Assembly) + TRACK-013 (Pre-Match)
*   Gap 14 (Sprite z-order/resolution): TRACK-005 + TRACK-011

### Godot Version Alignment
*   TDD Section 1 specifies Godot 4.5+ (updated to match gd-tools requirements — GUT 9.5.0)
*   ROADMAP uses Godot 4.5+ throughout
