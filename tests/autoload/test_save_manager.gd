# gdlint:ignore=max-public-methods
## Tests for SaveManager autoload.
extends GutTest

const SAVE_PATH := "user://saves/save_default.json"

# --- Helpers ---


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


func _setup_test_state() -> void:
	GameState.gold = 500
	GameState.infamy = 30
	GameState.losing_streak = 2
	GameState.research_points = 3
	GameState.research_progress = {"strain_mastery": {"undead": 1, "beast": 2}}
	var starters := PartDatabase.get_starter_chimeras()
	GameState.roster = []
	for starter in starters:
		GameState.roster.append(starter.duplicate())
	GameState.inventory = [
		PartDatabase.generate_random_part(GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100})
	]
	GameState.market_stock = Market.generate_initial_stock()
	GameState.hall_of_fame = []
	GameState.match_history = [{"result": "win", "gold": 30}]


func _read_save_file() -> Dictionary:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(json_text)
	if parsed is Dictionary:
		return parsed
	return {}


# --- has_save ---


func test_has_save_returns_false_when_no_save() -> void:
	assert_false(SaveManager.has_save())


func test_has_save_returns_true_after_save() -> void:
	_setup_test_state()
	SaveManager.save_game()
	assert_true(SaveManager.has_save())


# --- delete_save ---


func test_delete_save_removes_save_file() -> void:
	_setup_test_state()
	SaveManager.save_game()
	assert_true(SaveManager.has_save())
	SaveManager.delete_save()
	assert_false(SaveManager.has_save())


func test_delete_save_no_crash_when_no_save() -> void:
	SaveManager.delete_save()
	assert_false(SaveManager.has_save())


# --- save_game: JSON file creation ---


func test_save_game_creates_valid_json_file() -> void:
	_setup_test_state()
	SaveManager.save_game()
	assert_true(FileAccess.file_exists(SAVE_PATH))
	var data := _read_save_file()
	assert_not_null(data)


# --- save_game: structure ---


func test_save_game_has_version_and_timestamp() -> void:
	_setup_test_state()
	SaveManager.save_game()
	var data := _read_save_file()
	assert_eq(data["version"], 1)
	assert_true(data.has("timestamp"))


func test_save_game_has_game_state_with_all_fields() -> void:
	_setup_test_state()
	SaveManager.save_game()
	var data := _read_save_file()
	var gs: Dictionary = data["game_state"]
	assert_true(gs.has("gold"))
	assert_true(gs.has("infamy"))
	assert_true(gs.has("losing_streak"))
	assert_true(gs.has("research_points"))
	assert_true(gs.has("research_progress"))
	assert_true(gs.has("roster"))
	assert_true(gs.has("inventory"))
	assert_true(gs.has("market_stock"))
	assert_true(gs.has("hall_of_fame"))
	assert_true(gs.has("match_history"))


# --- save_game: scalar field preservation ---


func test_save_game_preserves_scalar_fields() -> void:
	_setup_test_state()
	SaveManager.save_game()
	var data := _read_save_file()
	var gs: Dictionary = data["game_state"]
	assert_eq(gs["gold"], 500)
	assert_eq(gs["infamy"], 30)
	assert_eq(gs["losing_streak"], 2)
	assert_eq(gs["research_points"], 3)


func test_save_game_preserves_research_progress() -> void:
	_setup_test_state()
	SaveManager.save_game()
	var data := _read_save_file()
	var gs: Dictionary = data["game_state"]
	var rp: Dictionary = gs["research_progress"]
	assert_eq(rp["strain_mastery"]["undead"], 1)
	assert_eq(rp["strain_mastery"]["beast"], 2)


# --- save_game: part serialization by reference ---


func test_save_game_serializes_roster_parts_by_reference() -> void:
	_setup_test_state()
	SaveManager.save_game()
	var data := _read_save_file()
	var gs: Dictionary = data["game_state"]
	var roster: Array = gs["roster"]
	assert_eq(roster.size(), 3)
	var chimera: Dictionary = roster[0]
	assert_true(chimera.has("nickname"))
	assert_true(chimera.has("match_wins"))
	assert_true(chimera.has("decay_level"))
	assert_true(chimera.has("parts"))
	var parts: Dictionary = chimera["parts"]
	for slot_key in ["head", "torso", "arms", "legs"]:
		var part: Dictionary = parts[slot_key]
		assert_true(part.has("shape_id"))
		assert_true(part.has("strain"))
		assert_true(part.has("rarity"))
		assert_true(part.has("slot"))


func test_save_game_serializes_inventory_parts_by_reference() -> void:
	_setup_test_state()
	SaveManager.save_game()
	var data := _read_save_file()
	var gs: Dictionary = data["game_state"]
	var inv: Array = gs["inventory"]
	assert_eq(inv.size(), 1)
	var part: Dictionary = inv[0]
	assert_true(part.has("shape_id"))
	assert_true(part.has("strain"))
	assert_true(part.has("rarity"))
	assert_true(part.has("slot"))


func test_save_game_serializes_market_stock_parts_by_reference() -> void:
	_setup_test_state()
	SaveManager.save_game()
	var data := _read_save_file()
	var gs: Dictionary = data["game_state"]
	var ms: Dictionary = gs["market_stock"]
	assert_true(ms.has("base"))
	assert_true(ms.has("rotating"))
	var base: Array = ms["base"]
	assert_true(base.size() > 0)
	var part: Dictionary = base[0]
	assert_true(part.has("shape_id"))
	assert_true(part.has("strain"))
	assert_true(part.has("rarity"))
	assert_true(part.has("slot"))


# --- load_game ---


func test_load_game_returns_false_when_no_save() -> void:
	assert_false(SaveManager.load_game())


func test_load_game_returns_true_after_save() -> void:
	_setup_test_state()
	SaveManager.save_game()
	assert_true(SaveManager.load_game())


func test_load_game_restores_scalar_fields() -> void:
	_setup_test_state()
	SaveManager.save_game()
	GameState.gold = 0
	GameState.infamy = 0
	GameState.losing_streak = 0
	GameState.research_points = 0
	SaveManager.load_game()
	assert_eq(GameState.gold, 500)
	assert_eq(GameState.infamy, 30)
	assert_eq(GameState.losing_streak, 2)
	assert_eq(GameState.research_points, 3)


func test_load_game_restores_research_progress() -> void:
	_setup_test_state()
	SaveManager.save_game()
	GameState.research_progress = {}
	SaveManager.load_game()
	assert_eq(GameState.research_progress["strain_mastery"]["undead"], 1)
	assert_eq(GameState.research_progress["strain_mastery"]["beast"], 2)


func test_load_game_reconstructs_roster_parts() -> void:
	_setup_test_state()
	var original_nick := GameState.roster[0].nickname
	SaveManager.save_game()
	GameState.roster = []
	SaveManager.load_game()
	assert_eq(GameState.roster.size(), 3)
	assert_eq(GameState.roster[0].nickname, original_nick)
	assert_not_null(GameState.roster[0].head)
	assert_not_null(GameState.roster[0].torso)
	assert_not_null(GameState.roster[0].arms)
	assert_not_null(GameState.roster[0].legs)


func test_load_game_restores_inventory() -> void:
	_setup_test_state()
	SaveManager.save_game()
	GameState.inventory = []
	SaveManager.load_game()
	assert_eq(GameState.inventory.size(), 1)


func test_load_game_restores_market_stock() -> void:
	_setup_test_state()
	SaveManager.save_game()
	GameState.market_stock = {}
	SaveManager.load_game()
	assert_true(GameState.market_stock.has("base"))
	assert_true(GameState.market_stock.has("rotating"))
	var base: Array = GameState.market_stock["base"]
	assert_true(base.size() > 0)


func test_load_game_restores_match_history() -> void:
	_setup_test_state()
	SaveManager.save_game()
	GameState.match_history = []
	SaveManager.load_game()
	assert_eq(GameState.match_history.size(), 1)
	assert_eq(GameState.match_history[0]["result"], "win")


# --- Save/load round-trip ---


func test_save_load_round_trip_preserves_all_state() -> void:
	_setup_test_state()
	SaveManager.save_game()
	# Clear all state
	GameState.gold = 0
	GameState.infamy = 0
	GameState.losing_streak = 0
	GameState.research_points = 0
	GameState.research_progress = {}
	GameState.roster = []
	GameState.inventory = []
	GameState.market_stock = {}
	GameState.match_history = []
	# Load
	SaveManager.load_game()
	# Verify all fields
	assert_eq(GameState.gold, 500)
	assert_eq(GameState.infamy, 30)
	assert_eq(GameState.losing_streak, 2)
	assert_eq(GameState.research_points, 3)
	assert_eq(GameState.roster.size(), 3)
	assert_eq(GameState.inventory.size(), 1)
	assert_true(GameState.market_stock.has("base"))
	assert_eq(GameState.match_history.size(), 1)


# --- _migrate ---


func test_migrate_returns_data_unchanged_for_version_1() -> void:
	var data := {"version": 1, "game_state": {"gold": 100}}
	var result: Dictionary = SaveManager._migrate(1, data)
	assert_eq(result["version"], 1)
	assert_eq(result["game_state"]["gold"], 100)


# --- _exit_tree ---


func test_exit_tree_saves_game() -> void:
	_setup_test_state()
	assert_false(SaveManager.has_save())
	SaveManager._exit_tree()
	assert_true(SaveManager.has_save())


func test_exit_tree_creates_valid_save() -> void:
	_setup_test_state()
	SaveManager._exit_tree()
	var data := _read_save_file()
	assert_eq(data["version"], SaveManager.CURRENT_VERSION)
	assert_eq(data["game_state"]["gold"], 500)
