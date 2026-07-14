# gdlint:ignore=max-public-methods
extends GutTest

## Tests for economy.gd static utility (TRACK-004).
##
## Verifies match reward calculation, tournament fees,
## multipliers, and infamy thresholds.

# --- calculate_match_reward: Regular matches ---


func test_regular_win_reward() -> void:
	var result := Economy.calculate_match_reward("regular", true, 0, 0)
	assert_eq(result["gold"], 30, "Regular win should give 30 gold")
	assert_eq(result["infamy"], 2, "Regular win should give 2 infamy")


func test_regular_loss_reward() -> void:
	var result := Economy.calculate_match_reward("regular", false, 0, 0)
	assert_eq(result["gold"], 10, "Regular loss should give 10 gold")
	assert_eq(result["infamy"], 0, "Regular loss should give 0 infamy")


func test_regular_loss_with_losing_streak() -> void:
	var result := Economy.calculate_match_reward("regular", false, 0, 5)
	assert_eq(result["gold"], 10, "Regular loss gold unaffected by losing streak")
	assert_eq(result["infamy"], 0, "Regular loss infamy unaffected by losing streak")


# --- calculate_match_reward: Tournament matches ---


func test_tournament_win_tier1() -> void:
	var result := Economy.calculate_match_reward("tournament", true, 1, 0)
	assert_eq(result["gold"], 50, "Tournament tier 1 win should give 50 gold (50*1)")
	assert_eq(result["infamy"], 10, "Tournament tier 1 win should give 10 infamy (10*1)")


func test_tournament_win_tier2() -> void:
	var result := Economy.calculate_match_reward("tournament", true, 2, 0)
	assert_eq(result["gold"], 100, "Tournament tier 2 win should give 100 gold (50*2)")
	assert_eq(result["infamy"], 20, "Tournament tier 2 win should give 20 infamy (10*2)")


func test_tournament_win_tier3() -> void:
	var result := Economy.calculate_match_reward("tournament", true, 3, 0)
	assert_eq(result["gold"], 200, "Tournament tier 3 win should give 200 gold (50*4)")
	assert_eq(result["infamy"], 40, "Tournament tier 3 win should give 40 infamy (10*4)")


func test_tournament_win_tier4() -> void:
	var result := Economy.calculate_match_reward("tournament", true, 4, 0)
	assert_eq(result["gold"], 400, "Tournament tier 4 win should give 400 gold (50*8)")
	assert_eq(result["infamy"], 80, "Tournament tier 4 win should give 80 infamy (10*8)")


func test_tournament_loss_reward() -> void:
	var result := Economy.calculate_match_reward("tournament", false, 2, 0)
	assert_eq(result["gold"], 0, "Tournament loss should give 0 gold")
	assert_eq(result["infamy"], 0, "Tournament loss should give 0 infamy")


# --- calculate_tournament_entry_fee ---


func test_entry_fee_tier1() -> void:
	assert_eq(Economy.calculate_tournament_entry_fee(1), 0, "Tier 1 entry fee should be 0")


func test_entry_fee_tier2() -> void:
	assert_eq(Economy.calculate_tournament_entry_fee(2), 100, "Tier 2 entry fee should be 100")


func test_entry_fee_tier3() -> void:
	assert_eq(Economy.calculate_tournament_entry_fee(3), 300, "Tier 3 entry fee should be 300")


func test_entry_fee_tier4() -> void:
	assert_eq(Economy.calculate_tournament_entry_fee(4), 1000, "Tier 4 entry fee should be 1000")


# --- get_tournament_multiplier ---


func test_multiplier_tier1() -> void:
	assert_eq(Economy.get_tournament_multiplier(1), 1, "Tier 1 multiplier should be 1")


func test_multiplier_tier2() -> void:
	assert_eq(Economy.get_tournament_multiplier(2), 2, "Tier 2 multiplier should be 2")


func test_multiplier_tier3() -> void:
	assert_eq(Economy.get_tournament_multiplier(3), 4, "Tier 3 multiplier should be 4")


func test_multiplier_tier4() -> void:
	assert_eq(Economy.get_tournament_multiplier(4), 8, "Tier 4 multiplier should be 8")


# --- get_tournament_infamy_threshold ---


func test_infamy_threshold_tier1() -> void:
	assert_eq(Economy.get_tournament_infamy_threshold(1), 0, "Tier 1 infamy threshold should be 0")


func test_infamy_threshold_tier2() -> void:
	assert_eq(
		Economy.get_tournament_infamy_threshold(2), 50, "Tier 2 infamy threshold should be 50"
	)


func test_infamy_threshold_tier3() -> void:
	assert_eq(
		Economy.get_tournament_infamy_threshold(3), 150, "Tier 3 infamy threshold should be 150"
	)


func test_infamy_threshold_tier4() -> void:
	assert_eq(
		Economy.get_tournament_infamy_threshold(4), 400, "Tier 4 infamy threshold should be 400"
	)
