<protect>
# Implementation Plan: Part Database & Data Definitions (TRACK-003)

## Phase 1: Data Files

- [ ] Task: Read spec.md and workflow.md to align with current requirements and TDD protocol
- [ ] Task: Create 23 part ability .tres files
    - [ ] Create 7 HEAD ability files (utility & disruption theme, active 5-10s CD, effects: DEBUFF_STAT/CLEANSE/REPOSITION/BUFF_STAT)
    - [ ] Create 6 TORSO ability files (defense & sustain, mix active 8-12s CD + passive, effects: SHIELD/HEAL/BUFF_STAT/DAMAGE)
    - [ ] Create 5 ARMS ability files (offense theme, active 3-6s CD, effects: DAMAGE/DEBUFF_STAT/BUFF_STAT)
    - [ ] Create 5 LEGS ability files (mobility & positioning, active 5-10s CD, effects: REPOSITION/BUFF_STAT)
- [ ] Task: Create 18 strain combo ability .tres files
    - [ ] Create 3 Undead combos (necrotic drain: life steal -> +heal -> +reanimate)
    - [ ] Create 3 Robotic combos (overcharge: burst -> +overclock -> +tradeoff)
    - [ ] Create 3 Draconic combos (dragon fury: AoE fire -> +enrage -> +aura)
    - [ ] Create 3 Beast combos (savagery: speed surge -> +lifesteal -> +crit bonus)
    - [ ] Create 3 Elemental combos (surge: chain damage -> +shield -> +persistent)
    - [ ] Create 3 Aberrant combos (chaos: random effect -> +mutation -> +persistent)
- [ ] Task: Create 7 behavior module .tres files
    - [ ] Create all 7 modules matching GDD Section 2.4 table (Charger/Skirmisher/Caster/Controller/Sentinel/Guardian/Stalker with correct targeting/ability_priority/positioning)
- [ ] Task: Create 23 base part template .tres files
    - [ ] Create 7 HEAD templates (with behavior_module ref, minor HP/Def bonuses, ability_id)
    - [ ] Create 6 TORSO templates (primary HP, moderate Defense, ability_id)
    - [ ] Create 5 ARMS templates (primary Attack, attack_range melee 32px/ranged 96px, ability_id)
    - [ ] Create 5 LEGS templates (primary Speed, ability_id)
- [ ] Task: Create 3 starter chimera definitions
    - [ ] Create Tank starter (Beast purebred, detail_ear_round/Guardian, high HP/Def, low Speed)
    - [ ] Create DPS starter (Draconic purebred, detail_horn_large/Charger, high Attack, moderate HP/Speed)
    - [ ] Create Utility starter (Elemental purebred, detail_antenna_large/Caster, balanced stats)
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Data Files' (Protocol in workflow.md)

## Phase 2: PartDatabase Implementation (TDD)

- [ ] Task: Read spec.md and workflow.md to align with current requirements and TDD protocol
- [ ] Task: Implement PartDatabase lookup methods with TDD
    - [ ] Write failing tests for get_part, get_ability, get_base_stats, get_behavior_module, get_strain_combo
    - [ ] Implement static vars, template loading from .tres files, and all lookup methods
    - [ ] Write failing tests for get_sprite_path handling both naming patterns (body_blueA.png vs detail_blue_horn_large.png)
    - [ ] Implement get_sprite_path fix
    - [ ] Run tests and verify all pass
- [ ] Task: Implement rarity modifier system with TDD
    - [ ] Write failing tests for stat multipliers (x1.0/x1.25/x1.5/x2.0) and ability potency (Rare -15% CD, Legendary -25% CD + +20% effect)
    - [ ] Implement rarity modifiers in get_part()
    - [ ] Run tests and verify they pass
- [ ] Task: Implement generate_random_part and starter chimera loading with TDD
    - [ ] Write failing tests for generate_random_part (valid shape/strain/rarity), get_starter_chimeras (3 starters with correct stats), Neutral strain (no combo, same strain for instability)
    - [ ] Implement generate_random_part and get_starter_chimeras methods
    - [ ] Run tests and verify they pass
- [ ] Task: Verify coverage and quality gates
    - [ ] Run gd-tools test --coverage --min 80
    - [ ] Run gd-tools lint
    - [ ] Run gd-tools format --check
- [ ] Task: Conductor - User Manual Verification 'Phase 2: PartDatabase Implementation' (Protocol in workflow.md)

## Phase 3: Integration Tests & Final Verification

- [ ] Task: Read spec.md and workflow.md to align with current requirements and TDD protocol
- [ ] Task: Write and verify integration tests
    - [ ] Write tests: all sprite_paths resolve to actual asset files
    - [ ] Write tests: all ability_id references resolve via get_ability()
    - [ ] Write tests: all detail_type references resolve via get_behavior_module()
    - [ ] Write tests: starter chimera stats match role expectations (Tank high HP/Def, DPS high Atk, Utility balanced)
    - [ ] Write tests: Neutral strain parts have no combo and count as same strain
    - [ ] Run all tests and verify they pass
- [ ] Task: Final quality gate verification
    - [ ] Run gd-tools test --coverage --min 80
    - [ ] Run gd-tools lint
    - [ ] Run gd-tools format --check
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Integration Tests & Final Verification' (Protocol in workflow.md)
</protect>
