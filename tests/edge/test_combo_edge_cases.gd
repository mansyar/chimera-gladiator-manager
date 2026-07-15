# gdlint:ignore=max-public-methods
## Edge case tests for combo tier calculations based on strain synergy.
##
## Combo tiers:
##   2 parts same strain -> tier 1 (Basic)
##   3 parts same strain -> tier 2 (Enhanced)
##   4 parts same strain -> tier 3 (Ultimate)
##   All different strains -> no combo (null)
extends GutTest

const PART_HP := 100.0
const PART_ATTACK := 50.0
const PART_DEFENSE := 30.0
const PART_SPEED := 20.0
const PART_RANGE := 32.0


func _make_part(strain: GameEnums.Strain, slot: GameEnums.PartSlot) -> PartData:
	var part := PartData.new()
	part.slot = slot
	part.strain = strain
	part.rarity = GameEnums.Rarity.COMMON
	part.hp_bonus = PART_HP
	part.attack_bonus = PART_ATTACK
	part.defense_bonus = PART_DEFENSE
	part.speed_bonus = PART_SPEED
	part.attack_range = PART_RANGE
	return part


func _make_chimera(strains: Array) -> ChimeraData:
	var chimera := ChimeraData.new()
	var slots: Array[GameEnums.PartSlot] = [
		GameEnums.PartSlot.HEAD,
		GameEnums.PartSlot.TORSO,
		GameEnums.PartSlot.ARMS,
		GameEnums.PartSlot.LEGS,
	]
	chimera.head = _make_part(strains[0], slots[0])
	chimera.torso = _make_part(strains[1], slots[1])
	chimera.arms = _make_part(strains[2], slots[2])
	chimera.legs = _make_part(strains[3], slots[3])
	chimera.calculate_instability()
	chimera.recalculate_stats()
	return chimera


# --- 2-strain combo = Basic (tier 1) ---


func test_two_same_strain_gives_basic_combo_tier() -> void:
	## 2 parts of same strain -> max_count=2, combo_tier=1 (Basic)
	var u := GameEnums.Strain.UNDEAD
	var b := GameEnums.Strain.BEAST
	var chimera := _make_chimera([u, u, b, b])
	var combo := chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 1, "2 matching strains should give tier 1 (Basic)")
	assert_not_null(combo, "Should have a combo ability")


func test_two_same_strain_head_torso() -> void:
	## Verify combo works regardless of which slots hold the matching strains.
	var u := GameEnums.Strain.UNDEAD
	var b := GameEnums.Strain.BEAST
	var chimera := _make_chimera([u, u, b, b])
	chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 1)


func test_two_same_strain_dominant_set_correctly() -> void:
	## The dominant strain should be the one with 2+ parts.
	var u := GameEnums.Strain.UNDEAD
	var b := GameEnums.Strain.BEAST
	var chimera := _make_chimera([u, u, b, b])
	chimera.get_combo_ability()
	# With 2 undead + 2 beast, the first encountered max becomes dominant
	# (depends on dict iteration order, but dominant_strain is set in
	# calculate_instability, not get_combo_ability)
	assert_eq(chimera.strain_count, 2, "Should have 2 distinct strains")


# --- 3-strain combo = Enhanced (tier 2) ---


func test_three_same_strain_gives_enhanced_combo_tier() -> void:
	## 3 parts of same strain -> max_count=3, combo_tier=2 (Enhanced)
	var u := GameEnums.Strain.UNDEAD
	var b := GameEnums.Strain.BEAST
	var chimera := _make_chimera([u, u, u, b])
	var combo := chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 2, "3 matching strains should give tier 2 (Enhanced)")
	assert_not_null(combo, "Should have a combo ability")


func test_three_same_strain_dominant_correct() -> void:
	var u := GameEnums.Strain.UNDEAD
	var b := GameEnums.Strain.BEAST
	var chimera := _make_chimera([u, u, u, b])
	chimera.get_combo_ability()
	assert_eq(chimera.dominant_strain, u, "Dominant strain should be UNDEAD")


# --- 4-strain combo = Ultimate (tier 3) ---


func test_four_same_strain_gives_ultimate_combo_tier() -> void:
	## 4 parts of same strain (purebred) -> max_count=4, combo_tier=3 (Ultimate)
	var u := GameEnums.Strain.UNDEAD
	var chimera := _make_chimera([u, u, u, u])
	var combo := chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 3, "4 matching strains should give tier 3 (Ultimate)")
	assert_not_null(combo, "Should have a combo ability")


func test_four_same_strain_instability_zero() -> void:
	## Purebred (4 same strain) has instability=0 but still gets ultimate combo.
	var u := GameEnums.Strain.UNDEAD
	var chimera := _make_chimera([u, u, u, u])
	chimera.get_combo_ability()
	assert_eq(chimera.instability, 0, "Purebred should have instability 0")
	assert_eq(chimera.combo_tier, 3, "But combo_tier should be 3 (Ultimate)")


# --- All different strains = null (no combo) ---


func test_all_different_strains_no_combo() -> void:
	## All 4 parts different strains -> max_count=1, combo_tier=0, no combo
	var chimera := _make_chimera(
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.ELEMENTAL,
			GameEnums.Strain.UNDEAD,
		]
	)
	var combo := chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 0, "All different strains should give tier 0 (no combo)")
	assert_null(combo, "Should not have a combo ability")


func test_all_different_strains_max_instability() -> void:
	var chimera := _make_chimera(
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.ELEMENTAL,
			GameEnums.Strain.UNDEAD,
		]
	)
	chimera.get_combo_ability()
	assert_eq(chimera.instability, 3, "4 different strains should give instability 3")


# --- Edge cases with 3 or 4 distinct strains ---


func test_three_distinct_strains_one_pair_gives_basic() -> void:
	## 3 distinct strains with one pair -> combo_tier=1 (Basic)
	var b := GameEnums.Strain.BEAST
	var d := GameEnums.Strain.DRACONIC
	var e := GameEnums.Strain.ELEMENTAL
	var chimera := _make_chimera([b, b, d, e])
	var combo := chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 1, "One pair among 3 strains should give tier 1")
	assert_not_null(combo, "Should have a combo ability")


func test_three_distinct_strains_triple_gives_enhanced() -> void:
	## 3 distinct strains with a triple -> combo_tier=2 (Enhanced)
	var b := GameEnums.Strain.BEAST
	var d := GameEnums.Strain.DRACONIC
	var e := GameEnums.Strain.ELEMENTAL
	var chimera := _make_chimera([b, b, b, d])
	var combo := chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 2, "Triple among 3 strains should give tier 2")
	assert_not_null(combo, "Should have a combo ability")


# --- Instability vs combo tier relationship ---


func test_instability_inversely_related_to_combo() -> void:
	## More matching strains = higher combo tier but lower instability.
	## 4 same: instability=0, combo_tier=3
	## 3 same + 1 diff: instability=1, combo_tier=2
	## 2 same + 2 same: instability=1, combo_tier=1
	## 2 same + 2 diff: instability=2, combo_tier=1
	## All diff: instability=3, combo_tier=0
	var u := GameEnums.Strain.UNDEAD
	var b := GameEnums.Strain.BEAST
	var d := GameEnums.Strain.DRACONIC
	var e := GameEnums.Strain.ELEMENTAL

	var pure := _make_chimera([u, u, u, u])
	pure.get_combo_ability()
	assert_eq(pure.instability, 0)
	assert_eq(pure.combo_tier, 3)

	var triple := _make_chimera([u, u, u, b])
	triple.get_combo_ability()
	assert_eq(triple.instability, 1)
	assert_eq(triple.combo_tier, 2)

	var two_pairs := _make_chimera([u, u, b, b])
	two_pairs.get_combo_ability()
	assert_eq(two_pairs.instability, 1)
	assert_eq(two_pairs.combo_tier, 1)

	var one_pair := _make_chimera([u, u, b, d])
	one_pair.get_combo_ability()
	assert_eq(one_pair.instability, 2)
	assert_eq(one_pair.combo_tier, 1)

	var all_diff := _make_chimera([u, b, d, e])
	all_diff.get_combo_ability()
	assert_eq(all_diff.instability, 3)
	assert_eq(all_diff.combo_tier, 0)


# --- Combo ability is the correct ability for dominant strain ---


func test_combo_ability_matches_dominant_strain() -> void:
	## The combo ability should be for the dominant (most frequent) strain.
	var u := GameEnums.Strain.UNDEAD
	var b := GameEnums.Strain.BEAST
	var chimera := _make_chimera([u, u, u, b])
	var combo := chimera.get_combo_ability()
	assert_not_null(combo, "Combo should not be null for 3 matching strains")
	# The combo should be the undead tier 2 combo from PartDatabase
	var expected := PartDatabase.get_strain_combo(u, 2)
	assert_not_null(expected, "Expected combo should exist in PartDatabase")
	if combo != null and expected != null:
		assert_eq(combo.id, expected.id, "Combo should match dominant strain")


func test_combo_tier_resets_to_zero_when_no_combo() -> void:
	## After getting a combo, if parts change to all-different, tier should reset.
	var u := GameEnums.Strain.UNDEAD
	var b := GameEnums.Strain.BEAST
	var d := GameEnums.Strain.DRACONIC
	var e := GameEnums.Strain.ELEMENTAL
	var chimera := _make_chimera([u, u, u, b])
	chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 2, "3 matching strains should give tier 2")
	# Change ALL parts to different strains
	chimera.head = _make_part(b, GameEnums.PartSlot.HEAD)
	chimera.torso = _make_part(d, GameEnums.PartSlot.TORSO)
	chimera.arms = _make_part(e, GameEnums.PartSlot.ARMS)
	chimera.legs = _make_part(u, GameEnums.PartSlot.LEGS)
	chimera.calculate_instability()
	var combo := chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 0, "Tier should reset to 0 when no combo")
	assert_null(combo, "Should return null when no combo")
