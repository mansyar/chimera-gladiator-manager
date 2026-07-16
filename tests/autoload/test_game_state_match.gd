# gdlint:ignore=max-public-methods
## Tests for GameState.record_match_result() — post-match economy integration.
extends GutTest

# --- Setup ---


func before_each() -> void:
	SaveManager.delete_save()
	GameState.gold = 200
	GameState.infamy = 0
	GameState.match_history = []
	GameState.losing_streak = 0
	GameState.market_stock = Market.generate_initial_stock()


func after_each() -> void:
	SaveManager.delete_save()


# --- losing_streak ---


func test_record_match_result_win_resets_losing_streak() -> void:
	GameState.losing_streak = 3
	GameState.record_match_result(true, "regular", {"gold": 30, "infamy": 2})
	assert_eq(GameState.losing_streak, 0)


func test_record_match_result_loss_increments_losing_streak() -> void:
	GameState.losing_streak = 0
	GameState.record_match_result(false, "regular", {"gold": 10, "infamy": 0})
	assert_eq(GameState.losing_streak, 1)


# --- match_history ---


func test_record_match_result_appends_win_to_history() -> void:
	GameState.record_match_result(true, "regular", {"gold": 30, "infamy": 2})
	assert_eq(GameState.match_history.size(), 1)
	assert_eq(GameState.match_history[0]["result"], "win")
	assert_eq(GameState.match_history[0]["gold"], 30)


func test_record_match_result_appends_loss_to_history() -> void:
	GameState.record_match_result(false, "regular", {"gold": 10, "infamy": 0})
	assert_eq(GameState.match_history.size(), 1)
	assert_eq(GameState.match_history[0]["result"], "loss")
	assert_eq(GameState.match_history[0]["gold"], 10)


# --- rewards ---


func test_record_match_result_adds_gold() -> void:
	GameState.record_match_result(true, "regular", {"gold": 30, "infamy": 2})
	assert_eq(GameState.gold, 230)


func test_record_match_result_adds_infamy() -> void:
	GameState.record_match_result(true, "regular", {"gold": 30, "infamy": 2})
	assert_eq(GameState.infamy, 2)


# --- side effects ---


func test_record_match_result_refreshes_market() -> void:
	watch_signals(EventBus)
	GameState.record_match_result(true, "regular", {"gold": 30, "infamy": 2})
	assert_signal_emitted(EventBus, "market_refreshed")


func test_record_match_result_triggers_save() -> void:
	GameState.record_match_result(true, "regular", {"gold": 30, "infamy": 2})
	assert_true(SaveManager.has_save())
