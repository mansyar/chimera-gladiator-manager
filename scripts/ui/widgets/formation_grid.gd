## Widget that renders a 3x3 formation grid with occupied cell highlighting.
class_name FormationGrid
extends Control

const CELL_COUNT: int = 9
const HIGHLIGHT_COLOR: Color = Color(0.3, 0.8, 0.3)
const DEFAULT_COLOR: Color = Color(0.15, 0.15, 0.15)

## Array of booleans (9 elements). true = cell is occupied/highlighted.
@export var grid_data: Array:
	set(value):
		grid_data = value
		if _is_ready:
			_update_display()

var _is_ready: bool = false
var _grid_container: GridContainer = null
var _cells: Array[ColorRect] = []


func _ready() -> void:
	_grid_container = GridContainer.new()
	_grid_container.name = "GridContainer"
	_grid_container.columns = 3
	add_child(_grid_container)

	for i in range(CELL_COUNT):
		var cell := ColorRect.new()
		cell.name = "Cell%d" % i
		cell.custom_minimum_size = Vector2(32, 32)
		cell.color = DEFAULT_COLOR
		_grid_container.add_child(cell)
		_cells.append(cell)

	_is_ready = true
	_update_display()


## Returns the GridContainer holding the 9 cells.
func get_grid_container() -> GridContainer:
	return _grid_container


## Returns the number of cells in the grid (always 9).
func get_cell_count() -> int:
	return _cells.size()


## Returns true if the cell at index is highlighted (occupied).
func is_cell_highlighted(index: int) -> bool:
	if index < 0 or index >= _cells.size():
		return false
	if index >= grid_data.size():
		return false
	return bool(grid_data[index])


func _update_display() -> void:
	for i in range(_cells.size()):
		if i < grid_data.size() and bool(grid_data[i]):
			_cells[i].color = HIGHLIGHT_COLOR
		else:
			_cells[i].color = DEFAULT_COLOR
