class_name ArenaController
extends Node2D

## Scene-level controller for arena setup.
## Manages entity spawning and formation grid initialization.
## Does NOT manage match lifecycle — that is CombatManager's role (TRACK-008).
## (FR-1: Arena scene)

const ARENA_WIDTH: int = 640
const ARENA_HEIGHT: int = 360

const GRID_CELL_SIZE: int = 64
const PLAYER_GRID_ORIGIN: Vector2 = Vector2(32, 84)
const ENEMY_GRID_ORIGIN: Vector2 = Vector2(416, 84)

@onready var entities: Node2D = get_node_or_null("Entities")
@onready var formation_grid_player: Node2D = get_node_or_null("FormationGridPlayer")
@onready var formation_grid_enemy: Node2D = get_node_or_null("FormationGridEnemy")


func _ready() -> void:
	pass  # Scene-level setup placeholder


func init_formation_grids() -> void:
	pass  # Scene-level formation grid initialization (to be wired in TRACK-006)


## Returns the world-space center of a formation grid cell.
## Row 0=BACK (top), Row 1=MID, Row 2=FRONT (bottom).
## Col 0=LEFT, Col 1=CENTER, Col 2=RIGHT.
## (FR-10: Formation grid mapping)
static func grid_to_world(row: int, col: int, is_player: bool) -> Vector2:
	var origin: Vector2 = PLAYER_GRID_ORIGIN if is_player else ENEMY_GRID_ORIGIN
	return Vector2(
		origin.x + col * GRID_CELL_SIZE + GRID_CELL_SIZE / 2,
		origin.y + row * GRID_CELL_SIZE + GRID_CELL_SIZE / 2
	)
