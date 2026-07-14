## Save and load system.
##
## Handles serializing game state to JSON files at user://saves/.[br]
## Parts are saved by reference (shape_id + strain + rarity + slot).
extends Node

const SAVE_DIR := "user://saves"
const SAVE_PATH := "user://saves/save_default.json"
const CURRENT_VERSION := 1

# --- Public API ---


## Save the current game state to a JSON file.[br]
## Serializes all GameState properties including roster, inventory,[br]
## market stock, and campaign progress. Parts are saved by reference.
func save_game() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var save_data := {
		"version": CURRENT_VERSION,
		"timestamp": Time.get_datetime_string_from_system(),
		"game_state": _serialize_game_state(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))


## Load game from save file.[br]
## Returns [code]false[/code] if no save exists or JSON is invalid.[br]
## Reconstructs parts via PartDatabase. Calls [code]_migrate()[/code]
## if save version differs from current.[br]
## [returns] [code]true[/code] if loaded successfully, [code]false[/code] otherwise.
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(json_text)
	if parsed == null or not (parsed is Dictionary):
		return false
	var save_data: Dictionary = parsed
	var save_version: int = save_data.get("version", CURRENT_VERSION)
	if save_version != CURRENT_VERSION:
		save_data = _migrate(save_version, save_data)
	_deserialize_game_state(save_data["game_state"])
	return true


## Check if a save file exists.[br]
## [returns] [code]true[/code] if a save file exists, [code]false[/code] otherwise.
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


## Delete the save file.[br]
## Does nothing if no save exists.
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


# --- Migration ---


## Migrate save data from an older version.[br]
## Currently a stub: version 1 is the only version, no migration needed.[br]
## [param from_version] The version of the save data being migrated.[br]
## [param data] The save data to migrate.[br]
## [returns] The migrated save data.
func _migrate(  # gdlint:ignore=unused-argument
	from_version: int,
	data: Dictionary,
) -> Dictionary:
	return data


# --- Serialization ---


func _serialize_game_state() -> Dictionary:
	var roster_data: Array = []
	for chimera in GameState.roster:
		roster_data.append(_serialize_chimera(chimera))
	var inventory_data: Array = []
	for part in GameState.inventory:
		inventory_data.append(_serialize_part(part))
	var market_base_data: Array = []
	for part in GameState.market_stock.get("base", []):
		market_base_data.append(_serialize_part(part))
	var market_rotating_data: Array = []
	for part in GameState.market_stock.get("rotating", []):
		market_rotating_data.append(_serialize_part(part))
	var hall_of_fame_data: Array = []
	for chimera in GameState.hall_of_fame:
		hall_of_fame_data.append(_serialize_chimera(chimera))
	return {
		"gold": GameState.gold,
		"infamy": GameState.infamy,
		"losing_streak": GameState.losing_streak,
		"research_points": GameState.research_points,
		"research_progress": GameState.research_progress,
		"roster": roster_data,
		"inventory": inventory_data,
		"market_stock":
		{
			"base": market_base_data,
			"rotating": market_rotating_data,
		},
		"hall_of_fame": hall_of_fame_data,
		"match_history": GameState.match_history,
	}


func _serialize_part(part: PartData) -> Dictionary:
	if part == null:
		return {}
	return {
		"shape_id": part.shape_id,
		"strain": part.strain,
		"rarity": part.rarity,
		"slot": part.slot,
	}


func _serialize_chimera(chimera: ChimeraData) -> Dictionary:
	return {
		"nickname": chimera.nickname,
		"match_wins": chimera.match_wins,
		"decay_level": chimera.decay_level,
		"parts":
		{
			"head": _serialize_part(chimera.head),
			"torso": _serialize_part(chimera.torso),
			"arms": _serialize_part(chimera.arms),
			"legs": _serialize_part(chimera.legs),
		},
	}


# --- Deserialization ---


func _deserialize_game_state(gs: Dictionary) -> void:
	GameState.gold = gs.get("gold", 200)
	GameState.infamy = gs.get("infamy", 0)
	GameState.losing_streak = gs.get("losing_streak", 0)
	GameState.research_points = gs.get("research_points", 0)
	GameState.research_progress = gs.get("research_progress", {})
	# Roster
	var roster_data: Array = gs.get("roster", [])
	GameState.roster = []
	for chimera_data in roster_data:
		GameState.roster.append(_deserialize_chimera(chimera_data))
	# Inventory
	var inventory_data: Array = gs.get("inventory", [])
	GameState.inventory = []
	for part_data in inventory_data:
		var part := _deserialize_part(part_data)
		if part != null:
			GameState.inventory.append(part)
	# Market stock
	var market_stock_data: Dictionary = gs.get("market_stock", {})
	var market_base: Array = []
	for part_data in market_stock_data.get("base", []):
		var part := _deserialize_part(part_data)
		if part != null:
			market_base.append(part)
	var market_rotating: Array = []
	for part_data in market_stock_data.get("rotating", []):
		var part := _deserialize_part(part_data)
		if part != null:
			market_rotating.append(part)
	GameState.market_stock = {
		"base": market_base,
		"rotating": market_rotating,
	}
	# Hall of fame
	var hof_data: Array = gs.get("hall_of_fame", [])
	GameState.hall_of_fame = []
	for chimera_data in hof_data:
		GameState.hall_of_fame.append(_deserialize_chimera(chimera_data))
	# Match history
	var match_history_data: Array = gs.get("match_history", [])
	GameState.match_history = []
	for entry in match_history_data:
		GameState.match_history.append(entry)


func _deserialize_part(data: Dictionary) -> PartData:
	if data.is_empty():
		return null
	return (
		PartDatabase
		. get_part(
			data["shape_id"],
			data["strain"],
			data["rarity"],
		)
	)


func _deserialize_chimera(data: Dictionary) -> ChimeraData:
	var chimera := ChimeraData.new()
	chimera.nickname = data.get("nickname", "")
	chimera.match_wins = data.get("match_wins", 0)
	chimera.decay_level = data.get("decay_level", 0)
	var parts: Dictionary = data.get("parts", {})
	chimera.head = _deserialize_part(parts.get("head", {}))
	chimera.torso = _deserialize_part(parts.get("torso", {}))
	chimera.arms = _deserialize_part(parts.get("arms", {}))
	chimera.legs = _deserialize_part(parts.get("legs", {}))
	chimera.calculate_instability()
	chimera.recalculate_stats()
	return chimera
