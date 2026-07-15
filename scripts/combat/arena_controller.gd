class_name ArenaController
extends Node2D

## Scene-level controller for arena setup.
## Manages entity spawning and formation grid initialization.
## Does NOT manage match lifecycle — that is CombatManager's role (TRACK-008).
## (FR-1: Arena scene)

@onready var entities: Node2D = get_node_or_null("Entities")
@onready var formation_grid_player: Node2D = get_node_or_null("FormationGridPlayer")
@onready var formation_grid_enemy: Node2D = get_node_or_null("FormationGridEnemy")


func _ready() -> void:
	pass  # Scene-level setup placeholder


func init_formation_grids() -> void:
	pass  # Phase 3: Implement grid_to_world mapping (FR-10)
