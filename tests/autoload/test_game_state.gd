# gdlint:ignore=max-public-methods
## Tests for GameState autoload - properties, gold, and infamy management.
extends GutTest

# --- Setup ---


func before_each() -> void:
	SaveManager.delete_save()
	GameState.gold = 200
	GameState.infamy = 0
	GameState.roster = []
	GameState.inventory = []
	GameState.market_stock = {}
	GameState.hall_of_fame = []
	GameState.research_progress = {}
	GameState.research_points = 0


func after_each() -> void:
	SaveManager.delete_save()


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


# --- New Game Initialization ---


func test_init_new_game_sets_gold_to_200() -> void:
	GameState.gold = 0
	GameState._init_new_game()
	assert_eq(GameState.gold, 200)


func test_init_new_game_sets_infamy_to_0() -> void:
	GameState.infamy = 50
	GameState._init_new_game()
	assert_eq(GameState.infamy, 0)


func test_init_new_game_sets_roster_to_3_starters() -> void:
	GameState.roster = []
	GameState._init_new_game()
	assert_eq(GameState.roster.size(), 3)


func test_init_new_game_roster_contains_chimera_data() -> void:
	GameState.roster = []
	GameState._init_new_game()
	for i in range(GameState.roster.size()):
		assert_not_null(GameState.roster[i])


func test_init_new_game_sets_empty_inventory() -> void:
	var part := PartData.new()
	GameState.inventory = [part]
	GameState._init_new_game()
	assert_eq(GameState.inventory.size(), 0)


func test_init_new_game_sets_market_stock() -> void:
	GameState.market_stock = {}
	GameState._init_new_game()
	assert_true(GameState.market_stock.has("base"))
	assert_true(GameState.market_stock.has("rotating"))


func test_init_new_game_market_base_has_24_parts() -> void:
	GameState._init_new_game()
	var base: Array = GameState.market_stock["base"]
	assert_eq(base.size(), 24)


func test_init_new_game_market_rotating_6_to_10() -> void:
	GameState._init_new_game()
	var rotating: Array = GameState.market_stock["rotating"]
	assert_true(rotating.size() >= 6)
	assert_true(rotating.size() <= 10)


func test_init_new_game_sets_empty_research_progress() -> void:
	GameState.research_progress = {"branch": {"node": 1}}
	GameState._init_new_game()
	assert_eq(GameState.research_progress.size(), 0)


func test_init_new_game_sets_research_points_to_0() -> void:
	GameState.research_points = 5
	GameState._init_new_game()
	assert_eq(GameState.research_points, 0)


func test_init_new_game_sets_empty_hall_of_fame() -> void:
	var chimera := ChimeraData.new()
	GameState.hall_of_fame = [chimera]
	GameState._init_new_game()
	assert_eq(GameState.hall_of_fame.size(), 0)


func test_init_new_game_sets_empty_match_history() -> void:
	GameState.match_history = [{"test": true}]
	GameState._init_new_game()
	assert_eq(GameState.match_history.size(), 0)


func test_init_new_game_sets_losing_streak_to_0() -> void:
	GameState.losing_streak = 5
	GameState._init_new_game()
	assert_eq(GameState.losing_streak, 0)


func test_init_new_game_sets_empty_current_tournament() -> void:
	GameState.current_tournament = {"tier": 1}
	GameState._init_new_game()
	assert_eq(GameState.current_tournament.size(), 0)


func test_ready_loads_save_or_inits_new_game() -> void:
	# _ready() loads from save if available, otherwise initializes a new game.
	# When no save exists, gold is set to 200 and roster gets 3 starters.
	GameState.gold = 0
	GameState.roster = []
	GameState._ready()
	if SaveManager.has_save():
		# Save existed — values come from the loaded save file.
		assert_true(GameState.gold >= 0, "Gold should be loaded from save")
	else:
		# No save — new game initialized with defaults.
		assert_eq(GameState.gold, 200, "New game should set gold to 200")
		assert_eq(GameState.roster.size(), 3, "New game should create 3 starter chimeras")


# --- buy_part ---


func test_buy_part_success_returns_true() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 1000
	var result: bool = GameState.buy_part(part)
	assert_true(result)


func test_buy_part_deducts_gold() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 1000
	GameState.buy_part(part)
	# Common price range: 50-100
	assert_true(GameState.gold >= 900)
	assert_true(GameState.gold <= 950)


func test_buy_part_adds_to_inventory() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 1000
	GameState.buy_part(part)
	assert_eq(GameState.inventory.size(), 1)
	assert_eq(GameState.inventory[0], part)


func test_buy_part_emits_part_purchased() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 1000
	watch_signals(EventBus)
	GameState.buy_part(part)
	assert_signal_emitted(EventBus, "part_purchased")


func test_buy_part_emits_correct_part() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 1000
	watch_signals(EventBus)
	GameState.buy_part(part)
	assert_signal_emitted_with_parameters(EventBus, "part_purchased", [part])


func test_buy_part_emits_gold_changed() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 1000
	watch_signals(EventBus)
	GameState.buy_part(part)
	assert_signal_emitted(EventBus, "gold_changed")


func test_buy_part_insufficient_gold_returns_false() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 10
	var result: bool = GameState.buy_part(part)
	assert_false(result)


func test_buy_part_insufficient_gold_no_deduction() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 10
	GameState.buy_part(part)
	assert_eq(GameState.gold, 10)


func test_buy_part_insufficient_gold_no_inventory_add() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 10
	GameState.buy_part(part)
	assert_eq(GameState.inventory.size(), 0)


func test_buy_part_insufficient_gold_no_signal() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.gold = 10
	watch_signals(EventBus)
	GameState.buy_part(part)
	assert_signal_not_emitted(EventBus, "part_purchased")


func test_buy_part_legendary_infamy_gate_returns_false() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.LEGENDARY
	GameState.gold = 5000
	GameState.infamy = 0
	var result: bool = GameState.buy_part(part)
	assert_false(result)


func test_buy_part_legendary_with_sufficient_infamy_succeeds() -> void:
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.LEGENDARY
	GameState.gold = 5000
	GameState.infamy = 50
	var result: bool = GameState.buy_part(part)
	assert_true(result)


# --- refresh_market ---


func test_refresh_market_generates_new_rotating_stock() -> void:
	GameState.market_stock = Market.generate_initial_stock()
	GameState.refresh_market()
	var new_rotating: Array = GameState.market_stock["rotating"]
	assert_true(new_rotating.size() >= 6)
	assert_true(new_rotating.size() <= 10)


func test_refresh_market_preserves_base_stock() -> void:
	GameState.market_stock = Market.generate_initial_stock()
	var old_base: Array = GameState.market_stock["base"]
	GameState.refresh_market()
	var new_base: Array = GameState.market_stock["base"]
	assert_eq(new_base.size(), old_base.size())


func test_refresh_market_emits_market_refreshed() -> void:
	GameState.market_stock = Market.generate_initial_stock()
	watch_signals(EventBus)
	GameState.refresh_market()
	assert_signal_emitted(EventBus, "market_refreshed")


# --- can_ascend ---


func test_can_ascend_true_at_10_wins() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	var result: bool = GameState.can_ascend(chimera)
	assert_true(result)


func test_can_ascend_false_below_10_wins() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 9
	var result: bool = GameState.can_ascend(chimera)
	assert_false(result)


func test_can_ascend_false_at_0_wins() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 0
	var result: bool = GameState.can_ascend(chimera)
	assert_false(result)


func test_can_ascend_true_above_10_wins() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 15
	var result: bool = GameState.can_ascend(chimera)
	assert_true(result)


# --- ascend_chimera ---


func test_ascend_chimera_returns_rp_gained() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	GameState.roster = [chimera]
	var rp: int = GameState.ascend_chimera(chimera)
	assert_eq(rp, 1)


func test_ascend_chimera_moves_to_hall_of_fame() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	GameState.roster = [chimera]
	GameState.ascend_chimera(chimera)
	assert_eq(GameState.hall_of_fame.size(), 1)
	assert_eq(GameState.hall_of_fame[0], chimera)


func test_ascend_chimera_grants_1_rp() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	GameState.roster = [chimera]
	GameState.research_points = 0
	GameState.ascend_chimera(chimera)
	assert_eq(GameState.research_points, 1)


func test_ascend_chimera_replaces_roster_slot() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	chimera.nickname = "AscendedOne"
	GameState.roster = [chimera]
	GameState.ascend_chimera(chimera)
	assert_eq(GameState.roster.size(), 1)
	assert_ne(GameState.roster[0], chimera)
	assert_not_null(GameState.roster[0])


func test_ascend_chimera_replacement_is_chimera_data() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	GameState.roster = [chimera]
	GameState.ascend_chimera(chimera)
	assert_true(GameState.roster[0] is ChimeraData)


func test_ascend_chimera_emits_chimera_ascended() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	GameState.roster = [chimera]
	watch_signals(EventBus)
	GameState.ascend_chimera(chimera)
	assert_signal_emitted(EventBus, "chimera_ascended")


func test_ascend_chimera_emits_correct_chimera() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	GameState.roster = [chimera]
	watch_signals(EventBus)
	GameState.ascend_chimera(chimera)
	assert_signal_emitted_with_parameters(EventBus, "chimera_ascended", [chimera])


func test_ascend_chimera_not_in_roster_returns_0() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	GameState.roster = []
	var rp: int = GameState.ascend_chimera(chimera)
	assert_eq(rp, 0)


func test_ascend_chimera_not_in_roster_no_hall_of_fame_add() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	GameState.roster = []
	GameState.ascend_chimera(chimera)
	assert_eq(GameState.hall_of_fame.size(), 0)


func test_ascend_chimera_preserves_other_slots() -> void:
	var chimera := ChimeraData.new()
	chimera.match_wins = 10
	var other := ChimeraData.new()
	other.nickname = "OtherChimera"
	GameState.roster = [chimera, other]
	GameState.ascend_chimera(chimera)
	assert_eq(GameState.roster[1], other)


# --- get_research_level ---


func test_get_research_level_returns_0_for_unlocked() -> void:
	var level: int = GameState.get_research_level(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_eq(level, 0)


func test_get_research_level_returns_correct_level() -> void:
	GameState.research_progress = {Research.BRANCH_STRAIN_MASTERY: {"beast": 2}}
	var level: int = GameState.get_research_level(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_eq(level, 2)


func test_get_research_level_returns_0_for_unknown_branch() -> void:
	GameState.research_progress = {Research.BRANCH_STRAIN_MASTERY: {"beast": 1}}
	var level: int = GameState.get_research_level("unknown_branch", "beast")
	assert_eq(level, 0)


func test_get_research_level_returns_0_for_unknown_node() -> void:
	GameState.research_progress = {Research.BRANCH_STRAIN_MASTERY: {"beast": 1}}
	var level: int = GameState.get_research_level(Research.BRANCH_STRAIN_MASTERY, "unknown_node")
	assert_eq(level, 0)


func test_get_research_level_returns_correct_after_unlock() -> void:
	GameState.research_points = 1
	GameState.spend_research_point(Research.BRANCH_LAB_ENGINEERING, "market_connections")
	var level: int = GameState.get_research_level(
		Research.BRANCH_LAB_ENGINEERING, "market_connections"
	)
	assert_eq(level, 1)


# --- spend_research_point ---


func test_spend_research_point_success_returns_true() -> void:
	GameState.research_points = 1
	var result: bool = GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_true(result)


func test_spend_research_point_deducts_rp() -> void:
	GameState.research_points = 3
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_eq(GameState.research_points, 2)


func test_spend_research_point_increments_level() -> void:
	GameState.research_points = 1
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	var level: int = GameState.get_research_level(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_eq(level, 1)


func test_spend_research_point_emits_research_unlocked() -> void:
	GameState.research_points = 1
	watch_signals(EventBus)
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_signal_emitted(EventBus, "research_unlocked")


func test_spend_research_point_emits_correct_params() -> void:
	GameState.research_points = 1
	watch_signals(EventBus)
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_signal_emitted_with_parameters(
		EventBus, "research_unlocked", [Research.BRANCH_STRAIN_MASTERY, "beast", 1]
	)


func test_spend_research_point_no_points_returns_false() -> void:
	GameState.research_points = 0
	var result: bool = GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_false(result)


func test_spend_research_point_at_max_level_returns_false() -> void:
	# Combat Doctrine max level is 1
	GameState.research_progress = {Research.BRANCH_COMBAT_DOCTRINE: {"tactical_ai": 1}}
	GameState.research_points = 5
	var result: bool = GameState.spend_research_point(
		Research.BRANCH_COMBAT_DOCTRINE, "tactical_ai"
	)
	assert_false(result)


func test_spend_research_point_unknown_branch_returns_false() -> void:
	GameState.research_points = 5
	var result: bool = GameState.spend_research_point("unknown_branch", "beast")
	assert_false(result)


func test_spend_research_point_no_points_no_deduction() -> void:
	GameState.research_points = 0
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_eq(GameState.research_points, 0)


func test_spend_research_point_failure_no_signal() -> void:
	GameState.research_points = 0
	watch_signals(EventBus)
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_signal_not_emitted(EventBus, "research_unlocked")


func test_spend_research_point_multiple_unlocks() -> void:
	GameState.research_points = 3
	# First unlock: level 0 -> 1
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_eq(GameState.get_research_level(Research.BRANCH_STRAIN_MASTERY, "beast"), 1)
	assert_eq(GameState.research_points, 2)
	# Second unlock: level 1 -> 2
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_eq(GameState.get_research_level(Research.BRANCH_STRAIN_MASTERY, "beast"), 2)
	assert_eq(GameState.research_points, 1)
	# Third unlock: level 2 -> 3 (max for Strain Mastery)
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_eq(GameState.get_research_level(Research.BRANCH_STRAIN_MASTERY, "beast"), 3)
	assert_eq(GameState.research_points, 0)
	# Fourth attempt: at max level, should fail
	var result: bool = GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "beast")
	assert_false(result)


# --- Save Triggers ---


func test_buy_part_triggers_save_on_success() -> void:
	GameState.gold = 1000
	var part := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	GameState.buy_part(part)
	assert_true(SaveManager.has_save())


func test_buy_part_no_save_on_failure() -> void:
	GameState.gold = 10
	var part := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	GameState.buy_part(part)
	assert_false(SaveManager.has_save())


func test_replace_chimera_triggers_save() -> void:
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	var new_chimera: ChimeraData = starters[0].duplicate()
	GameState.replace_chimera(0, new_chimera)
	assert_true(SaveManager.has_save())


func test_replace_chimera_oob_no_save() -> void:
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	GameState.replace_chimera(99, starters[0].duplicate())
	assert_false(SaveManager.has_save())


func test_refresh_market_triggers_save() -> void:
	GameState.market_stock = Market.generate_initial_stock()
	GameState.refresh_market()
	assert_true(SaveManager.has_save())


func test_ascend_chimera_triggers_save() -> void:
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	starters[0].match_wins = 10
	GameState.ascend_chimera(starters[0])
	assert_true(SaveManager.has_save())


func test_ascend_chimera_not_in_roster_no_save() -> void:
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	var orphan: ChimeraData = starters[0].duplicate()
	orphan.match_wins = 10
	GameState.ascend_chimera(orphan)
	assert_false(SaveManager.has_save())


func test_spend_research_point_triggers_save() -> void:
	GameState.research_points = 1
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "undead")
	assert_true(SaveManager.has_save())


func test_spend_research_point_failure_no_save() -> void:
	GameState.research_points = 0
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "undead")
	assert_false(SaveManager.has_save())


# --- Signal Integration ---


func test_integration_all_signals_fire_in_game_flow() -> void:
	# Set up state for a full game flow
	GameState.gold = 1000
	GameState.infamy = 50
	GameState.research_points = 3
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	GameState.market_stock = Market.generate_initial_stock()
	# Watch all signals on EventBus
	watch_signals(EventBus)
	# Exercise each signal-emitting method
	GameState.add_gold(100)  # gold_changed
	GameState.add_infamy(5)  # infamy_changed
	var part := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	GameState.buy_part(part)  # part_purchased + gold_changed
	var new_chimera: ChimeraData = starters[0].duplicate()
	GameState.replace_chimera(0, new_chimera)  # chimera_modified
	GameState.refresh_market()  # market_refreshed
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "undead")  # research_unlocked
	starters[1].match_wins = 10
	GameState.ascend_chimera(starters[1])  # chimera_ascended
	# Verify all 7 signals were emitted
	assert_signal_emitted(EventBus, "gold_changed")
	assert_signal_emitted(EventBus, "infamy_changed")
	assert_signal_emitted(EventBus, "part_purchased")
	assert_signal_emitted(EventBus, "chimera_modified")
	assert_signal_emitted(EventBus, "market_refreshed")
	assert_signal_emitted(EventBus, "research_unlocked")
	assert_signal_emitted(EventBus, "chimera_ascended")


func test_integration_no_signals_on_failed_operations() -> void:
	# Set up state where operations will fail
	GameState.gold = 10  # insufficient gold
	GameState.research_points = 0  # no research points
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	# Watch all signals
	watch_signals(EventBus)
	# Failed buy_part (insufficient gold)
	var part := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	GameState.buy_part(part)
	# Failed replace_chimera (out of bounds)
	GameState.replace_chimera(99, starters[0].duplicate())
	# Failed spend_research_point (no points)
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "undead")
	# Failed ascend_chimera (not in roster)
	var orphan: ChimeraData = starters[0].duplicate()
	orphan.match_wins = 10
	GameState.ascend_chimera(orphan)
	# Verify no specific signals emitted
	assert_signal_not_emitted(EventBus, "part_purchased")
	assert_signal_not_emitted(EventBus, "chimera_modified")
	assert_signal_not_emitted(EventBus, "research_unlocked")
	assert_signal_not_emitted(EventBus, "chimera_ascended")


func test_integration_signal_parameter_types() -> void:
	GameState.gold = 1000
	GameState.infamy = 50
	GameState.research_points = 1
	var starters := PartDatabase.get_starter_chimeras().duplicate()
	GameState.roster = starters
	GameState.market_stock = Market.generate_initial_stock()
	watch_signals(EventBus)
	# gold_changed emits int
	GameState.add_gold(100)
	var params: Array = get_signal_parameters(EventBus, "gold_changed")
	assert_eq(typeof(params[0]), TYPE_INT)
	# infamy_changed emits int
	GameState.add_infamy(5)
	params = get_signal_parameters(EventBus, "infamy_changed")
	assert_eq(typeof(params[0]), TYPE_INT)
	# part_purchased emits PartData
	var part := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	GameState.buy_part(part)
	params = get_signal_parameters(EventBus, "part_purchased")
	assert_true(params[0] is PartData)
	# chimera_modified emits ChimeraData
	var new_chimera: ChimeraData = starters[0].duplicate()
	GameState.replace_chimera(0, new_chimera)
	params = get_signal_parameters(EventBus, "chimera_modified")
	assert_true(params[0] is ChimeraData)
	# research_unlocked emits String, String, int
	GameState.spend_research_point(Research.BRANCH_STRAIN_MASTERY, "undead")
	params = get_signal_parameters(EventBus, "research_unlocked")
	assert_eq(typeof(params[0]), TYPE_STRING)
	assert_eq(typeof(params[1]), TYPE_STRING)
	assert_eq(typeof(params[2]), TYPE_INT)
	# chimera_ascended emits ChimeraData
	starters[1].match_wins = 10
	GameState.ascend_chimera(starters[1])
	params = get_signal_parameters(EventBus, "chimera_ascended")
	assert_true(params[0] is ChimeraData)
