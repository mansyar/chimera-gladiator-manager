# gdlint:ignore=max-public-methods
## Edge case tests for genetic decay across multiple matches and repair cycles.
##
## Tests decay accumulation (compounding stat loss), repair reset,
## and purebred immunity more thoroughly than the unit tests in
## test_decay.gd, which test single-application scenarios.
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


func _make_stable_chimera() -> ChimeraData:
	var b := GameEnums.Strain.BEAST
	var d := GameEnums.Strain.DRACONIC
	return _make_chimera([b, b, d, d])


func _make_pure_chimera() -> ChimeraData:
	var s := GameEnums.Strain.BEAST
	return _make_chimera([s, s, s, s])


# --- Decay accumulation across multiple matches ---


func test_decay_accumulation_three_matches_compounds() -> void:
	## apply_decay reduces stats by a percentage of the CURRENT value,
	## so multiple applications compound rather than subtracting a flat amount.
	var chimera := _make_stable_chimera()
	var original_hp := chimera.max_hp
	var original_attack := chimera.attack
	# Stable chimera: 5% stat loss per decay application
	# After 3 applications: hp * 0.95 * 0.95 * 0.95 = hp * 0.857375
	Decay.apply_decay(chimera)
	Decay.apply_decay(chimera)
	Decay.apply_decay(chimera)
	assert_eq(chimera.decay_level, 3, "decay_level should be 3 after 3 applications")
	assert_almost_eq(chimera.max_hp, original_hp * 0.95 * 0.95 * 0.95, 0.01)
	assert_almost_eq(chimera.attack, original_attack * 0.95 * 0.95 * 0.95, 0.01)


func test_decay_accumulation_five_matches() -> void:
	## Verify decay_level tracks correctly over 5 matches.
	var chimera := _make_stable_chimera()
	var original_hp := chimera.max_hp
	for i in range(5):
		Decay.apply_decay(chimera)
	assert_eq(chimera.decay_level, 5, "decay_level should be 5 after 5 applications")
	# 0.95^5 = 0.7737809375
	assert_almost_eq(chimera.max_hp, original_hp * 0.7737809375, 0.01)


func test_decay_accumulation_all_instability_levels() -> void:
	## Verify compounding works correctly for stable (5%), volatile (10%), chaotic (15%).
	for instability_config in [
		{
			"strains":
			[
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
				GameEnums.Strain.DRACONIC,
				GameEnums.Strain.DRACONIC
			],
			"multiplier": 0.95
		},
		{
			"strains":
			[
				GameEnums.Strain.BEAST,
				GameEnums.Strain.DRACONIC,
				GameEnums.Strain.ELEMENTAL,
				GameEnums.Strain.ELEMENTAL
			],
			"multiplier": 0.90
		},
		{
			"strains":
			[
				GameEnums.Strain.BEAST,
				GameEnums.Strain.DRACONIC,
				GameEnums.Strain.ELEMENTAL,
				GameEnums.Strain.UNDEAD
			],
			"multiplier": 0.85
		},
	]:
		var chimera := _make_chimera(instability_config["strains"])
		var original_hp := chimera.max_hp
		Decay.apply_decay(chimera)
		Decay.apply_decay(chimera)
		var expected_multiplier: float = (
			float(instability_config["multiplier"]) * float(instability_config["multiplier"])
		)
		assert_almost_eq(chimera.max_hp, original_hp * expected_multiplier, 0.01)


# --- Repair resets decay to zero ---


func test_repair_after_multiple_decays_resets_level() -> void:
	var chimera := _make_stable_chimera()
	Decay.apply_decay(chimera)
	Decay.apply_decay(chimera)
	Decay.apply_decay(chimera)
	assert_eq(chimera.decay_level, 3)
	Decay.repair_chimera(chimera)
	assert_eq(chimera.decay_level, 0, "decay_level should be 0 after repair")


func test_repair_after_multiple_decays_restores_stats() -> void:
	var chimera := _make_stable_chimera()
	var original_hp := chimera.max_hp
	var original_attack := chimera.attack
	var original_defense := chimera.defense
	var original_speed := chimera.speed
	Decay.apply_decay(chimera)
	Decay.apply_decay(chimera)
	Decay.repair_chimera(chimera)
	assert_almost_eq(chimera.max_hp, original_hp, 0.01, "HP should be restored")
	assert_almost_eq(chimera.attack, original_attack, 0.01, "Attack should be restored")
	assert_almost_eq(chimera.defense, original_defense, 0.01, "Defense should be restored")
	assert_almost_eq(chimera.speed, original_speed, 0.01, "Speed should be restored")


func test_repair_allows_decay_cycle() -> void:
	## After repair, decay can be applied again (decay_level restarts from 0).
	var chimera := _make_stable_chimera()
	var original_hp := chimera.max_hp
	Decay.apply_decay(chimera)
	assert_eq(chimera.decay_level, 1)
	Decay.repair_chimera(chimera)
	assert_eq(chimera.decay_level, 0)
	# Apply decay again after repair
	Decay.apply_decay(chimera)
	assert_eq(chimera.decay_level, 1, "decay_level should be 1 after post-repair decay")
	# Stats should match a single decay application from full
	assert_almost_eq(chimera.max_hp, original_hp * 0.95, 0.01)


func test_repair_cost_zero_after_repair() -> void:
	## After repair, decay_level is 0 and instability is recalculated.
	## For a stable chimera (instability=1), repair cost should still be
	## based on instability, not decay_level.
	var chimera := _make_stable_chimera()
	Decay.apply_decay(chimera)
	Decay.apply_decay(chimera)
	Decay.repair_chimera(chimera)
	# Repair cost is based on instability (1 for stable), not decay_level
	assert_eq(
		Decay.calculate_repair_cost(chimera, 0),
		50,
		"Repair cost based on instability, not decay_level"
	)


# --- Purebred immunity to decay ---


func test_purebred_check_decay_never_triggers() -> void:
	var chimera := _make_pure_chimera()
	for i in range(100):
		var result := Decay.check_decay(chimera)
		assert_false(result["decayed"], "Purebred should never decay (iter %d)" % i)
		assert_eq(result["reason"], "purebred", "Reason should be 'purebred'")


func test_purebred_apply_decay_returns_empty_and_no_stat_change() -> void:
	var chimera := _make_pure_chimera()
	var original_hp := chimera.max_hp
	var original_attack := chimera.attack
	var result := Decay.apply_decay(chimera)
	assert_eq(result, "", "apply_decay should return empty string for purebred")
	assert_almost_eq(chimera.max_hp, original_hp, 0.01, "HP unchanged")
	assert_almost_eq(chimera.attack, original_attack, 0.01, "Attack unchanged")
	assert_eq(chimera.decay_level, 0, "decay_level unchanged")


func test_purebred_repair_cost_zero() -> void:
	var chimera := _make_pure_chimera()
	assert_eq(Decay.calculate_repair_cost(chimera, 0), 0, "Purebred repair cost should be 0")
	assert_eq(
		Decay.calculate_repair_cost(chimera, 2),
		0,
		"Purebred repair cost should be 0 even with research"
	)


func test_purebred_repair_is_noop() -> void:
	var chimera := _make_pure_chimera()
	var original_hp := chimera.max_hp
	Decay.repair_chimera(chimera)
	assert_eq(chimera.decay_level, 0, "decay_level should still be 0")
	assert_almost_eq(chimera.max_hp, original_hp, 0.01, "HP should be unchanged")


func test_purebred_reinforced_genetics_reduction_on_zero_chance() -> void:
	## Purebred decay chance is 0.0, so reduction should also be 0.0.
	var reduced := Decay.apply_reinforced_genetics_reduction(0.0, 2)
	assert_almost_eq(reduced, 0.0, 0.001, "Reduction of 0.0 should stay 0.0")
