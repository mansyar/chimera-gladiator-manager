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


# --- _get_difficulty_tier ---


func test_get_difficulty_tier_regular_low_streak_returns_normal() -> void:
	var tier: String = EnemyGenerator._get_difficulty_tier("regular", 0, 0)
	assert_eq(tier, "normal", "Regular with losing_streak < 3 should return 'normal'")


func test_get_difficulty_tier_regular_streak_2_returns_normal() -> void:
	var tier: String = EnemyGenerator._get_difficulty_tier("regular", 2, 0)
	assert_eq(tier, "normal", "Regular with losing_streak = 2 should return 'normal'")


func test_get_difficulty_tier_regular_streak_3_returns_weak() -> void:
	var tier: String = EnemyGenerator._get_difficulty_tier("regular", 3, 0)
	assert_eq(tier, "weak", "Regular with losing_streak >= 3 should return 'weak' (rubber-band)")


func test_get_difficulty_tier_regular_streak_5_returns_weak() -> void:
	var tier: String = EnemyGenerator._get_difficulty_tier("regular", 5, 0)
	assert_eq(tier, "weak", "Regular with losing_streak > 3 should return 'weak' (rubber-band)")


func test_get_difficulty_tier_tournament_tier_1_returns_tough() -> void:
	var tier: String = EnemyGenerator._get_difficulty_tier("tournament", 0, 1)
	assert_eq(tier, "tough", "Tournament tier 1 should return 'tough'")


func test_get_difficulty_tier_tournament_tier_2_returns_tough() -> void:
	var tier: String = EnemyGenerator._get_difficulty_tier("tournament", 0, 2)
	assert_eq(tier, "tough", "Tournament tier 2 should return 'tough'")


func test_get_difficulty_tier_tournament_tier_3_returns_strong() -> void:
	var tier: String = EnemyGenerator._get_difficulty_tier("tournament", 0, 3)
	assert_eq(tier, "strong", "Tournament tier 3 should return 'strong'")


func test_get_difficulty_tier_tournament_tier_4_returns_strong() -> void:
	var tier: String = EnemyGenerator._get_difficulty_tier("tournament", 0, 4)
	assert_eq(tier, "strong", "Tournament tier 4 should return 'strong'")


# --- _generate_enemy_chimera ---


func test_generate_enemy_chimera_returns_chimera_data() -> void:
	var weights: Dictionary = EnemyGenerator.DIFFICULTY_WEIGHTS["normal"]
	var chimera: ChimeraData = EnemyGenerator._generate_enemy_chimera(weights)
	assert_not_null(chimera, "Should return a non-null ChimeraData")
	assert_true(chimera is ChimeraData, "Should be a ChimeraData instance")


func test_generate_enemy_chimera_has_four_parts() -> void:
	var weights: Dictionary = EnemyGenerator.DIFFICULTY_WEIGHTS["normal"]
	var chimera: ChimeraData = EnemyGenerator._generate_enemy_chimera(weights)
	assert_not_null(chimera.head, "Should have a head part")
	assert_not_null(chimera.torso, "Should have a torso part")
	assert_not_null(chimera.arms, "Should have an arms part")
	assert_not_null(chimera.legs, "Should have a legs part")


func test_generate_enemy_chimera_parts_have_correct_slots() -> void:
	var weights: Dictionary = EnemyGenerator.DIFFICULTY_WEIGHTS["normal"]
	var chimera: ChimeraData = EnemyGenerator._generate_enemy_chimera(weights)
	assert_eq(chimera.head.slot, GameEnums.PartSlot.HEAD, "Head part slot should be HEAD")
	assert_eq(chimera.torso.slot, GameEnums.PartSlot.TORSO, "Torso part slot should be TORSO")
	assert_eq(chimera.arms.slot, GameEnums.PartSlot.ARMS, "Arms part slot should be ARMS")
	assert_eq(chimera.legs.slot, GameEnums.PartSlot.LEGS, "Legs part slot should be LEGS")


func test_generate_enemy_chimera_recalculates_stats() -> void:
	var weights: Dictionary = EnemyGenerator.DIFFICULTY_WEIGHTS["normal"]
	var chimera: ChimeraData = EnemyGenerator._generate_enemy_chimera(weights)
	# After recalculate_stats, max_hp should be > 0 (parts contribute hp bonuses)
	assert_gt(chimera.max_hp, 0.0, "max_hp should be positive after recalculate_stats")
	assert_gt(chimera.attack, 0.0, "attack should be positive after recalculate_stats")


# --- generate_enemy_roster ---


func test_generate_enemy_roster_returns_three_chimeras() -> void:
	var roster: Array = PartDatabase.get_starter_chimeras()
	var enemies: Array = EnemyGenerator.generate_enemy_roster(roster, "regular", 0, 0)
	assert_eq(enemies.size(), 3, "Should return exactly 3 enemy chimeras")


func test_generate_enemy_roster_returns_chimera_data_instances() -> void:
	var roster: Array = PartDatabase.get_starter_chimeras()
	var enemies: Array = EnemyGenerator.generate_enemy_roster(roster, "regular", 0, 0)
	for i in range(enemies.size()):
		assert_true(enemies[i] is ChimeraData, "Enemy %d should be a ChimeraData instance" % i)


func test_generate_enemy_roster_each_chimera_has_four_parts() -> void:
	var roster: Array = PartDatabase.get_starter_chimeras()
	var enemies: Array = EnemyGenerator.generate_enemy_roster(roster, "regular", 0, 0)
	for i in range(enemies.size()):
		assert_not_null(enemies[i].head, "Enemy %d should have a head part" % i)
		assert_not_null(enemies[i].torso, "Enemy %d should have a torso part" % i)
		assert_not_null(enemies[i].arms, "Enemy %d should have an arms part" % i)
		assert_not_null(enemies[i].legs, "Enemy %d should have a legs part" % i)


func test_generate_enemy_roster_each_chimera_has_recalculated_stats() -> void:
	var roster: Array = PartDatabase.get_starter_chimeras()
	var enemies: Array = EnemyGenerator.generate_enemy_roster(roster, "regular", 0, 0)
	for i in range(enemies.size()):
		assert_gt(enemies[i].max_hp, 0.0, "Enemy %d should have positive max_hp" % i)


func test_generate_enemy_roster_tournament_tier_4() -> void:
	var roster: Array = PartDatabase.get_starter_chimeras()
	var enemies: Array = EnemyGenerator.generate_enemy_roster(roster, "tournament", 0, 4)
	assert_eq(enemies.size(), 3, "Should return 3 enemies for tournament tier 4")
	for i in range(enemies.size()):
		assert_gt(enemies[i].max_hp, 0.0, "Tournament enemy %d should have positive max_hp" % i)
