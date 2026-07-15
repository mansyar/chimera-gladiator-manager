# gdlint:ignore=max-public-methods
## Edge case tests for save/load round-trip and PartDatabase reconstruction.
##
## Tests full state preservation, part reconstruction from saved references,
## multiple save/load cycles, and empty-state edge cases.
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


func _setup_full_state() -> void:
	## Populate GameState with all fields for comprehensive round-trip testing.
	GameState.gold = 500
	GameState.infamy = 42
	GameState.losing_streak = 3
	GameState.research_points = 5
	GameState.research_progress = {
		"combat_doctrine": 2,
		"reinforced_genetics": 1,
	}
	# Roster with 2 chimeras from starter templates
	var starters := PartDatabase.get_starter_chimeras()
	for starter in starters:
		var dup := starter.duplicate()
		dup.calculate_instability()
		dup.recalculate_stats()
		GameState.roster.append(dup)
		if GameState.roster.size() >= 2:
			break
	# Inventory with 3 parts from PartDatabase (serializable)
	for i in range(3):
		var part := PartDatabase.generate_random_part(
			GameEnums.PartSlot.values()[i], {GameEnums.Rarity.COMMON: 100}
		)
		GameState.inventory.append(part)
	# Market stock
	GameState.market_stock = Market.generate_initial_stock()
	# Match history
	GameState.match_history = [
		{"type": "regular", "won": true, "gold": 30, "infamy": 2},
		{"type": "tournament", "won": false, "gold": 10, "infamy": 0},
	]
	# Hall of fame with 1 chimera
	var hof_chimera := starters[0].duplicate()
	hof_chimera.nickname = "Champion"
	hof_chimera.match_wins = 10
	hof_chimera.calculate_instability()
	hof_chimera.recalculate_stats()
	GameState.hall_of_fame.append(hof_chimera)


# --- Full state preservation ---


func test_full_state_preservation_through_save_load() -> void:
	_setup_full_state()
	var saved_gold := GameState.gold
	var saved_infamy := GameState.infamy
	var saved_losing_streak := GameState.losing_streak
	var saved_research_points := GameState.research_points
	var saved_research_progress := GameState.research_progress.duplicate()
	var saved_roster_size := GameState.roster.size()
	var saved_inventory_size := GameState.inventory.size()
	var saved_match_history_size := GameState.match_history.size()
	var saved_hof_size := GameState.hall_of_fame.size()

	SaveManager.save_game()
	_reset_game_state()
	var loaded := SaveManager.load_game()

	assert_true(loaded, "Load should succeed")
	assert_eq(GameState.gold, saved_gold, "Gold should match")
	assert_eq(GameState.infamy, saved_infamy, "Infamy should match")
	assert_eq(GameState.losing_streak, saved_losing_streak, "Losing streak should match")
	assert_eq(GameState.research_points, saved_research_points, "Research points should match")
	assert_eq(
		GameState.research_progress.size(),
		saved_research_progress.size(),
		"Research progress size should match"
	)
	assert_eq(
		int(GameState.research_progress["combat_doctrine"]),
		int(saved_research_progress["combat_doctrine"]),
		"Combat doctrine should match"
	)
	assert_eq(
		int(GameState.research_progress["reinforced_genetics"]),
		int(saved_research_progress["reinforced_genetics"]),
		"Reinforced genetics should match"
	)
	assert_eq(GameState.roster.size(), saved_roster_size, "Roster size should match")
	assert_eq(GameState.inventory.size(), saved_inventory_size, "Inventory size should match")
	assert_eq(
		GameState.match_history.size(), saved_match_history_size, "Match history size should match"
	)
	assert_eq(GameState.hall_of_fame.size(), saved_hof_size, "Hall of fame size should match")


func test_chimera_stats_preserved_through_save_load() -> void:
	_setup_full_state()
	var original := GameState.roster[0]
	var original_attack := original.attack
	var original_hp := original.max_hp
	var original_nickname := original.nickname

	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()

	var loaded := GameState.roster[0]
	assert_eq(loaded.nickname, original_nickname, "Nickname should match")
	assert_almost_eq(loaded.attack, original_attack, 0.01, "Attack should match")
	assert_almost_eq(loaded.max_hp, original_hp, 0.01, "Max HP should match")


func test_research_progress_preserved_with_multiple_nodes() -> void:
	GameState.research_progress = {
		"combat_doctrine": 3,
		"reinforced_genetics": 2,
		"market_connections": 1,
		"formation_mastery": 0,
	}
	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()
	assert_eq(
		int(GameState.research_progress["combat_doctrine"]), 3, "Combat doctrine level preserved"
	)
	assert_eq(
		int(GameState.research_progress["reinforced_genetics"]),
		2,
		"Reinforced genetics level preserved"
	)
	assert_eq(
		int(GameState.research_progress["market_connections"]),
		1,
		"Market connections level preserved"
	)


func test_match_history_entries_preserved() -> void:
	GameState.match_history = [
		{"type": "regular", "won": true, "gold": 30, "infamy": 2},
		{"type": "regular", "won": false, "gold": 10, "infamy": 0},
		{"type": "tournament", "won": true, "gold": 200, "infamy": 40},
	]
	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()
	assert_eq(GameState.match_history.size(), 3, "Should have 3 match history entries")
	assert_eq(int(GameState.match_history[0]["gold"]), 30, "First entry gold preserved")
	assert_eq(int(GameState.match_history[2]["infamy"]), 40, "Third entry infamy preserved")


# --- PartDatabase reconstruction ---


func test_part_reconstruction_from_saved_references() -> void:
	## Parts saved by reference (shape_id + strain + rarity) should be
	## reconstructable via PartDatabase.get_part after loading.
	var part := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	GameState.inventory.append(part)
	var saved_shape_id := part.shape_id
	var saved_strain := part.strain
	var saved_rarity := part.rarity

	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()

	assert_eq(GameState.inventory.size(), 1, "Should have 1 part in inventory")
	var loaded_part := GameState.inventory[0]
	assert_eq(loaded_part.shape_id, saved_shape_id, "Shape ID should match")
	assert_eq(loaded_part.strain, saved_strain, "Strain should match")
	assert_eq(loaded_part.rarity, saved_rarity, "Rarity should match")
	# Verify the loaded part matches what PartDatabase would return
	var expected := PartDatabase.get_part(saved_shape_id, saved_strain, saved_rarity)
	assert_eq(
		loaded_part.attack_bonus,
		expected.attack_bonus,
		"Attack bonus should match PartDatabase reconstruction"
	)


func test_chimera_parts_reconstructed_correctly() -> void:
	## Each chimera part slot should be reconstructed from saved references.
	var starters := PartDatabase.get_starter_chimeras()
	var chimera := starters[0].duplicate()
	chimera.calculate_instability()
	chimera.recalculate_stats()
	GameState.roster.append(chimera)
	var original_head_shape: String = chimera.head.shape_id
	var original_head_strain: int = chimera.head.strain

	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()

	var loaded := GameState.roster[0]
	assert_not_null(loaded.head, "Head should not be null")
	assert_eq(loaded.head.shape_id, original_head_shape, "Head shape_id should match")
	assert_eq(loaded.head.strain, original_head_strain, "Head strain should match")


func test_legendary_part_rarity_preserved() -> void:
	## Legendary rarity should survive the save/load round-trip.
	var part := PartDatabase.generate_random_part(
		GameEnums.PartSlot.TORSO, {GameEnums.Rarity.LEGENDARY: 100}
	)
	GameState.inventory.append(part)
	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()
	assert_eq(
		GameState.inventory[0].rarity,
		GameEnums.Rarity.LEGENDARY,
		"Legendary rarity should be preserved"
	)


# --- Multiple save/load cycles ---


func test_multiple_save_load_cycles_preserve_state() -> void:
	## Save → load → save → load should produce identical state.
	_setup_full_state()
	SaveManager.save_game()
	SaveManager.load_game()
	var gold_after_first := GameState.gold
	var roster_size_after_first := GameState.roster.size()

	# Second cycle
	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()

	assert_eq(GameState.gold, gold_after_first, "Gold should be same after 2nd cycle")
	assert_eq(
		GameState.roster.size(),
		roster_size_after_first,
		"Roster size should be same after 2nd cycle"
	)


func test_save_load_with_decay_level_preserved() -> void:
	## decay_level should survive the save/load round-trip.
	var starters := PartDatabase.get_starter_chimeras()
	var chimera := starters[0].duplicate()
	# Swap one part to a different strain — all starter chimeras are purebred
	# (instability=0), which are immune to decay. Mixing strains guarantees
	# instability > 0 so decay actually applies.
	chimera.head = starters[1].head
	chimera.calculate_instability()
	chimera.recalculate_stats()
	Decay.apply_decay(chimera)
	Decay.apply_decay(chimera)
	assert_gt(chimera.decay_level, 0, "decay_level should be > 0 after applying decay")
	GameState.roster.append(chimera)
	var saved_decay_level: int = chimera.decay_level

	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()

	assert_eq(
		GameState.roster[0].decay_level,
		saved_decay_level,
		"Decay level should be preserved through save/load"
	)


# --- Empty state edge cases ---


func test_save_load_empty_state() -> void:
	## Saving with empty roster/inventory should load back as empty.
	GameState.gold = 0
	GameState.infamy = 0
	GameState.roster = []
	GameState.inventory = []
	GameState.match_history = []
	GameState.hall_of_fame = []
	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()
	assert_eq(GameState.gold, 0, "Gold should be 0")
	assert_eq(GameState.roster.size(), 0, "Roster should be empty")
	assert_eq(GameState.inventory.size(), 0, "Inventory should be empty")
	assert_eq(GameState.match_history.size(), 0, "Match history should be empty")
	assert_eq(GameState.hall_of_fame.size(), 0, "Hall of fame should be empty")


func test_save_load_preserves_market_stock() -> void:
	## Market stock (base + rotating) should survive save/load.
	GameState.market_stock = Market.generate_initial_stock()
	var base_size: int = GameState.market_stock.get("base", []).size()
	var rotating_size: int = GameState.market_stock.get("rotating", []).size()

	SaveManager.save_game()
	_reset_game_state()
	SaveManager.load_game()

	var loaded_base: Array = GameState.market_stock.get("base", [])
	var loaded_rotating: Array = GameState.market_stock.get("rotating", [])
	assert_eq(loaded_base.size(), base_size, "Base market stock size should match")
	assert_eq(loaded_rotating.size(), rotating_size, "Rotating market stock size should match")
