## Tests for UISounds UI sound system.
extends GutTest
# gdlint:ignore=max-public-methods


func test_player_is_child() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	assert_not_null(ui_sounds.get_player())
	assert_eq(ui_sounds.get_player().get_parent(), ui_sounds)


func test_sounds_has_three_categories() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	var sounds: Dictionary = ui_sounds.get_sounds()
	assert_eq(sounds.size(), 3)
	assert_true(sounds.has("click"))
	assert_true(sounds.has("switch"))
	assert_true(sounds.has("tap"))


func test_click_has_two_streams() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	var streams: Array = ui_sounds.get_sounds()["click"]
	assert_eq(streams.size(), 2)


func test_switch_has_two_streams() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	var streams: Array = ui_sounds.get_sounds()["switch"]
	assert_eq(streams.size(), 2)


func test_tap_has_two_streams() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	var streams: Array = ui_sounds.get_sounds()["tap"]
	assert_eq(streams.size(), 2)


func test_all_streams_are_audio_streams() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	var sounds: Dictionary = ui_sounds.get_sounds()
	for category in ["click", "switch", "tap"]:
		var streams: Array = sounds[category]
		assert_true(streams[0] is AudioStream)
		assert_true(streams[1] is AudioStream)


func test_play_click_sets_stream() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	ui_sounds.play_sound("click")
	assert_not_null(ui_sounds.get_player().stream)


func test_play_switch_sets_stream() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	ui_sounds.play_sound("switch")
	assert_not_null(ui_sounds.get_player().stream)


func test_play_tap_sets_stream() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	ui_sounds.play_sound("tap")
	assert_not_null(ui_sounds.get_player().stream)


func test_play_invalid_does_nothing() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	ui_sounds.play_sound("invalid")
	assert_null(ui_sounds.get_player().stream)


func test_play_invalid_after_valid_keeps_stream() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	ui_sounds.play_sound("click")
	var original: AudioStream = ui_sounds.get_player().stream
	ui_sounds.play_sound("invalid")
	assert_eq(ui_sounds.get_player().stream, original)


func test_screen_change_plays_switch() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	EventBus.screen_change_requested.emit("lab_hub")
	assert_not_null(ui_sounds.get_player().stream)
	var stream: AudioStream = ui_sounds.get_player().stream
	var switch_streams: Array = ui_sounds.get_sounds()["switch"]
	assert_true(switch_streams.has(stream))


func test_play_click_sets_valid_stream() -> void:
	var ui_sounds: UISounds = add_child_autofree(UISounds.new())
	ui_sounds.play_sound("click")
	var stream: AudioStream = ui_sounds.get_player().stream
	var click_streams: Array = ui_sounds.get_sounds()["click"]
	assert_true(click_streams.has(stream))
