## Tests for FormationGrid widget — renders 3x3 grid with occupied cell highlighting.
extends GutTest
# gdlint:ignore=max-public-methods

# --- Node creation tests ---


func test_formation_grid_creates_9_cells() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	assert_eq(widget.get_cell_count(), 9, "Should create 9 cells in 3x3 grid")


func test_formation_grid_creates_grid_container() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	assert_not_null(widget.get_grid_container(), "GridContainer should exist after _ready")


# --- Highlighting tests ---


func test_no_cells_highlighted_by_default() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	for i in range(9):
		assert_false(
			widget.is_cell_highlighted(i), "Cell %d should not be highlighted by default" % i
		)


func test_highlights_single_occupied_cell() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	widget.grid_data = [false, false, false, false, true, false, false, false, false]
	assert_false(widget.is_cell_highlighted(0), "Cell 0 should not be highlighted")
	assert_true(widget.is_cell_highlighted(4), "Cell 4 should be highlighted")
	assert_false(widget.is_cell_highlighted(8), "Cell 8 should not be highlighted")


func test_highlights_multiple_occupied_cells() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	widget.grid_data = [true, false, true, false, true, false, true, false, true]
	assert_true(widget.is_cell_highlighted(0), "Cell 0 should be highlighted")
	assert_false(widget.is_cell_highlighted(1), "Cell 1 should not be highlighted")
	assert_true(widget.is_cell_highlighted(2), "Cell 2 should be highlighted")
	assert_true(widget.is_cell_highlighted(4), "Cell 4 should be highlighted")
	assert_true(widget.is_cell_highlighted(6), "Cell 6 should be highlighted")
	assert_true(widget.is_cell_highlighted(8), "Cell 8 should be highlighted")


func test_highlights_all_cells() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	widget.grid_data = [true, true, true, true, true, true, true, true, true]
	for i in range(9):
		assert_true(widget.is_cell_highlighted(i), "Cell %d should be highlighted" % i)


func test_highlights_no_cells_when_all_false() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	widget.grid_data = [false, false, false, false, false, false, false, false, false]
	for i in range(9):
		assert_false(widget.is_cell_highlighted(i), "Cell %d should not be highlighted" % i)


# --- Update tests ---


func test_updates_highlighting_when_grid_data_changes() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	widget.grid_data = [true, false, false, false, false, false, false, false, false]
	assert_true(widget.is_cell_highlighted(0), "Cell 0 should be highlighted initially")
	widget.grid_data = [false, true, false, false, false, false, false, false, false]
	assert_false(widget.is_cell_highlighted(0), "Cell 0 should no longer be highlighted")
	assert_true(widget.is_cell_highlighted(1), "Cell 1 should now be highlighted")


# --- Edge cases ---


func test_no_crash_with_empty_grid_data() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	widget.grid_data = []
	for i in range(9):
		assert_false(
			widget.is_cell_highlighted(i), "No cells should be highlighted with empty data"
		)


func test_no_crash_with_short_grid_data() -> void:
	var widget: FormationGrid = add_child_autofree(FormationGrid.new())
	widget.grid_data = [true, false]
	assert_true(widget.is_cell_highlighted(0), "Cell 0 should be highlighted")
	assert_false(widget.is_cell_highlighted(1), "Cell 1 should not be highlighted")
	assert_false(widget.is_cell_highlighted(2), "Cell 2 should not be highlighted")
