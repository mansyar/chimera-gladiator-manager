# gdlint:ignore=max-public-methods
extends GutTest

## Tests for enemy_generator.gd static utility (TRACK-008).
##
## Verifies difficulty tier rarity weight tables,
## difficulty selection logic, and enemy roster generation.

# --- DIFFICULTY_WEIGHTS constant ---


func test_difficulty_weights_contains_four_tiers() -> void:
	assert_true(EnemyGenerator.DIFFICULTY_WEIGHTS.has("weak"), "Should have 'weak' tier")
	assert_true(EnemyGenerator.DIFFICULTY_WEIGHTS.has("normal"), "Should have 'normal' tier")
	assert_true(EnemyGenerator.DIFFICULTY_WEIGHTS.has("tough"), "Should have 'tough' tier")
	assert_true(EnemyGenerator.DIFFICULTY_WEIGHTS.has("strong"), "Should have 'strong' tier")
	assert_eq(EnemyGenerator.DIFFICULTY_WEIGHTS.size(), 4, "Should have exactly 4 tiers")


func test_weak_tier_weights() -> void:
	var weights: Dictionary = EnemyGenerator.DIFFICULTY_WEIGHTS["weak"]
	assert_eq(weights[GameEnums.Rarity.COMMON], 80, "Weak COMMON weight should be 80")
	assert_eq(weights[GameEnums.Rarity.UNCOMMON], 18, "Weak UNCOMMON weight should be 18")
	assert_eq(weights[GameEnums.Rarity.RARE], 2, "Weak RARE weight should be 2")
	assert_eq(weights[GameEnums.Rarity.LEGENDARY], 0, "Weak LEGENDARY weight should be 0")


func test_normal_tier_weights() -> void:
	var weights: Dictionary = EnemyGenerator.DIFFICULTY_WEIGHTS["normal"]
	assert_eq(weights[GameEnums.Rarity.COMMON], 60, "Normal COMMON weight should be 60")
	assert_eq(weights[GameEnums.Rarity.UNCOMMON], 30, "Normal UNCOMMON weight should be 30")
	assert_eq(weights[GameEnums.Rarity.RARE], 9, "Normal RARE weight should be 9")
	assert_eq(weights[GameEnums.Rarity.LEGENDARY], 1, "Normal LEGENDARY weight should be 1")


func test_tough_tier_weights() -> void:
	var weights: Dictionary = EnemyGenerator.DIFFICULTY_WEIGHTS["tough"]
	assert_eq(weights[GameEnums.Rarity.COMMON], 45, "Tough COMMON weight should be 45")
	assert_eq(weights[GameEnums.Rarity.UNCOMMON], 35, "Tough UNCOMMON weight should be 35")
	assert_eq(weights[GameEnums.Rarity.RARE], 18, "Tough RARE weight should be 18")
	assert_eq(weights[GameEnums.Rarity.LEGENDARY], 2, "Tough LEGENDARY weight should be 2")


func test_strong_tier_weights() -> void:
	var weights: Dictionary = EnemyGenerator.DIFFICULTY_WEIGHTS["strong"]
	assert_eq(weights[GameEnums.Rarity.COMMON], 30, "Strong COMMON weight should be 30")
	assert_eq(weights[GameEnums.Rarity.UNCOMMON], 40, "Strong UNCOMMON weight should be 40")
	assert_eq(weights[GameEnums.Rarity.RARE], 25, "Strong RARE weight should be 25")
	assert_eq(weights[GameEnums.Rarity.LEGENDARY], 5, "Strong LEGENDARY weight should be 5")
