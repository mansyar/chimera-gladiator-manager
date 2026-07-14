# gdlint:ignore=max-public-methods
## Tests for GameState autoload - properties, gold, and infamy management.
extends GutTest

# --- Setup ---


func before_each() -> void:
	GameState.gold = 200
	GameState.infamy = 0


# --- Properties ---


func test_all_properties_accessible() -> void:
	# Verify all properties exist by setting and reading them
	GameState.gold = 100
	GameState.infamy = 5
	GameState.roster = []
	GameState.inventory = []
	GameState.market_stock = {}
	GameState.research_progress = {}
	GameState.research_points = 0
	GameState.hall_of_fame = []
	GameState.current_tournament = {}
	GameState.match_history = []
	GameState.losing_streak = 0
	assert_eq(GameState.gold, 100)
	assert_eq(GameState.infamy, 5)
	assert_eq(GameState.research_points, 0)
	assert_eq(GameState.losing_streak, 0)


# --- add_gold ---


func test_add_gold_increases_amount() -> void:
	GameState.add_gold(50)
	assert_eq(GameState.gold, 250)


func test_add_gold_emits_gold_changed() -> void:
	watch_signals(EventBus)
	GameState.add_gold(50)
	assert_signal_emitted(EventBus, "gold_changed")


func test_add_gold_emits_correct_value() -> void:
	watch_signals(EventBus)
	GameState.add_gold(50)
	assert_signal_emitted_with_parameters(EventBus, "gold_changed", [250])


func test_add_gold_zero_emits_signal() -> void:
	watch_signals(EventBus)
	GameState.add_gold(0)
	assert_eq(GameState.gold, 200)
	assert_signal_emitted(EventBus, "gold_changed")


func test_add_gold_negative_clamps_to_zero() -> void:
	GameState.gold = 50
	GameState.add_gold(-100)
	assert_eq(GameState.gold, 0)


func test_add_gold_negative_emits_zero() -> void:
	GameState.gold = 50
	watch_signals(EventBus)
	GameState.add_gold(-100)
	assert_signal_emitted_with_parameters(EventBus, "gold_changed", [0])


# --- spend_gold ---


func test_spend_gold_sufficient_returns_true() -> void:
	var result: bool = GameState.spend_gold(50)
	assert_true(result)
	assert_eq(GameState.gold, 150)


func test_spend_gold_insufficient_returns_false() -> void:
	var result: bool = GameState.spend_gold(300)
	assert_false(result)
	assert_eq(GameState.gold, 200)


func test_spend_gold_exact_amount() -> void:
	var result: bool = GameState.spend_gold(200)
	assert_true(result)
	assert_eq(GameState.gold, 0)


func test_spend_gold_emits_gold_changed() -> void:
	watch_signals(EventBus)
	GameState.spend_gold(50)
	assert_signal_emitted(EventBus, "gold_changed")


func test_spend_gold_emits_correct_value() -> void:
	watch_signals(EventBus)
	GameState.spend_gold(50)
	assert_signal_emitted_with_parameters(EventBus, "gold_changed", [150])


func test_spend_gold_insufficient_no_signal() -> void:
	watch_signals(EventBus)
	GameState.spend_gold(300)
	assert_signal_not_emitted(EventBus, "gold_changed")


# --- add_infamy ---


func test_add_infamy_increases_amount() -> void:
	GameState.add_infamy(5)
	assert_eq(GameState.infamy, 5)


func test_add_infamy_emits_infamy_changed() -> void:
	watch_signals(EventBus)
	GameState.add_infamy(5)
	assert_signal_emitted(EventBus, "infamy_changed")


func test_add_infamy_emits_correct_value() -> void:
	watch_signals(EventBus)
	GameState.add_infamy(5)
	assert_signal_emitted_with_parameters(EventBus, "infamy_changed", [5])
