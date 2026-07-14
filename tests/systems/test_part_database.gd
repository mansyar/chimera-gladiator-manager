# gdlint:ignore=max-public-methods
extends GutTest

## Tests for PartDatabase static class (TRACK-003).

# --- get_ability() tests ---


func test_get_ability_returns_head_ability() -> void:
	var ability := PartDatabase.get_ability("head_horn_large_ability")
	assert_not_null(ability, "Should return head horn large ability")
	assert_eq(ability.id, "head_horn_large_ability", "ID should match")
	assert_eq(ability.name, "Intimidating Roar", "Name should match")
	assert_eq(ability.category, GameEnums.AbilityCategory.UTILITY, "Category should be UTILITY")
	assert_eq(ability.cooldown, 8.0, "Cooldown should be 8.0")
	assert_eq(ability.range, 64.0, "Range should be 64.0")
	assert_eq(ability.effects.size(), 1, "Should have 1 effect")
	assert_eq(
		ability.effects[0].effect_type,
		AbilityEffect.EffectType.DEBUFF_STAT,
		"Effect should be DEBUFF_STAT"
	)


func test_get_ability_returns_combo_ability() -> void:
	var ability := PartDatabase.get_ability("undead_1")
	assert_not_null(ability, "Should return undead_1 combo")
	assert_eq(ability.id, "undead_1", "ID should match")
	assert_eq(ability.name, "Life Steal", "Name should match")
	assert_eq(ability.cooldown, 6.0, "Cooldown should be 6.0")
	assert_eq(ability.effects.size(), 2, "Should have 2 effects")


func test_get_ability_returns_null_for_unknown() -> void:
	var ability := PartDatabase.get_ability("nonexistent")
	assert_null(ability, "Should return null for unknown ability")


# --- get_base_stats() tests ---


func test_get_base_stats_returns_correct_stats() -> void:
	var stats := PartDatabase.get_base_stats("detail_horn_large")
	assert_eq(stats["hp_bonus"], 5.0, "hp_bonus should be 5.0")
	assert_eq(stats["defense_bonus"], 3.0, "defense_bonus should be 3.0")
	assert_eq(stats.get("attack_bonus", 0.0), 0.0, "attack_bonus should be 0.0")
	assert_eq(stats.get("speed_bonus", 0.0), 0.0, "speed_bonus should be 0.0")


func test_get_base_stats_returns_empty_for_unknown() -> void:
	var stats := PartDatabase.get_base_stats("nonexistent")
	assert_true(stats.is_empty(), "Should return empty dict for unknown shape")


# --- get_behavior_module() tests ---


func test_get_behavior_module_returns_charger() -> void:
	var behavior := PartDatabase.get_behavior_module("horn_large")
	assert_not_null(behavior, "Should return Charger behavior")
	assert_eq(behavior.module_name, "Charger", "Module name should be Charger")
	assert_eq(behavior.detail_type, "horn_large", "Detail type should be horn_large")
	assert_eq(behavior.targeting, GameEnums.TargetingMode.NEAREST, "Targeting should be NEAREST")
	assert_eq(behavior.positioning, GameEnums.Positioning.FRONT, "Positioning should be FRONT")
	assert_eq(behavior.ability_priority, [0, 1, 2, 3], "Priority should be [OFF,MOB,UT,DEF]")


func test_get_behavior_module_returns_caster() -> void:
	var behavior := PartDatabase.get_behavior_module("antenna_large")
	assert_not_null(behavior, "Should return Caster behavior")
	assert_eq(behavior.module_name, "Caster", "Module name should be Caster")
	assert_eq(
		behavior.targeting,
		GameEnums.TargetingMode.HIGHEST_THREAT,
		"Targeting should be HIGHEST_THREAT"
	)
	assert_eq(behavior.positioning, GameEnums.Positioning.BACK, "Positioning should be BACK")


func test_get_behavior_module_returns_null_for_unknown() -> void:
	var behavior := PartDatabase.get_behavior_module("nonexistent")
	assert_null(behavior, "Should return null for unknown detail type")


# --- get_strain_combo() tests ---


func test_get_strain_combo_undead_tier_1() -> void:
	var combo := PartDatabase.get_strain_combo(GameEnums.Strain.UNDEAD, 1)
	assert_not_null(combo, "Should return undead tier 1 combo")
	assert_eq(combo.id, "undead_1", "ID should be undead_1")


func test_get_strain_combo_undead_tier_3() -> void:
	var combo := PartDatabase.get_strain_combo(GameEnums.Strain.UNDEAD, 3)
	assert_not_null(combo, "Should return undead tier 3 combo")
	assert_eq(combo.id, "undead_3", "ID should be undead_3")


func test_get_strain_combo_neutral_returns_null() -> void:
	var combo := PartDatabase.get_strain_combo(GameEnums.Strain.NEUTRAL, 1)
	assert_null(combo, "NEUTRAL should return null (no combo)")


func test_get_strain_combo_all_strains_tier_1() -> void:
	var strains := [
		GameEnums.Strain.UNDEAD,
		GameEnums.Strain.ROBOTIC,
		GameEnums.Strain.DRACONIC,
		GameEnums.Strain.BEAST,
		GameEnums.Strain.ELEMENTAL,
		GameEnums.Strain.ABERRANT,
	]
	for strain in strains:
		var combo := PartDatabase.get_strain_combo(strain, 1)
		assert_not_null(combo, "Strain %d tier 1 should have combo" % strain)


# --- get_part() tests ---


func test_get_part_returns_correct_part() -> void:
	var part := PartDatabase.get_part(
		"detail_horn_large", GameEnums.Strain.BEAST, GameEnums.Rarity.COMMON
	)
	assert_not_null(part, "Should return a PartData")
	assert_eq(part.shape_id, "detail_horn_large", "shape_id should match")
	assert_eq(part.strain, GameEnums.Strain.BEAST, "strain should be BEAST")
	assert_eq(part.rarity, GameEnums.Rarity.COMMON, "rarity should be COMMON")
	assert_eq(part.hp_bonus, 5.0, "hp_bonus should be 5.0 from template")
	assert_eq(part.defense_bonus, 3.0, "defense_bonus should be 3.0 from template")
	assert_eq(part.ability_id, "head_horn_large_ability", "ability_id should match")
	assert_not_null(part.behavior_module, "behavior_module should be set")


func test_get_part_constructs_sprite_path_detail() -> void:
	var part := PartDatabase.get_part(
		"detail_horn_large", GameEnums.Strain.BEAST, GameEnums.Rarity.COMMON
	)
	assert_eq(
		part.sprite_path,
		"res://assets/kenney-monster-builder-pack/PNG/Default/detail_green_horn_large.png",
		"sprite_path should use detail pattern with green color"
	)


func test_get_part_constructs_sprite_path_body() -> void:
	var part := PartDatabase.get_part("body_a", GameEnums.Strain.UNDEAD, GameEnums.Rarity.COMMON)
	assert_eq(
		part.sprite_path,
		"res://assets/kenney-monster-builder-pack/PNG/Default/body_darkA.png",
		"sprite_path should use body pattern with dark color"
	)


func test_get_part_returns_null_for_unknown() -> void:
	var part := PartDatabase.get_part(
		"nonexistent", GameEnums.Strain.BEAST, GameEnums.Rarity.COMMON
	)
	assert_null(part, "Should return null for unknown shape_id")


func test_get_part_returns_independent_instances() -> void:
	var part1 := PartDatabase.get_part(
		"detail_horn_large", GameEnums.Strain.BEAST, GameEnums.Rarity.COMMON
	)
	var part2 := PartDatabase.get_part(
		"detail_horn_large", GameEnums.Strain.UNDEAD, GameEnums.Rarity.COMMON
	)
	assert_ne(part1, part2, "Should return different instances")
	assert_ne(part1.strain, part2.strain, "Strains should differ")


# --- get_sprite_path() tests ---


func test_get_sprite_path_detail_pattern() -> void:
	var path := PartDatabase.get_sprite_path("detail_horn_large", GameEnums.Strain.BEAST)
	assert_eq(
		path,
		"res://assets/kenney-monster-builder-pack/PNG/Default/detail_green_horn_large.png",
		"Detail pattern: detail_{color}_{variant}.png"
	)


func test_get_sprite_path_body_pattern() -> void:
	var path := PartDatabase.get_sprite_path("body_a", GameEnums.Strain.UNDEAD)
	assert_eq(
		path,
		"res://assets/kenney-monster-builder-pack/PNG/Default/body_darkA.png",
		"Body pattern: {category}_{color}{Variant}.png"
	)


func test_get_sprite_path_arm_pattern() -> void:
	var path := PartDatabase.get_sprite_path("arm_c", GameEnums.Strain.ELEMENTAL)
	assert_eq(
		path,
		"res://assets/kenney-monster-builder-pack/PNG/Default/arm_blueC.png",
		"Arm pattern: arm_{color}{Variant}.png"
	)


func test_get_sprite_path_neutral_uses_dark() -> void:
	var path := PartDatabase.get_sprite_path("body_a", GameEnums.Strain.NEUTRAL)
	assert_eq(
		path,
		"res://assets/kenney-monster-builder-pack/PNG/Default/body_darkA.png",
		"NEUTRAL should use 'dark' color"
	)


func test_get_sprite_path_all_strain_colors() -> void:
	assert_eq(
		PartDatabase.get_sprite_path("body_a", GameEnums.Strain.UNDEAD),
		"res://assets/kenney-monster-builder-pack/PNG/Default/body_darkA.png",
		"UNDEAD=dark"
	)
	assert_eq(
		PartDatabase.get_sprite_path("body_a", GameEnums.Strain.ROBOTIC),
		"res://assets/kenney-monster-builder-pack/PNG/Default/body_whiteA.png",
		"ROBOTIC=white"
	)
	assert_eq(
		PartDatabase.get_sprite_path("body_a", GameEnums.Strain.DRACONIC),
		"res://assets/kenney-monster-builder-pack/PNG/Default/body_redA.png",
		"DRACONIC=red"
	)
	assert_eq(
		PartDatabase.get_sprite_path("body_a", GameEnums.Strain.ABERRANT),
		"res://assets/kenney-monster-builder-pack/PNG/Default/body_yellowA.png",
		"ABERRANT=yellow"
	)


# --- Rarity stat multiplier tests ---


func test_get_part_common_stats_unchanged() -> void:
	var part := PartDatabase.get_part(
		"detail_horn_large", GameEnums.Strain.BEAST, GameEnums.Rarity.COMMON
	)
	assert_eq(part.hp_bonus, 5.0, "COMMON hp_bonus should be base (x1.0)")
	assert_eq(part.defense_bonus, 3.0, "COMMON defense_bonus should be base (x1.0)")


func test_get_part_uncommon_stats_multiplied() -> void:
	var part := PartDatabase.get_part(
		"detail_horn_large", GameEnums.Strain.BEAST, GameEnums.Rarity.UNCOMMON
	)
	assert_almost_eq(part.hp_bonus, 6.25, 0.01, "UNCOMMON hp_bonus should be x1.25")
	assert_almost_eq(part.defense_bonus, 3.75, 0.01, "UNCOMMON defense_bonus should be x1.25")


func test_get_part_rare_stats_multiplied() -> void:
	var part := PartDatabase.get_part(
		"detail_horn_large", GameEnums.Strain.BEAST, GameEnums.Rarity.RARE
	)
	assert_almost_eq(part.hp_bonus, 7.5, 0.01, "RARE hp_bonus should be x1.5")
	assert_almost_eq(part.defense_bonus, 4.5, 0.01, "RARE defense_bonus should be x1.5")


func test_get_part_legendary_stats_multiplied() -> void:
	var part := PartDatabase.get_part(
		"detail_horn_large", GameEnums.Strain.BEAST, GameEnums.Rarity.LEGENDARY
	)
	assert_almost_eq(part.hp_bonus, 10.0, 0.01, "LEGENDARY hp_bonus should be x2.0")
	assert_almost_eq(part.defense_bonus, 6.0, 0.01, "LEGENDARY defense_bonus should be x2.0")


# --- Ability potency tests ---


func test_get_ability_with_rarity_common_unchanged() -> void:
	var ability := PartDatabase.get_ability_with_rarity(
		"head_horn_large_ability", GameEnums.Rarity.COMMON
	)
	assert_eq(ability.cooldown, 8.0, "COMMON cooldown should be base")


func test_get_ability_with_rarity_uncommon_unchanged() -> void:
	var ability := PartDatabase.get_ability_with_rarity(
		"head_horn_large_ability", GameEnums.Rarity.UNCOMMON
	)
	assert_eq(ability.cooldown, 8.0, "UNCOMMON cooldown should be base")


func test_get_ability_with_rarity_rare_cooldown_reduced() -> void:
	var ability := PartDatabase.get_ability_with_rarity(
		"head_horn_large_ability", GameEnums.Rarity.RARE
	)
	assert_almost_eq(ability.cooldown, 6.8, 0.01, "RARE cooldown should be -15% (8.0 * 0.85)")


func test_get_ability_with_rarity_legendary_cooldown_reduced() -> void:
	var ability := PartDatabase.get_ability_with_rarity(
		"head_horn_large_ability", GameEnums.Rarity.LEGENDARY
	)
	assert_almost_eq(ability.cooldown, 6.0, 0.01, "LEGENDARY cooldown should be -25% (8.0 * 0.75)")


func test_get_ability_with_rarity_legendary_effect_increased() -> void:
	var ability := PartDatabase.get_ability_with_rarity(
		"head_horn_large_ability", GameEnums.Rarity.LEGENDARY
	)
	# head_horn_large_ability has DEBUFF_STAT with amount=0.3
	assert_almost_eq(
		ability.effects[0].params["amount"],
		0.36,
		0.01,
		"LEGENDARY effect amount should be +20% (0.3 * 1.2)"
	)


func test_get_ability_with_rarity_does_not_modify_template() -> void:
	PartDatabase.get_ability_with_rarity("head_horn_large_ability", GameEnums.Rarity.LEGENDARY)
	var original := PartDatabase.get_ability("head_horn_large_ability")
	assert_eq(original.cooldown, 8.0, "Template cooldown should be unchanged")
	assert_eq(
		original.effects[0].params["amount"], 0.3, "Template effect amount should be unchanged"
	)


func test_get_ability_with_rarity_returns_null_for_unknown() -> void:
	var ability := PartDatabase.get_ability_with_rarity("nonexistent", GameEnums.Rarity.COMMON)
	assert_null(ability, "Should return null for unknown ability")


# --- generate_random_part() tests ---


func test_generate_random_part_returns_part_for_head_slot() -> void:
	var weights := {GameEnums.Rarity.COMMON: 100}
	var part := PartDatabase.generate_random_part(GameEnums.PartSlot.HEAD, weights)
	assert_not_null(part, "Should return a part for HEAD slot")
	assert_eq(part.slot, GameEnums.PartSlot.HEAD, "Slot should be HEAD")


func test_generate_random_part_returns_part_for_torso_slot() -> void:
	var weights := {GameEnums.Rarity.COMMON: 100}
	var part := PartDatabase.generate_random_part(GameEnums.PartSlot.TORSO, weights)
	assert_not_null(part, "Should return a part for TORSO slot")
	assert_eq(part.slot, GameEnums.PartSlot.TORSO, "Slot should be TORSO")


func test_generate_random_part_returns_part_for_arms_slot() -> void:
	var weights := {GameEnums.Rarity.COMMON: 100}
	var part := PartDatabase.generate_random_part(GameEnums.PartSlot.ARMS, weights)
	assert_not_null(part, "Should return a part for ARMS slot")
	assert_eq(part.slot, GameEnums.PartSlot.ARMS, "Slot should be ARMS")


func test_generate_random_part_returns_part_for_legs_slot() -> void:
	var weights := {GameEnums.Rarity.COMMON: 100}
	var part := PartDatabase.generate_random_part(GameEnums.PartSlot.LEGS, weights)
	assert_not_null(part, "Should return a part for LEGS slot")
	assert_eq(part.slot, GameEnums.PartSlot.LEGS, "Slot should be LEGS")


func test_generate_random_part_respects_common_weight() -> void:
	var weights := {GameEnums.Rarity.COMMON: 100}
	var part := PartDatabase.generate_random_part(GameEnums.PartSlot.HEAD, weights)
	assert_eq(part.rarity, GameEnums.Rarity.COMMON, "Should be COMMON with 100% weight")


func test_generate_random_part_respects_legendary_weight() -> void:
	var weights := {GameEnums.Rarity.LEGENDARY: 100}
	var part := PartDatabase.generate_random_part(GameEnums.PartSlot.HEAD, weights)
	assert_eq(part.rarity, GameEnums.Rarity.LEGENDARY, "Should be LEGENDARY with 100% weight")


func test_generate_random_part_has_valid_shape_id() -> void:
	var weights := {GameEnums.Rarity.COMMON: 100}
	var part := PartDatabase.generate_random_part(GameEnums.PartSlot.TORSO, weights)
	var valid_shapes := ["body_a", "body_b", "body_c", "body_d", "body_e", "body_f"]
	assert_true(valid_shapes.has(part.shape_id), "shape_id should be a valid torso shape")


func test_generate_random_part_has_sprite_path() -> void:
	var weights := {GameEnums.Rarity.COMMON: 100}
	var part := PartDatabase.generate_random_part(GameEnums.PartSlot.HEAD, weights)
	assert_true(part.sprite_path.length() > 0, "sprite_path should not be empty")


func test_generate_random_part_returns_independent_instance() -> void:
	var weights := {GameEnums.Rarity.COMMON: 100}
	var part1 := PartDatabase.generate_random_part(GameEnums.PartSlot.HEAD, weights)
	var part2 := PartDatabase.generate_random_part(GameEnums.PartSlot.HEAD, weights)
	assert_ne(part1, part2, "Should return independent instances")


# --- get_starter_chimeras() tests ---


func test_get_starter_chimeras_returns_three() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	assert_eq(starters.size(), 3, "Should return 3 starter chimeras")


func test_get_starter_chimeras_has_tank() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	var found := false
	for chimera in starters:
		if chimera.nickname == "Bastion":
			found = true
			assert_eq(chimera.head.strain, GameEnums.Strain.BEAST, "Tank HEAD should be BEAST")
			break
	assert_true(found, "Should find tank starter (Bastion)")


func test_get_starter_chimeras_has_dps() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	var found := false
	for chimera in starters:
		if chimera.nickname == "Ignis":
			found = true
			assert_eq(chimera.head.strain, GameEnums.Strain.DRACONIC, "DPS HEAD should be DRACONIC")
			break
	assert_true(found, "Should find DPS starter (Ignis)")


func test_get_starter_chimeras_has_utility() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	var found := false
	for chimera in starters:
		if chimera.nickname == "Cipher":
			found = true
			assert_eq(
				chimera.head.strain, GameEnums.Strain.ELEMENTAL, "Utility HEAD should be ELEMENTAL"
			)
			break
	assert_true(found, "Should find utility starter (Cipher)")


func test_get_starter_chimeras_all_have_four_parts() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	for chimera in starters:
		assert_not_null(chimera.head, "Starter should have HEAD")
		assert_not_null(chimera.torso, "Starter should have TORSO")
		assert_not_null(chimera.arms, "Starter should have ARMS")
		assert_not_null(chimera.legs, "Starter should have LEGS")
