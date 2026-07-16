## Combat match manager.
##
## Creates and manages transient CombatState instances for each match.
## Handles combat lifecycle: setup, execution, resolution.
extends Node

## Whether a combat match is currently active.
## When false, _process returns early (no combat simulation).
var match_active: bool = false

## Countdown timer for the current match (starts at 60.0 seconds).
var timer: float = 0.0

## All ChimeraEntity instances spawned for the current match.
var combat_entities: Array[ChimeraEntity] = []

## Combat context tracking entities for the current match.
var combat_context: CombatContext = null

## Player formation grid positions for the current match.
var player_formation: Array = []

## Enemy formation grid positions for the current match.
var enemy_formation: Array = []

## Result dictionary populated when a match ends.
var match_result: Dictionary = {}


func _process(delta: float) -> void:  # gdlint:ignore=unused-argument
	if not match_active:
		return


## Find the arena's Entities node via the 'arena_entities' scene tree group.
## If no arena scene is loaded (test mode), creates a temporary Node2D container.
func _find_or_create_entities_container() -> Node2D:
	var nodes := get_tree().get_nodes_in_group("arena_entities")
	if not nodes.is_empty():
		return nodes[0] as Node2D
	# No arena scene loaded (test mode) — create a temporary container
	var container := Node2D.new()
	container.name = "TempEntities"
	add_child(container)
	return container
