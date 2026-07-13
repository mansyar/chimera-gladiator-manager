## Persistent campaign state manager.
##
## Stores and manages all persistent game data including:
## - Player's chimera roster
## - Inventory and currency
## - Campaign progress
extends Node


func _ready() -> void:
	print("GameState ready")
