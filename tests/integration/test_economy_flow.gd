## Integration tests for the economy flow:
## buy_part -> gold deduction -> inventory add -> save -> load -> verify state.
##
## Tests cross-system interaction between GameState, Market, SaveManager,
## and EventBus to verify the full purchase lifecycle persists correctly.
extends GutTest


func before_each() -> void:
	SaveManager.delete_save()
	_reset_game_state()


func after_each() -> void:
	SaveManager.delete_save()
	_reset_game_state()


func _reset_game_state() -> void:
	GameState.gold = 200
	GameState.infamy = 0
	GameState.roster = []
	GameState.inventory = []
	GameState.market_stock = {}
	GameState.research_progress = {}
	GameState.research_points = 0
	GameState.hall_of_fame = []
	GameState.match_history = []
	GameState.losing_streak = 0
	GameState.current_tournament = {}


# --- Full buy -> save -> load cycle ---


func test_buy_part_then_save_load_preserves_gold_and_inventory() -> void:
	# Setup: known gold, empty inventory
	GameState.gold = 1000
	GameState.infamy = 10
	GameState.inventory = []
	# Use a real part from PartDatabase so it can be serialized/deserialized
	var part := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	# Act: buy part (triggers save internally)
	var result: bool = GameState.buy_part(part)
	assert_true(result, "buy_part should succeed with sufficient gold")
	var gold_after_purchase := GameState.gold
	var inv_size_after_purchase := GameState.inventory.size()
	# Simulate restart: clear all state
	GameState.gold = 0
	GameState.infamy = 0
	GameState.inventory = []
	# Load saved state
	var loaded: bool = SaveManager.load_game()
	assert_true(loaded, "load_game should succeed after save")
	# Verify state restored
	assert_eq(GameState.gold, gold_after_purchase, "gold should match post-purchase value")
	assert_eq(GameState.inventory.size(), inv_size_after_purchase, "inventory size should match")


func test_buy_multiple_parts_then_save_load_preserves_all() -> void:
	GameState.gold = 5000
	GameState.infamy = 50
	# Buy 3 parts from PartDatabase so they serialize/deserialize correctly
	var part1 := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	var part2 := PartDatabase.generate_random_part(
		GameEnums.PartSlot.TORSO, {GameEnums.Rarity.UNCOMMON: 100}
	)
	var part3 := PartDatabase.generate_random_part(
		GameEnums.PartSlot.ARMS, {GameEnums.Rarity.RARE: 100}
	)
	GameState.buy_part(part1)
	GameState.buy_part(part2)
	GameState.buy_part(part3)
	var gold_after := GameState.gold
	var inv_after := GameState.inventory.size()
	assert_eq(inv_after, 3, "should have 3 parts in inventory")
	# Clear and reload
	GameState.gold = 0
	GameState.inventory = []
	SaveManager.load_game()
	assert_eq(GameState.gold, gold_after, "gold should be preserved after round-trip")
	assert_eq(GameState.inventory.size(), inv_after, "inventory count should be preserved")


# --- Economy rewards -> gold -> purchase flow ---


func test_match_rewards_flow_into_purchase() -> void:
	# Start with minimal gold (not enough for any part)
	GameState.gold = 0
	GameState.infamy = 0
	# Simulate earning match rewards — tournament tier 2 win gives 100 gold
	var reward := Economy.calculate_match_reward("tournament", true, 2, 0)
	GameState.add_gold(reward["gold"])
	# Now buy a part with accumulated gold (100 covers max common price)
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	var result: bool = GameState.buy_part(part)
	assert_true(result, "purchase should succeed with reward gold")
	assert_eq(GameState.inventory.size(), 1, "part should be in inventory")


# --- Market integration ---


func test_buy_from_market_stock_then_save_load() -> void:
	# Generate market stock
	GameState.market_stock = Market.generate_initial_stock()
	GameState.gold = 5000
	GameState.infamy = 50
	# Buy first part from base stock
	var base_stock: Array = GameState.market_stock["base"]
	assert_true(base_stock.size() > 0, "market should have base stock")
	var market_part: PartData = base_stock[0]
	var result: bool = GameState.buy_part(market_part)
	assert_true(result, "should be able to buy from market stock")
	# Save and reload
	var gold_after := GameState.gold
	GameState.gold = 0
	GameState.inventory = []
	SaveManager.load_game()
	assert_eq(GameState.gold, gold_after, "gold should be preserved")
	assert_eq(GameState.inventory.size(), 1, "purchased part should be in inventory after load")


# --- Failed purchase does not persist ---


func test_failed_purchase_does_not_save() -> void:
	GameState.gold = 10  # Not enough for any part
	GameState.infamy = 0
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	var result: bool = GameState.buy_part(part)
	assert_false(result, "purchase should fail with insufficient gold")
	# Verify no save was created (buy_part only saves on success)
	# The save should not exist since before_each deleted it and buy_part failed
	assert_false(SaveManager.has_save(), "no save should exist after failed purchase")


# --- Signal integration with economy flow ---


func test_buy_part_emits_signals_in_sequence() -> void:
	GameState.gold = 1000
	GameState.infamy = 10
	watch_signals(EventBus)
	var part := PartData.new()
	part.rarity = GameEnums.Rarity.COMMON
	GameState.buy_part(part)
	# gold_changed should fire (from spend_gold)
	assert_signal_emitted(EventBus, "gold_changed")
	# part_purchased should fire
	assert_signal_emitted(EventBus, "part_purchased")


# --- Ascension economy flow ---


func test_ascension_grants_research_point_and_saves() -> void:
	# Setup roster with a chimera eligible for ascension
	GameState.gold = 500
	GameState.infamy = 20
	var starters := PartDatabase.get_starter_chimeras()
	GameState.roster = []
	for starter in starters:
		GameState.roster.append(starter.duplicate())
	# Make first chimera eligible (10+ wins)
	var chimera := GameState.roster[0]
	chimera.match_wins = 10
	var rp_before := GameState.research_points
	# Ascend
	var gained: int = GameState.ascend_chimera(chimera)
	assert_eq(gained, 1, "should gain 1 research point")
	assert_eq(GameState.research_points, rp_before + 1, "research points should increase")
	# Verify saved
	assert_true(SaveManager.has_save(), "ascension should trigger save")
	# Load and verify
	GameState.research_points = 0
	GameState.hall_of_fame = []
	SaveManager.load_game()
	assert_eq(GameState.research_points, rp_before + 1, "research points preserved after load")
	assert_eq(GameState.hall_of_fame.size(), 1, "hall of fame should have 1 entry after load")
