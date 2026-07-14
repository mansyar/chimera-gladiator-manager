# gdlint:ignore=max-public-methods
## Tests for GameState autoload - properties, gold, and infamy management.
extends GutTest

# --- Setup ---


func before_each() -> void:
	GameState.gold = 200
	GameState.infamy = 0
	GameState.roster = []
	GameState.inventory = []


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


# --- get_chimera ---


func test_get_chimera_returns_correct_chimera_at_index_0() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	GameState.roster = starters
	var chimera: ChimeraData = GameState.get_chimera(0)
	assert_not_null(chimera)
	assert_eq(chimera, starters[0])


func test_get_chimera_returns_correct_chimera_at_index_1() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	GameState.roster = starters
	var chimera: ChimeraData = GameState.get_chimera(1)
	assert_eq(chimera, starters[1])


func test_get_chimera_returns_correct_chimera_at_index_2() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	GameState.roster = starters
	var chimera: ChimeraData = GameState.get_chimera(2)
	assert_eq(chimera, starters[2])


func test_get_chimera_out_of_bounds_returns_null() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	GameState.roster = starters
	var chimera: ChimeraData = GameState.get_chimera(5)
	assert_null(chimera)


func test_get_chimera_negative_index_returns_null() -> void:
	var starters := PartDatabase.get_starter_chimeras()
	GameState.roster = starters
	var chimera: ChimeraData = GameState.get_chimera(-1)
	assert_null(chimera)


func test_get_chimera_empty_roster_returns_null() -> void:
	var chimera: ChimeraData = GameState.get_chimera(0)
	assert_null(chimera)


# --- replace_chimera ---


func test_replace_chimera_updates_roster() -> void:
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	var new_chimera := ChimeraData.new()
	new_chimera.nickname = "TestChimera"
	GameState.replace_chimera(0, new_chimera)
	assert_eq(GameState.roster[0], new_chimera)


func test_replace_chimera_emits_chimera_modified() -> void:
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	var new_chimera := ChimeraData.new()
	new_chimera.nickname = "TestChimera"
	watch_signals(EventBus)
	GameState.replace_chimera(0, new_chimera)
	assert_signal_emitted(EventBus, "chimera_modified")


func test_replace_chimera_emits_correct_chimera() -> void:
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	var new_chimera := ChimeraData.new()
	new_chimera.nickname = "TestChimera"
	watch_signals(EventBus)
	GameState.replace_chimera(0, new_chimera)
	assert_signal_emitted_with_parameters(EventBus, "chimera_modified", [new_chimera])


func test_replace_chimera_other_slots_unchanged() -> void:
	var originals := PartDatabase.get_starter_chimeras()
	var starters := originals.duplicate()
	GameState.roster = starters
	var new_chimera := ChimeraData.new()
	new_chimera.nickname = "TestChimera"
	GameState.replace_chimera(1, new_chimera)
	assert_eq(GameState.roster[0], originals[0])
	assert_eq(GameState.roster[1], new_chimera)
	assert_eq(GameState.roster[2], originals[2])


func test_replace_chimera_out_of_bounds_no_change() -> void:
	var originals := PartDatabase.get_starter_chimeras()
	var starters := originals.duplicate()
	GameState.roster = starters
	var new_chimera := ChimeraData.new()
	GameState.replace_chimera(5, new_chimera)
	assert_eq(GameState.roster.size(), 3)
	assert_eq(GameState.roster[0], originals[0])


# --- add_part ---


func test_add_part_adds_to_inventory() -> void:
	var part := PartData.new()
	GameState.add_part(part)
	assert_eq(GameState.inventory.size(), 1)
	assert_eq(GameState.inventory[0], part)


func test_add_part_multiple_parts() -> void:
	var part1 := PartData.new()
	var part2 := PartData.new()
	GameState.add_part(part1)
	GameState.add_part(part2)
	assert_eq(GameState.inventory.size(), 2)
	assert_eq(GameState.inventory[0], part1)
	assert_eq(GameState.inventory[1], part2)


# --- remove_part ---


func test_remove_part_removes_from_inventory() -> void:
	var part := PartData.new()
	GameState.inventory = [part]
	GameState.remove_part(part)
	assert_eq(GameState.inventory.size(), 0)


func test_remove_part_removes_correct_part() -> void:
	var part1 := PartData.new()
	var part2 := PartData.new()
	GameState.inventory = [part1, part2]
	GameState.remove_part(part1)
	assert_eq(GameState.inventory.size(), 1)
	assert_eq(GameState.inventory[0], part2)


func test_remove_part_not_in_inventory_no_change() -> void:
	var part1 := PartData.new()
	var part2 := PartData.new()
	GameState.inventory = [part1]
	GameState.remove_part(part2)
	assert_eq(GameState.inventory.size(), 1)
	assert_eq(GameState.inventory[0], part1)


func test_remove_part_empty_inventory_no_crash() -> void:
	var part := PartData.new()
	GameState.remove_part(part)
	assert_eq(GameState.inventory.size(), 0)
