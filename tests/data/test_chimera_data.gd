extends GutTest

## Tests for ChimeraData class.

var chimera: ChimeraData


func before_each() -> void:
	chimera = ChimeraData.new()


func _make_part(
	slot: GameEnums.PartSlot,
	strain: GameEnums.Strain,
	hp: float = 10.0,
	atk: float = 5.0,
	def_val: float = 3.0,
	spd: float = 7.0,
	range_val: float = 32.0
) -> PartData:
	var part := PartData.new()
	part.slot = slot
	part.strain = strain
	part.hp_bonus = hp
	part.attack_bonus = atk
	part.defense_bonus = def_val
	part.speed_bonus = spd
	part.attack_range = range_val
	return part


func _setup_purebred(strain: GameEnums.Strain) -> void:
	chimera.head = _make_part(GameEnums.PartSlot.HEAD, strain)
	chimera.torso = _make_part(GameEnums.PartSlot.TORSO, strain)
	chimera.arms = _make_part(GameEnums.PartSlot.ARMS, strain)
	chimera.legs = _make_part(GameEnums.PartSlot.LEGS, strain)


func _setup_mixed(strains: Array) -> void:
	chimera.head = _make_part(GameEnums.PartSlot.HEAD, strains[0])
	chimera.torso = _make_part(GameEnums.PartSlot.TORSO, strains[1])
	chimera.arms = _make_part(GameEnums.PartSlot.ARMS, strains[2])
	chimera.legs = _make_part(GameEnums.PartSlot.LEGS, strains[3])


# --- get_parts() tests ---


func test_get_parts_returns_four_parts() -> void:
	_setup_purebred(GameEnums.Strain.UNDEAD)
	var parts := chimera.get_parts()
	assert_eq(parts.size(), 4, "Should return 4 parts")
	assert_eq(parts[0], chimera.head, "First should be head")
	assert_eq(parts[1], chimera.torso, "Second should be torso")
	assert_eq(parts[2], chimera.arms, "Third should be arms")
	assert_eq(parts[3], chimera.legs, "Fourth should be legs")


# --- get_part() tests ---


func test_get_part_returns_head() -> void:
	_setup_purebred(GameEnums.Strain.UNDEAD)
	assert_eq(chimera.get_part(GameEnums.PartSlot.HEAD), chimera.head, "HEAD should return head")


func test_get_part_returns_torso() -> void:
	_setup_purebred(GameEnums.Strain.UNDEAD)
	assert_eq(
		chimera.get_part(GameEnums.PartSlot.TORSO), chimera.torso, "TORSO should return torso"
	)


func test_get_part_returns_arms() -> void:
	_setup_purebred(GameEnums.Strain.UNDEAD)
	assert_eq(chimera.get_part(GameEnums.PartSlot.ARMS), chimera.arms, "ARMS should return arms")


func test_get_part_returns_legs() -> void:
	_setup_purebred(GameEnums.Strain.UNDEAD)
	assert_eq(chimera.get_part(GameEnums.PartSlot.LEGS), chimera.legs, "LEGS should return legs")


# --- recalculate_stats() tests ---


func test_recalculate_stats_sums_bonuses() -> void:
	_setup_mixed(
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	chimera.calculate_instability()
	chimera.recalculate_stats()
	assert_eq(chimera.max_hp, 40.0, "max_hp should be sum of hp_bonus")
	assert_eq(chimera.attack, 20.0, "attack should be sum of attack_bonus")
	assert_eq(chimera.defense, 12.0, "defense should be sum of defense_bonus")
	assert_eq(chimera.speed, 28.0, "speed should be sum of speed_bonus")


func test_recalculate_stats_applies_purebred_multiplier() -> void:
	_setup_purebred(GameEnums.Strain.UNDEAD)
	chimera.calculate_instability()
	chimera.recalculate_stats()
	assert_almost_eq(chimera.max_hp, 48.0, 0.01, "max_hp should have purebred multiplier")
	assert_almost_eq(chimera.attack, 24.0, 0.01, "attack should have purebred multiplier")
	assert_almost_eq(chimera.defense, 14.4, 0.01, "defense should have purebred multiplier")
	assert_almost_eq(chimera.speed, 33.6, 0.01, "speed should have purebred multiplier")


func test_recalculate_stats_applies_research_bonuses() -> void:
	_setup_mixed(
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	chimera.calculate_instability()
	chimera.recalculate_stats({"max_hp": 1.5, "attack": 2.0})
	assert_eq(chimera.max_hp, 60.0, "max_hp should have research multiplier")
	assert_eq(chimera.attack, 40.0, "attack should have research multiplier")
	assert_eq(chimera.defense, 12.0, "defense should not have research multiplier")
	assert_eq(chimera.speed, 28.0, "speed should not have research multiplier")


func test_recalculate_stats_sets_attack_range_from_arms() -> void:
	_setup_purebred(GameEnums.Strain.UNDEAD)
	chimera.arms.attack_range = 64.0
	chimera.calculate_instability()
	chimera.recalculate_stats()
	assert_eq(chimera.attack_range, 64.0, "attack_range should come from arms part")


# --- calculate_instability() tests ---


func test_calculate_instability_zero_for_purebred() -> void:
	_setup_purebred(GameEnums.Strain.UNDEAD)
	chimera.calculate_instability()
	assert_eq(chimera.instability, 0, "Purebred should have instability 0")
	assert_eq(chimera.strain_count, 1, "Purebred should have strain_count 1")


func test_calculate_instability_three_for_all_different() -> void:
	_setup_mixed(
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	chimera.calculate_instability()
	assert_eq(chimera.instability, 3, "All different should have instability 3")
	assert_eq(chimera.strain_count, 4, "All different should have strain_count 4")


func test_calculate_instability_one_for_two_strains() -> void:
	_setup_mixed(
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.ROBOTIC,
		]
	)
	chimera.calculate_instability()
	assert_eq(chimera.instability, 1, "Two strains should have instability 1")
	assert_eq(chimera.strain_count, 2, "Two strains should have strain_count 2")


func test_calculate_instability_sets_dominant_strain() -> void:
	_setup_mixed(
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
		]
	)
	chimera.calculate_instability()
	assert_eq(chimera.dominant_strain, GameEnums.Strain.UNDEAD, "Dominant strain should be UNDEAD")


# --- get_combo_ability() tests ---


func test_get_combo_ability_tier_one_for_two_same() -> void:
	_setup_mixed(
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
		]
	)
	chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 1, "2 same-strain should give combo_tier 1 (Basic)")


func test_get_combo_ability_tier_two_for_three_same() -> void:
	_setup_mixed(
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
		]
	)
	chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 2, "3 same-strain should give combo_tier 2 (Enhanced)")


func test_get_combo_ability_tier_three_for_four_same() -> void:
	_setup_purebred(GameEnums.Strain.UNDEAD)
	chimera.get_combo_ability()
	assert_eq(chimera.combo_tier, 3, "4 same-strain should give combo_tier 3 (Ultimate)")


func test_get_combo_ability_returns_null_for_all_different() -> void:
	_setup_mixed(
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var result := chimera.get_combo_ability()
	assert_null(result, "All-different should return null")
	assert_eq(chimera.combo_tier, 0, "All-different should have combo_tier 0")
