## Combat match manager.
##
## Creates and manages transient CombatState instances for each match.
## Handles combat lifecycle: setup, execution, resolution.
extends Node


func _ready() -> void:
	print("CombatManager ready")
