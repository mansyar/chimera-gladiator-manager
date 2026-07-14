<protect>
# Track: Part Database & Data Definitions (TRACK-003)

## Overview

Implement the PartDatabase static class and all associated data resource files (.tres) that serve as the foundation for the chimera part system. This includes 23 part abilities, 18 strain combo abilities, 7 behavior modules, 23 base part templates, and 3 starter chimera definitions. The PartDatabase provides centralized lookup, generation, and rarity modification for all part-related data.

**Context Anchors:**
- GDD Sections 2.1, 2.3, 2.4, 4.1, 4.7
- TDD Section 3 (PartDatabase, data model structures), Section 11 (asset paths)
- ROADMAP TRACK-003

**Dependencies:** TRACK-002 (Core data structures: PartData, AbilityData, AbilityEffect, BehaviorModuleData, ChimeraData resources)

## Functional Requirements

### FR-1: PartDatabase Static Class

Implement `scripts/systems/part_database.gd` as a static utility class (per TDD Section 3) with:

**Static Variables:**
- `part_templates: Dictionary` — keyed by shape_id (e.g., `body_a`, `detail_horn_large`)
- `ability_templates: Dictionary` — keyed by ability_id (String)
- `behavior_templates: Dictionary` — keyed by detail_type (String)
- `combo_templates: Dictionary` — keyed by `{strain}_{tier}` (e.g., `undead_1`)

**Methods:**
- `get_part(shape_id: String, strain: String, rarity: String) -> PartData` — Returns a PartData instance with strain-appropriate stats, rarity modifiers applied, and sprite_path constructed
- `get_ability(ability_id: String) -> AbilityData` — Returns ability template by ID
- `get_base_stats(shape_id: String) -> Dictionary` — Returns base HP/Attack/Defense/Speed for a shape
- `generate_random_part(slot: String, rarity: String = "common") -> PartData` — Generates a random part for the given slot with optional rarity weighting
- `get_strain_combo(strain: String, same_strain_count: int) -> AbilityData` — Returns the combo ability for a strain based on count tier (2=Basic, 3=Enhanced, 4=Ultimate)
- `get_behavior_module(detail_type: String) -> BehaviorModuleData` — Returns behavior module for a HEAD detail type
- `get_starter_chimeras() -> Array[ChimeraData]` — Returns the 3 starter chimera definitions

**Loading:** Templates are loaded from .tres files at startup (via `_static_init()` or lazy initialization).

### FR-2: Sprite Path Construction Fix

Fix `get_sprite_path()` to handle the two actual Kenney Monster Builder Pack naming patterns:

1. **Body/Arm/Leg:** `{category}_{color}{Variant}.png` where Variant is UPPERCASE letter
   - Example: `body_blueA.png`, `arm_darkC.png`, `leg_redE.png`
   - shape_id format: `body_a`, `arm_c`, `leg_e` (lowercase variant letter)

2. **Details (HEAD):** `{category}_{color}_{variant}.png` where variant is descriptive lowercase
   - Example: `detail_blue_horn_large.png`, `detail_green_antenna_small.png`
   - shape_id format: `detail_horn_large`, `detail_antenna_small`

**Logic:** If shape_id starts with `"detail_"`, construct `detail_{color}_{variant}.png` (variant = shape_id without `detail_` prefix). Otherwise, split by `_`, category = parts[0], variant = parts[1].to_upper(), construct `{category}_{color}{Variant}.png`.

### FR-3: Part Ability Data Files (23 files)

Create 23 `.tres` AbilityData resource files with differentiated values per slot theme:

**HEAD — 7 abilities (utility & disruption):**
- Cooldown: 5-10s
- Effect types: DEBUFF_STAT, CLEANSE, REPOSITION, BUFF_STAT
- Location: `resources/abilities/head/`

**TORSO — 6 abilities (defense & sustain):**
- Mix of active (8-12s CD) and passive abilities
- Effect types: SHIELD, HEAL, BUFF_STAT, DAMAGE
- Location: `resources/abilities/torso/`

**ARMS — 5 abilities (offense):**
- Cooldown: 3-6s
- Effect types: DAMAGE, DEBUFF_STAT, BUFF_STAT
- Location: `resources/abilities/arms/`

**LEGS — 5 abilities (mobility):**
- Cooldown: 5-10s
- Effect types: REPOSITION, BUFF_STAT
- Location: `resources/abilities/legs/`

### FR-4: Strain Combo Ability Data Files (18 files)

Create 18 `.tres` AbilityData resource files (6 strains × 3 tiers):

| Strain | Theme | Tier 1 (Basic, count=2) | Tier 2 (Enhanced, count=3) | Tier 3 (Ultimate, count=4) |
|--------|-------|------------------------|---------------------------|---------------------------|
| Undead | Necrotic drain | Life steal | +Heal on kill | +Reanimate fallen |
| Robotic | Overcharge | Burst damage | +Overclock (temp boost) | +Tradeoff (power vs defense) |
| Draconic | Dragon fury | AoE fire damage | +Enrage on low HP | +Persistent fire aura |
| Beast | Savagery | Speed surge | +Lifesteal | +Crit damage bonus |
| Elemental | Surge | Chain damage | +Shield | +Persistent effect |
| Aberrant | Chaos | Random effect | +Mutation | +Persistent chaos |

- Location: `resources/abilities/combos/`

### FR-5: Behavior Module Data Files (7 files)

Create 7 `.tres` BehaviorModuleData resource files matching GDD Section 2.4:

| detail_type | module_name | targeting_mode | ability_priority | positioning |
|-------------|-------------|----------------|------------------|-------------|
| horn_large | Charger | NEAREST | [OFF, MOB, UT, DEF] | FRONT |
| horn_small | Skirmisher | WEAKEST_ACCESSIBLE | [MOB, OFF, UT, DEF] | MID |
| antenna_large | Caster | HIGHEST_THREAT | [UT, OFF, DEF, MOB] | BACK |
| antenna_small | Controller | OPTIMAL_DISRUPT | [UT, MOB, DEF, OFF] | MID |
| ear | Sentinel | ATTACKING_ALLIES | [DEF, UT, OFF, MOB] | FRONT |
| ear_round | Guardian | ATTACKING_ALLIES | [DEF, UT, MOB, OFF] | FRONT |
| eye | Stalker | LOWEST_HP | [OFF, UT, MOB, DEF] | BACK |

- Location: `resources/behaviors/`

### FR-6: Base Part Template Data Files (23 files)

Create 23 `.tres` PartData resource files as base templates (COMMON rarity, NEUTRAL strain):

**HEAD (7):** Each has a `behavior_module` reference (via detail_type), minor HP/Defense bonuses, and an `ability_id`.
**TORSO (6):** Primary HP stat, moderate Defense.
**ARMS (5):** Primary Attack stat, `attack_range` of 32px (melee) for shapes a-c, 96px (ranged) for shapes d-e.
**LEGS (5):** Primary Speed stat.

Base templates store `shape_id` but leave `sprite_path` empty (constructed at instantiation by `get_part()`).
- Location: `resources/parts/{slot}/`

### FR-7: Rarity Modifier System

Implement rarity modifiers in `get_part()`:

**Stat Multipliers:**
- Common: x1.0
- Uncommon: x1.25
- Rare: x1.5
- Legendary: x2.0

**Ability Potency:**
- Common: Base values
- Uncommon: Base values
- Rare: -15% cooldown
- Legendary: -25% cooldown + +20% effect amount

### FR-8: Starter Chimera Definitions (3 files)

Create 3 starter ChimeraData definitions (all purebred, COMMON rarity):

| Role | Strain | HEAD (detail_type) | Behavior | Stats Focus |
|------|--------|---------------------|----------|------------|
| Tank | Beast | ear_round | Guardian | High HP/Def, low Speed |
| DPS | Draconic | horn_large | Charger | High Attack, moderate HP/Speed |
| Utility | Elemental | antenna_large | Caster | Balanced stats |

- Location: `resources/starters/`

### FR-9: Neutral Strain Support

- NEUTRAL strain has no combo ability (get_strain_combo returns null for NEUTRAL)
- All-Neutral chimera = Pure (Instability 0)
- `STRAIN_TO_COLOR[NEUTRAL] = "dark"` (no grey sprites in Kenney pack — known limitation, documented)

## Non-Functional Requirements

- **Performance:** Template loading happens once at startup; lookups are O(1) dictionary access
- **Data Integrity:** All .tres files must be valid Godot resources loadable via `load()`
- **Testability:** PartDatabase methods must be testable without Godot editor (via GUT)
- **Consistency:** All ability_id references in part templates must resolve via get_ability()

## Acceptance Criteria

1. PartDatabase loads all templates from .tres files at startup without errors
2. `get_part()` returns a PartData with correct base stats, strain-appropriate sprite_path, and rarity modifiers applied
3. `get_ability()` returns all 41 abilities (23 part + 18 combo) by their ability_id
4. `generate_random_part()` produces valid PartData with correct slot, shape, and rarity
5. `get_strain_combo()` returns the correct tier ability based on same_strain_count (2→Basic, 3→Enhanced, 4→Ultimate)
6. NEUTRAL strain returns no combo from `get_strain_combo()`
7. All 7 behavior modules match the GDD Section 2.4 table exactly (targeting, priority, positioning)
8. 3 starter chimeras have correct role-appropriate stats (Tank high HP/Def, DPS high Attack, Utility balanced)
9. `get_sprite_path()` correctly resolves both naming patterns (body_blueA.png and detail_blue_horn_large.png)
10. All sprite_paths generated by `get_part()` resolve to actual files in the asset directory
11. Rarity stat multipliers apply correctly (x1.0/x1.25/x1.5/x2.0)
12. Rare abilities have -15% cooldown; Legendary abilities have -25% cooldown + +20% effect amount
13. `gd-tools test --coverage --min 80`, `gd-tools lint`, and `gd-tools format --check` all pass

## Out of Scope

- Market UI and part purchasing (TRACK-012)
- Enemy chimera generation (TRACK-008)
- Save/load system (TRACK-004)
- Ability execution in combat (TRACK-007)
- Combat system and AI (TRACK-005, TRACK-006)
- Balance tuning and playtesting
</protect>
