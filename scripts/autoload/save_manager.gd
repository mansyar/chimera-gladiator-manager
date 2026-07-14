## Save and load system.
##
## Handles serializing game state to JSON files at user://saves/.
## Parts are saved by reference (shape_id + strain + rarity).
extends Node


## Load game from save file.[br]
## Returns [code]false[/code] if no save exists.[br]
## [returns] [code]true[/code] if loaded successfully, [code]false[/code] otherwise.
func load_game() -> bool:
	return false
