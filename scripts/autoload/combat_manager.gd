## Combat match manager.
##
## Creates and manages transient CombatState instances for each match.
## Handles combat lifecycle: setup, execution, resolution.
extends Node

## Whether a combat match is currently active.
## When false, _process returns early (no combat simulation).
var match_active: bool = false


func _process(delta: float) -> void:  # gdlint:ignore=unused-argument
	if not match_active:
		return
