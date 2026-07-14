# gdlint:ignore=max-public-methods
extends GutTest

## Tests for EventBus autoload (TRACK-004).
##
## Verifies all 13 global signals are declared, can be emitted,
## and can be connected to handlers.

# --- Signal existence tests ---


func test_has_signal_gold_changed() -> void:
	assert_true(EventBus.has_signal("gold_changed"), "Should have gold_changed signal")


func test_has_signal_infamy_changed() -> void:
	assert_true(EventBus.has_signal("infamy_changed"), "Should have infamy_changed signal")


func test_has_signal_part_purchased() -> void:
	assert_true(EventBus.has_signal("part_purchased"), "Should have part_purchased signal")


func test_has_signal_chimera_modified() -> void:
	assert_true(EventBus.has_signal("chimera_modified"), "Should have chimera_modified signal")


func test_has_signal_chimera_decayed() -> void:
	assert_true(EventBus.has_signal("chimera_decayed"), "Should have chimera_decayed signal")


func test_has_signal_match_started() -> void:
	assert_true(EventBus.has_signal("match_started"), "Should have match_started signal")


func test_has_signal_match_ended() -> void:
	assert_true(EventBus.has_signal("match_ended"), "Should have match_ended signal")


func test_has_signal_market_refreshed() -> void:
	assert_true(EventBus.has_signal("market_refreshed"), "Should have market_refreshed signal")


func test_has_signal_research_unlocked() -> void:
	assert_true(EventBus.has_signal("research_unlocked"), "Should have research_unlocked signal")


func test_has_signal_chimera_ascended() -> void:
	assert_true(EventBus.has_signal("chimera_ascended"), "Should have chimera_ascended signal")


func test_has_signal_screen_change_requested() -> void:
	assert_true(
		EventBus.has_signal("screen_change_requested"), "Should have screen_change_requested signal"
	)


func test_has_signal_berserk_triggered() -> void:
	assert_true(EventBus.has_signal("berserk_triggered"), "Should have berserk_triggered signal")


func test_has_signal_combat_log() -> void:
	assert_true(EventBus.has_signal("combat_log"), "Should have combat_log signal")


func test_all_13_expected_signals_exist() -> void:
	var expected: Array[String] = [
		"gold_changed",
		"infamy_changed",
		"part_purchased",
		"chimera_modified",
		"chimera_decayed",
		"match_started",
		"match_ended",
		"market_refreshed",
		"research_unlocked",
		"chimera_ascended",
		"screen_change_requested",
		"berserk_triggered",
		"combat_log",
	]
	for signal_name in expected:
		assert_true(
			EventBus.has_signal(signal_name), "EventBus should have signal: %s" % signal_name
		)
	assert_eq(expected.size(), 13, "Should verify exactly 13 signals")


# --- Signal emission tests ---


func test_gold_changed_emits() -> void:
	watch_signals(EventBus)
	EventBus.gold_changed.emit(100)
	assert_signal_emitted(EventBus, "gold_changed", "gold_changed should emit")


func test_infamy_changed_emits() -> void:
	watch_signals(EventBus)
	EventBus.infamy_changed.emit(5)
	assert_signal_emitted(EventBus, "infamy_changed", "infamy_changed should emit")


func test_part_purchased_emits() -> void:
	var part := PartData.new()
	watch_signals(EventBus)
	EventBus.part_purchased.emit(part)
	assert_signal_emitted(EventBus, "part_purchased", "part_purchased should emit")


func test_chimera_modified_emits() -> void:
	var chimera := ChimeraData.new()
	watch_signals(EventBus)
	EventBus.chimera_modified.emit(chimera)
	assert_signal_emitted(EventBus, "chimera_modified", "chimera_modified should emit")


func test_chimera_decayed_emits() -> void:
	var chimera := ChimeraData.new()
	watch_signals(EventBus)
	EventBus.chimera_decayed.emit(chimera, "attack")
	assert_signal_emitted(EventBus, "chimera_decayed", "chimera_decayed should emit")


func test_match_started_emits() -> void:
	watch_signals(EventBus)
	EventBus.match_started.emit([], [])
	assert_signal_emitted(EventBus, "match_started", "match_started should emit")


func test_match_ended_emits() -> void:
	watch_signals(EventBus)
	EventBus.match_ended.emit({"winner": "player"})
	assert_signal_emitted(EventBus, "match_ended", "match_ended should emit")


func test_market_refreshed_emits() -> void:
	watch_signals(EventBus)
	EventBus.market_refreshed.emit()
	assert_signal_emitted(EventBus, "market_refreshed", "market_refreshed should emit")


func test_research_unlocked_emits() -> void:
	watch_signals(EventBus)
	EventBus.research_unlocked.emit("strain_mastery", "undead", 1)
	assert_signal_emitted(EventBus, "research_unlocked", "research_unlocked should emit")


func test_chimera_ascended_emits() -> void:
	var chimera := ChimeraData.new()
	watch_signals(EventBus)
	EventBus.chimera_ascended.emit(chimera)
	assert_signal_emitted(EventBus, "chimera_ascended", "chimera_ascended should emit")


func test_screen_change_requested_emits() -> void:
	watch_signals(EventBus)
	EventBus.screen_change_requested.emit("lab")
	assert_signal_emitted(
		EventBus, "screen_change_requested", "screen_change_requested should emit"
	)


func test_berserk_triggered_emits() -> void:
	var chimera := ChimeraData.new()
	watch_signals(EventBus)
	EventBus.berserk_triggered.emit(chimera)
	assert_signal_emitted(EventBus, "berserk_triggered", "berserk_triggered should emit")


func test_combat_log_emits() -> void:
	watch_signals(EventBus)
	EventBus.combat_log.emit("Battle started!")
	assert_signal_emitted(EventBus, "combat_log", "combat_log should emit")


# --- Signal connection tests ---


func test_gold_changed_can_be_connected() -> void:
	var received: Array = []
	EventBus.gold_changed.connect(func(amount: int) -> void: received.append(amount))
	EventBus.gold_changed.emit(42)
	assert_eq(received.size(), 1, "Handler should be called once")
	assert_eq(received[0], 42, "Handler should receive the amount")


func test_combat_log_can_be_connected() -> void:
	var received: Array = []
	EventBus.combat_log.connect(func(msg: String) -> void: received.append(msg))
	EventBus.combat_log.emit("Test message")
	assert_eq(received.size(), 1, "Handler should be called once")
	assert_eq(received[0], "Test message", "Handler should receive the message")


func test_market_refreshed_can_be_connected() -> void:
	var calls: Array = []
	EventBus.market_refreshed.connect(func() -> void: calls.append(true))
	EventBus.market_refreshed.emit()
	assert_eq(calls.size(), 1, "Handler should be called once")
