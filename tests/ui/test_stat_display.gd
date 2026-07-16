## Tests for StatDisplay widget — renders "StatName: Value" label.
extends GutTest
# gdlint:ignore=max-public-methods

# --- Node creation tests ---


func test_stat_display_creates_label() -> void:
	var widget: StatDisplay = add_child_autofree(StatDisplay.new())
	assert_not_null(widget.get_display_label(), "Label should exist after _ready")


# --- Display text tests ---


func test_displays_hp_stat() -> void:
	var widget: StatDisplay = add_child_autofree(StatDisplay.new())
	widget.stat_name = "HP"
	widget.stat_value = 100.0
	assert_eq(widget.get_display_text(), "HP: 100", "Should render 'HP: 100'")


func test_displays_attack_stat() -> void:
	var widget: StatDisplay = add_child_autofree(StatDisplay.new())
	widget.stat_name = "Attack"
	widget.stat_value = 25.5
	assert_eq(widget.get_display_text(), "Attack: 25.5", "Should render 'Attack: 25.5'")


func test_displays_zero_value() -> void:
	var widget: StatDisplay = add_child_autofree(StatDisplay.new())
	widget.stat_name = "Defense"
	widget.stat_value = 0.0
	assert_eq(widget.get_display_text(), "Defense: 0", "Should render 'Defense: 0'")


func test_displays_negative_value() -> void:
	var widget: StatDisplay = add_child_autofree(StatDisplay.new())
	widget.stat_name = "Speed"
	widget.stat_value = -5.0
	assert_eq(widget.get_display_text(), "Speed: -5", "Should render 'Speed: -5'")


# --- Update tests ---


func test_updates_when_stat_name_changes() -> void:
	var widget: StatDisplay = add_child_autofree(StatDisplay.new())
	widget.stat_name = "HP"
	widget.stat_value = 50.0
	assert_eq(widget.get_display_text(), "HP: 50")
	widget.stat_name = "Max HP"
	assert_eq(widget.get_display_text(), "Max HP: 50", "Should update when stat_name changes")


func test_updates_when_stat_value_changes() -> void:
	var widget: StatDisplay = add_child_autofree(StatDisplay.new())
	widget.stat_name = "Attack"
	widget.stat_value = 10.0
	assert_eq(widget.get_display_text(), "Attack: 10")
	widget.stat_value = 99.0
	assert_eq(widget.get_display_text(), "Attack: 99", "Should update when stat_value changes")


# --- Edge cases ---


func test_empty_stat_name() -> void:
	var widget: StatDisplay = add_child_autofree(StatDisplay.new())
	widget.stat_name = ""
	widget.stat_value = 42.0
	assert_eq(widget.get_display_text(), ": 42", "Should render ': 42' for empty name")
