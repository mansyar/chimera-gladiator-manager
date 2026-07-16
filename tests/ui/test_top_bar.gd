## Tests for TopBar widget — displays Gold/Infamy, updates on EventBus signals.
extends GutTest
# gdlint:ignore=max-public-methods

# --- Setup ---


func before_each() -> void:
	GameState.gold = 200
	GameState.infamy = 0


# --- Node creation tests ---


func test_top_bar_creates_gold_label() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	assert_not_null(top_bar.get_gold_label(), "Gold label should exist after _ready")


func test_top_bar_creates_infamy_label() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	assert_not_null(top_bar.get_infamy_label(), "Infamy label should exist after _ready")


# --- Initial values from GameState ---


func test_initial_gold_from_game_state() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	assert_eq(top_bar.get_gold_text(), "Gold: 200", "Should read initial gold from GameState")


func test_initial_infamy_from_game_state() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	assert_eq(top_bar.get_infamy_text(), "Infamy: 0", "Should read initial infamy from GameState")


func test_initial_gold_from_modified_game_state() -> void:
	GameState.gold = 500
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	assert_eq(top_bar.get_gold_text(), "Gold: 500", "Should read modified gold from GameState")


func test_initial_infamy_from_modified_game_state() -> void:
	GameState.infamy = 10
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	assert_eq(top_bar.get_infamy_text(), "Infamy: 10", "Should read modified infamy from GameState")


# --- Signal update tests ---


func test_gold_label_updates_on_signal() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	EventBus.gold_changed.emit(250)
	assert_eq(
		top_bar.get_gold_text(), "Gold: 250", "Gold label should update on gold_changed signal"
	)


func test_infamy_label_updates_on_signal() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	EventBus.infamy_changed.emit(5)
	assert_eq(
		top_bar.get_infamy_text(),
		"Infamy: 5",
		"Infamy label should update on infamy_changed signal"
	)


func test_gold_label_updates_multiple_times() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	EventBus.gold_changed.emit(300)
	assert_eq(top_bar.get_gold_text(), "Gold: 300")
	EventBus.gold_changed.emit(150)
	assert_eq(top_bar.get_gold_text(), "Gold: 150", "Gold label should update on each signal")


func test_infamy_label_updates_multiple_times() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	EventBus.infamy_changed.emit(3)
	assert_eq(top_bar.get_infamy_text(), "Infamy: 3")
	EventBus.infamy_changed.emit(7)
	assert_eq(top_bar.get_infamy_text(), "Infamy: 7", "Infamy label should update on each signal")


# --- Independence tests ---


func test_gold_update_does_not_affect_infamy() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	EventBus.gold_changed.emit(500)
	assert_eq(top_bar.get_infamy_text(), "Infamy: 0", "Infamy should not change when gold updates")


func test_infamy_update_does_not_affect_gold() -> void:
	var top_bar: TopBar = add_child_autofree(TopBar.new())
	EventBus.infamy_changed.emit(15)
	assert_eq(top_bar.get_gold_text(), "Gold: 200", "Gold should not change when infamy updates")
