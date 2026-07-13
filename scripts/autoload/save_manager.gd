## Save and load system.
##
## Handles serializing game state to JSON files at user://saves/.
## Parts are saved by reference (shape_id + strain + rarity).
extends Node


func _ready() -> void:
	print("SaveManager ready")
