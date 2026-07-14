# gdlint:ignore=max-public-methods
## Tests for Research static utility (TRACK-004 FR-3.4).
extends GutTest

# --- Branch names ---
const BRANCH_STRAIN := "strain_mastery"
const BRANCH_LAB := "lab_engineering"
const BRANCH_COMBAT := "combat_doctrine"

# --- Strain Mastery node names ---
const SM_UNDEAD := "undead"
const SM_ROBOTIC := "robotic"
const SM_DRACONIC := "draconic"
const SM_BEAST := "beast"
const SM_ELEMENTAL := "elemental"
const SM_ABERRANT := "aberrant"

# --- Lab Engineering node names ---
const LE_GENETICS := "reinforced_genetics"
const LE_CLINIC := "clinic_efficiency"
const LE_MARKET := "market_connections"
const LE_SERUM := "stability_serum"

# --- Combat Doctrine node names ---
const CD_TACTICAL := "tactical_ai"
const CD_TUNING := "ability_tuning"
const CD_FORMATION := "formation_mastery"
const CD_BERSERK := "berserk_control"

# ==================== get_max_level ====================


func test_get_max_level_strain_mastery() -> void:
	assert_eq(Research.get_max_level(BRANCH_STRAIN, SM_UNDEAD), 3)
	assert_eq(Research.get_max_level(BRANCH_STRAIN, SM_ROBOTIC), 3)
	assert_eq(Research.get_max_level(BRANCH_STRAIN, SM_DRACONIC), 3)
	assert_eq(Research.get_max_level(BRANCH_STRAIN, SM_BEAST), 3)
	assert_eq(Research.get_max_level(BRANCH_STRAIN, SM_ELEMENTAL), 3)
	assert_eq(Research.get_max_level(BRANCH_STRAIN, SM_ABERRANT), 3)


func test_get_max_level_lab_engineering() -> void:
	assert_eq(Research.get_max_level(BRANCH_LAB, LE_GENETICS), 2)
	assert_eq(Research.get_max_level(BRANCH_LAB, LE_CLINIC), 2)
	assert_eq(Research.get_max_level(BRANCH_LAB, LE_MARKET), 2)
	assert_eq(Research.get_max_level(BRANCH_LAB, LE_SERUM), 2)


func test_get_max_level_combat_doctrine() -> void:
	assert_eq(Research.get_max_level(BRANCH_COMBAT, CD_TACTICAL), 1)
	assert_eq(Research.get_max_level(BRANCH_COMBAT, CD_TUNING), 1)
	assert_eq(Research.get_max_level(BRANCH_COMBAT, CD_FORMATION), 1)
	assert_eq(Research.get_max_level(BRANCH_COMBAT, CD_BERSERK), 1)


func test_get_max_level_unknown_branch() -> void:
	assert_eq(Research.get_max_level("unknown", SM_BEAST), 0)


func test_get_max_level_unknown_node() -> void:
	assert_eq(Research.get_max_level(BRANCH_STRAIN, "unknown"), 0)


# ==================== get_research_cost ====================


func test_get_research_cost_strain_mastery() -> void:
	assert_eq(Research.get_research_cost(BRANCH_STRAIN, SM_BEAST, 0), 1)
	assert_eq(Research.get_research_cost(BRANCH_STRAIN, SM_BEAST, 1), 1)
	assert_eq(Research.get_research_cost(BRANCH_STRAIN, SM_BEAST, 2), 1)


func test_get_research_cost_lab_engineering() -> void:
	assert_eq(Research.get_research_cost(BRANCH_LAB, LE_GENETICS, 0), 1)
	assert_eq(Research.get_research_cost(BRANCH_LAB, LE_GENETICS, 1), 1)


func test_get_research_cost_combat_doctrine() -> void:
	assert_eq(Research.get_research_cost(BRANCH_COMBAT, CD_TACTICAL, 0), 1)


func test_get_research_cost_at_max_level() -> void:
	# At max level, cost is 0 (nothing to unlock)
	assert_eq(Research.get_research_cost(BRANCH_STRAIN, SM_BEAST, 3), 0)
	assert_eq(Research.get_research_cost(BRANCH_LAB, LE_GENETICS, 2), 0)
	assert_eq(Research.get_research_cost(BRANCH_COMBAT, CD_TACTICAL, 1), 0)


# ==================== can_unlock ====================


func test_can_unlock_valid_unlock() -> void:
	assert_true(Research.can_unlock(BRANCH_STRAIN, SM_BEAST, 0, 1))
	assert_true(Research.can_unlock(BRANCH_STRAIN, SM_BEAST, 1, 1))
	assert_true(Research.can_unlock(BRANCH_STRAIN, SM_BEAST, 2, 1))
	assert_true(Research.can_unlock(BRANCH_LAB, LE_GENETICS, 0, 1))
	assert_true(Research.can_unlock(BRANCH_COMBAT, CD_TACTICAL, 0, 1))


func test_can_unlock_insufficient_points() -> void:
	assert_false(Research.can_unlock(BRANCH_STRAIN, SM_BEAST, 0, 0))
	assert_false(Research.can_unlock(BRANCH_LAB, LE_GENETICS, 0, 0))
	assert_false(Research.can_unlock(BRANCH_COMBAT, CD_TACTICAL, 0, 0))


func test_can_unlock_at_max_level() -> void:
	assert_false(Research.can_unlock(BRANCH_STRAIN, SM_BEAST, 3, 5))
	assert_false(Research.can_unlock(BRANCH_LAB, LE_GENETICS, 2, 5))
	assert_false(Research.can_unlock(BRANCH_COMBAT, CD_TACTICAL, 1, 5))


func test_can_unlock_more_points_than_needed() -> void:
	assert_true(Research.can_unlock(BRANCH_STRAIN, SM_BEAST, 0, 5))
	assert_true(Research.can_unlock(BRANCH_LAB, LE_GENETICS, 1, 3))


func test_can_unlock_unknown_branch() -> void:
	assert_false(Research.can_unlock("unknown", SM_BEAST, 0, 5))


func test_can_unlock_unknown_node() -> void:
	assert_false(Research.can_unlock(BRANCH_STRAIN, "unknown", 0, 5))


# ==================== get_effect_value - Strain Mastery ====================


func test_get_effect_value_strain_mastery_level_0() -> void:
	for node in [SM_UNDEAD, SM_ROBOTIC, SM_DRACONIC, SM_BEAST, SM_ELEMENTAL, SM_ABERRANT]:
		assert_almost_eq(Research.get_effect_value(BRANCH_STRAIN, node, 0), 0.0, 0.001)


func test_get_effect_value_strain_mastery_level_1() -> void:
	for node in [SM_UNDEAD, SM_ROBOTIC, SM_DRACONIC, SM_BEAST, SM_ELEMENTAL, SM_ABERRANT]:
		assert_almost_eq(Research.get_effect_value(BRANCH_STRAIN, node, 1), 0.05, 0.001)


func test_get_effect_value_strain_mastery_level_2() -> void:
	for node in [SM_UNDEAD, SM_ROBOTIC, SM_DRACONIC, SM_BEAST, SM_ELEMENTAL, SM_ABERRANT]:
		assert_almost_eq(Research.get_effect_value(BRANCH_STRAIN, node, 2), 0.10, 0.001)


func test_get_effect_value_strain_mastery_level_3() -> void:
	for node in [SM_UNDEAD, SM_ROBOTIC, SM_DRACONIC, SM_BEAST, SM_ELEMENTAL, SM_ABERRANT]:
		assert_almost_eq(Research.get_effect_value(BRANCH_STRAIN, node, 3), 0.15, 0.001)


# ==================== get_effect_value - Lab Engineering ====================


func test_get_effect_value_lab_engineering_level_0() -> void:
	for node in [LE_GENETICS, LE_CLINIC, LE_MARKET, LE_SERUM]:
		assert_almost_eq(Research.get_effect_value(BRANCH_LAB, node, 0), 0.0, 0.001)


func test_get_effect_value_lab_engineering_level_1() -> void:
	for node in [LE_GENETICS, LE_CLINIC, LE_MARKET, LE_SERUM]:
		assert_almost_eq(Research.get_effect_value(BRANCH_LAB, node, 1), 0.15, 0.001)


func test_get_effect_value_lab_engineering_level_2() -> void:
	for node in [LE_GENETICS, LE_CLINIC, LE_MARKET, LE_SERUM]:
		assert_almost_eq(Research.get_effect_value(BRANCH_LAB, node, 2), 0.30, 0.001)


# ==================== get_effect_value - Combat Doctrine ====================


func test_get_effect_value_combat_doctrine_level_0() -> void:
	for node in [CD_TACTICAL, CD_TUNING, CD_FORMATION, CD_BERSERK]:
		assert_almost_eq(Research.get_effect_value(BRANCH_COMBAT, node, 0), 0.0, 0.001)


func test_get_effect_value_tactical_ai() -> void:
	assert_almost_eq(Research.get_effect_value(BRANCH_COMBAT, CD_TACTICAL, 1), 0.10, 0.001)


func test_get_effect_value_ability_tuning() -> void:
	assert_almost_eq(Research.get_effect_value(BRANCH_COMBAT, CD_TUNING, 1), 0.10, 0.001)


func test_get_effect_value_formation_mastery() -> void:
	assert_almost_eq(Research.get_effect_value(BRANCH_COMBAT, CD_FORMATION, 1), 0.05, 0.001)


func test_get_effect_value_berserk_control() -> void:
	# Returns 2.0 (seconds to subtract from base 5s duration)
	assert_almost_eq(Research.get_effect_value(BRANCH_COMBAT, CD_BERSERK, 1), 2.0, 0.001)


# ==================== get_effect_value - Edge Cases ====================


func test_get_effect_value_clamps_above_max() -> void:
	# Level above max should clamp to max level value
	assert_almost_eq(Research.get_effect_value(BRANCH_STRAIN, SM_BEAST, 5), 0.15, 0.001)
	assert_almost_eq(Research.get_effect_value(BRANCH_LAB, LE_GENETICS, 5), 0.30, 0.001)
	assert_almost_eq(Research.get_effect_value(BRANCH_COMBAT, CD_TACTICAL, 5), 0.10, 0.001)


func test_get_effect_value_unknown_branch() -> void:
	assert_almost_eq(Research.get_effect_value("unknown", SM_BEAST, 1), 0.0, 0.001)


func test_get_effect_value_unknown_node() -> void:
	assert_almost_eq(Research.get_effect_value(BRANCH_STRAIN, "unknown", 1), 0.0, 0.001)
