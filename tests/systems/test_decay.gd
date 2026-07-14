# gdlint:ignore=max-public-methods
## Tests for decay.gd static utility (FR-3.3).
extends GutTest

# --- Test Helpers ---

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


func _make_pure_chimera() -> ChimeraData:
	var s := GameEnums.Strain.BEAST
	return _make_chimera([s, s, s, s])


func _make_stable_chimera() -> ChimeraData:
	var b := GameEnums.Strain.BEAST
	var d := GameEnums.Strain.DRACONIC
	return _make_chimera([b, b, d, d])


func _make_volatile_chimera() -> ChimeraData:
	var b := GameEnums.Strain.BEAST
	var d := GameEnums.Strain.DRACONIC
	var e := GameEnums.Strain.ELEMENTAL
	return _make_chimera([b, d, e, e])


func _make_chaotic_chimera() -> ChimeraData:
	return _make_chimera(
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.ELEMENTAL,
			GameEnums.Strain.UNDEAD,
		]
	)


# --- check_decay ---


func test_check_decay_purebred_never_decays() -> void:
	var chimera := _make_pure_chimera()
	for i in range(100):
		var result := Decay.check_decay(chimera)
		assert_false(result["decayed"], "Purebred should never decay (iter %d)" % i)


func test_check_decay_purebred_reason() -> void:
	var chimera := _make_pure_chimera()
	var result := Decay.check_decay(chimera)
	assert_eq(result["reason"], "purebred")


func test_check_decay_returns_decayed_key() -> void:
	var chimera := _make_stable_chimera()
	var result := Decay.check_decay(chimera)
	assert_true(result.has("decayed"))


func test_check_decay_returns_stat_loss_percent_key() -> void:
	var chimera := _make_stable_chimera()
	var result := Decay.check_decay(chimera)
	assert_true(result.has("stat_loss_percent"))


func test_check_decay_returns_reason_key() -> void:
	var chimera := _make_stable_chimera()
	var result := Decay.check_decay(chimera)
	assert_true(result.has("reason"))


func test_check_decay_chaotic_can_decay() -> void:
	var chimera := _make_chaotic_chimera()
	var decayed_count := 0
	for i in range(100):
		var result := Decay.check_decay(chimera)
		if result["decayed"]:
			decayed_count += 1
	assert_true(
		decayed_count > 0, "Chaotic chimera (50%% chance) should decay at least once in 100 rolls"
	)


func test_check_decay_stable_can_decay() -> void:
	var chimera := _make_stable_chimera()
	var decayed_count := 0
	for i in range(100):
		var result := Decay.check_decay(chimera)
		if result["decayed"]:
			decayed_count += 1
	assert_true(
		decayed_count > 0, "Stable chimera (15%% chance) should decay at least once in 100 rolls"
	)


func test_check_decay_decayed_returns_correct_percent() -> void:
	var chimera := _make_chaotic_chimera()
	for i in range(100):
		var result := Decay.check_decay(chimera)
		if result["decayed"]:
			assert_eq(result["stat_loss_percent"], 15)
			return
	fail_test("Chaotic chimera never decayed in 100 rolls")


func test_check_decay_resisted_returns_zero_percent() -> void:
	var chimera := _make_chaotic_chimera()
	for i in range(100):
		var result := Decay.check_decay(chimera)
		if not result["decayed"]:
			assert_eq(result["stat_loss_percent"], 0)
			assert_eq(result["reason"], "decay_resisted")
			return
	# If all 100 rolls decayed, just pass (extremely unlikely but valid)


# --- apply_decay ---


func test_apply_decay_stable_reduces_stats() -> void:
	var chimera := _make_stable_chimera()
	var original_hp := chimera.max_hp
	var original_attack := chimera.attack
	var original_defense := chimera.defense
	var original_speed := chimera.speed
	Decay.apply_decay(chimera)
	assert_almost_eq(chimera.max_hp, original_hp * 0.95, 0.01)
	assert_almost_eq(chimera.attack, original_attack * 0.95, 0.01)
	assert_almost_eq(chimera.defense, original_defense * 0.95, 0.01)
	assert_almost_eq(chimera.speed, original_speed * 0.95, 0.01)


func test_apply_decay_volatile_reduces_stats() -> void:
	var chimera := _make_volatile_chimera()
	var original_hp := chimera.max_hp
	var original_attack := chimera.attack
	var original_defense := chimera.defense
	var original_speed := chimera.speed
	Decay.apply_decay(chimera)
	assert_almost_eq(chimera.max_hp, original_hp * 0.90, 0.01)
	assert_almost_eq(chimera.attack, original_attack * 0.90, 0.01)
	assert_almost_eq(chimera.defense, original_defense * 0.90, 0.01)
	assert_almost_eq(chimera.speed, original_speed * 0.90, 0.01)


func test_apply_decay_chaotic_reduces_stats() -> void:
	var chimera := _make_chaotic_chimera()
	var original_hp := chimera.max_hp
	var original_attack := chimera.attack
	var original_defense := chimera.defense
	var original_speed := chimera.speed
	Decay.apply_decay(chimera)
	assert_almost_eq(chimera.max_hp, original_hp * 0.85, 0.01)
	assert_almost_eq(chimera.attack, original_attack * 0.85, 0.01)
	assert_almost_eq(chimera.defense, original_defense * 0.85, 0.01)
	assert_almost_eq(chimera.speed, original_speed * 0.85, 0.01)


func test_apply_decay_increments_decay_level() -> void:
	var chimera := _make_stable_chimera()
	assert_eq(chimera.decay_level, 0)
	Decay.apply_decay(chimera)
	assert_eq(chimera.decay_level, 1)
	Decay.apply_decay(chimera)
	assert_eq(chimera.decay_level, 2)


func test_apply_decay_stable_returns_percentage_string() -> void:
	var chimera := _make_stable_chimera()
	var result := Decay.apply_decay(chimera)
	assert_eq(result, "5%")


func test_apply_decay_volatile_returns_percentage_string() -> void:
	var chimera := _make_volatile_chimera()
	var result := Decay.apply_decay(chimera)
	assert_eq(result, "10%")


func test_apply_decay_chaotic_returns_percentage_string() -> void:
	var chimera := _make_chaotic_chimera()
	var result := Decay.apply_decay(chimera)
	assert_eq(result, "15%")


func test_apply_decay_pure_returns_empty() -> void:
	var chimera := _make_pure_chimera()
	var original_hp := chimera.max_hp
	var result := Decay.apply_decay(chimera)
	assert_eq(result, "")
	assert_almost_eq(chimera.max_hp, original_hp, 0.01)
	assert_eq(chimera.decay_level, 0)


# --- calculate_repair_cost ---


func test_calculate_repair_cost_pure() -> void:
	var chimera := _make_pure_chimera()
	assert_eq(Decay.calculate_repair_cost(chimera, 0), 0)


func test_calculate_repair_cost_stable_no_research() -> void:
	var chimera := _make_stable_chimera()
	assert_eq(Decay.calculate_repair_cost(chimera, 0), 50)


func test_calculate_repair_cost_volatile_no_research() -> void:
	var chimera := _make_volatile_chimera()
	assert_eq(Decay.calculate_repair_cost(chimera, 0), 100)


func test_calculate_repair_cost_chaotic_no_research() -> void:
	var chimera := _make_chaotic_chimera()
	assert_eq(Decay.calculate_repair_cost(chimera, 0), 200)


func test_calculate_repair_cost_stable_level_1() -> void:
	var chimera := _make_stable_chimera()
	# 50 * 0.85 = 42 (int truncation)
	assert_eq(Decay.calculate_repair_cost(chimera, 1), 42)


func test_calculate_repair_cost_chaotic_level_2() -> void:
	var chimera := _make_chaotic_chimera()
	# 200 * 0.70 = 140
	assert_eq(Decay.calculate_repair_cost(chimera, 2), 140)


func test_calculate_repair_cost_caps_at_level_2() -> void:
	var chimera := _make_chaotic_chimera()
	assert_eq(Decay.calculate_repair_cost(chimera, 3), Decay.calculate_repair_cost(chimera, 2))
	assert_eq(Decay.calculate_repair_cost(chimera, 99), Decay.calculate_repair_cost(chimera, 2))


# --- repair_chimera ---


func test_repair_resets_decay_level() -> void:
	var chimera := _make_stable_chimera()
	Decay.apply_decay(chimera)
	Decay.apply_decay(chimera)
	assert_eq(chimera.decay_level, 2)
	Decay.repair_chimera(chimera)
	assert_eq(chimera.decay_level, 0)


func test_repair_recalculates_stats() -> void:
	var chimera := _make_stable_chimera()
	var original_hp := chimera.max_hp
	var original_attack := chimera.attack
	var original_defense := chimera.defense
	var original_speed := chimera.speed
	Decay.apply_decay(chimera)
	# Verify stats were reduced
	assert_lt(chimera.max_hp, original_hp)
	Decay.repair_chimera(chimera)
	# Verify stats are restored
	assert_almost_eq(chimera.max_hp, original_hp, 0.01)
	assert_almost_eq(chimera.attack, original_attack, 0.01)
	assert_almost_eq(chimera.defense, original_defense, 0.01)
	assert_almost_eq(chimera.speed, original_speed, 0.01)


func test_repair_pure_chimera_no_change() -> void:
	var chimera := _make_pure_chimera()
	var original_hp := chimera.max_hp
	Decay.repair_chimera(chimera)
	assert_eq(chimera.decay_level, 0)
	assert_almost_eq(chimera.max_hp, original_hp, 0.01)


# --- apply_reinforced_genetics_reduction ---


func test_reinforced_genetics_level_0_no_reduction() -> void:
	assert_almost_eq(Decay.apply_reinforced_genetics_reduction(0.30, 0), 0.30, 0.001)


func test_reinforced_genetics_level_1_reduces_15_percent() -> void:
	# 0.30 * 0.85 = 0.255
	assert_almost_eq(Decay.apply_reinforced_genetics_reduction(0.30, 1), 0.255, 0.001)


func test_reinforced_genetics_level_2_reduces_30_percent() -> void:
	# 0.30 * 0.70 = 0.21
	assert_almost_eq(Decay.apply_reinforced_genetics_reduction(0.30, 2), 0.21, 0.001)


func test_reinforced_genetics_caps_at_level_2() -> void:
	var level2_result := Decay.apply_reinforced_genetics_reduction(0.50, 2)
	var level5_result := Decay.apply_reinforced_genetics_reduction(0.50, 5)
	assert_almost_eq(level5_result, level2_result, 0.001)


func test_reinforced_genetics_zero_base_returns_zero() -> void:
	assert_almost_eq(Decay.apply_reinforced_genetics_reduction(0.0, 2), 0.0, 0.001)


# --- salvage_chimera ---


func test_salvage_produces_neutral_parts() -> void:
	var chimera := _make_chaotic_chimera()
	var parts := Decay.salvage_chimera(chimera)
	assert_eq(parts.size(), 4)
	for part in parts:
		assert_eq(part.strain, GameEnums.Strain.NEUTRAL)


func test_salvage_retains_base_stats() -> void:
	var chimera := _make_stable_chimera()
	var original_parts := chimera.get_parts()
	var salvaged := Decay.salvage_chimera(chimera)
	assert_eq(salvaged.size(), original_parts.size())
	for i in range(salvaged.size()):
		assert_almost_eq(salvaged[i].hp_bonus, original_parts[i].hp_bonus, 0.01)
		assert_almost_eq(salvaged[i].attack_bonus, original_parts[i].attack_bonus, 0.01)
		assert_almost_eq(salvaged[i].defense_bonus, original_parts[i].defense_bonus, 0.01)
		assert_almost_eq(salvaged[i].speed_bonus, original_parts[i].speed_bonus, 0.01)


func test_salvage_all_neutral_is_pure() -> void:
	var chimera := _make_chaotic_chimera()
	var salvaged := Decay.salvage_chimera(chimera)
	# Assemble a new chimera from salvaged parts
	var new_chimera := ChimeraData.new()
	new_chimera.head = salvaged[0]
	new_chimera.torso = salvaged[1]
	new_chimera.arms = salvaged[2]
	new_chimera.legs = salvaged[3]
	new_chimera.calculate_instability()
	assert_eq(new_chimera.instability, 0)


func test_salvage_does_not_modify_original() -> void:
	var chimera := _make_chaotic_chimera()
	var original_strains: Array[GameEnums.Strain] = []
	for part in chimera.get_parts():
		original_strains.append(part.strain)
	Decay.salvage_chimera(chimera)
	var current_parts := chimera.get_parts()
	for i in range(current_parts.size()):
		assert_eq(
			current_parts[i].strain, original_strains[i], "Original parts should not be modified"
		)


func test_salvage_skips_null_parts() -> void:
	var chimera := ChimeraData.new()
	chimera.head = _make_part(GameEnums.Strain.BEAST, GameEnums.PartSlot.HEAD)
	chimera.torso = null
	chimera.arms = _make_part(GameEnums.Strain.DRACONIC, GameEnums.PartSlot.ARMS)
	chimera.legs = null
	var salvaged := Decay.salvage_chimera(chimera)
	assert_eq(salvaged.size(), 2)
	for part in salvaged:
		assert_eq(part.strain, GameEnums.Strain.NEUTRAL)
