extends GutTest

## Tests for ArenaController scene-level controller.
## (FR-1: Arena scene — ArenaController script)
## (FR-9: Arena dimensions)
## (FR-10: Formation grid mapping)


func test_arena_controller_instantiates() -> void:
	var controller: ArenaController = ArenaController.new()
	assert_true(is_instance_valid(controller))
	controller.free()


func test_init_formation_grids_does_not_error() -> void:
	var controller: ArenaController = ArenaController.new()
	controller.init_formation_grids()
	assert_true(is_instance_valid(controller))
	controller.free()


func test_ready_does_not_error() -> void:
	var controller: ArenaController = ArenaController.new()
	add_child_autofree(controller)
	assert_true(is_instance_valid(controller))


func test_arena_dimensions() -> void:
	assert_eq(ArenaController.ARENA_WIDTH, 640)
	assert_eq(ArenaController.ARENA_HEIGHT, 360)


func test_grid_cell_size() -> void:
	assert_eq(ArenaController.GRID_CELL_SIZE, 64)


func test_grid_to_world_player_cells() -> void:
	# Row 0 (BACK): y=116
	assert_eq(ArenaController.grid_to_world(0, 0, true), Vector2(64, 116))
	assert_eq(ArenaController.grid_to_world(0, 1, true), Vector2(128, 116))
	assert_eq(ArenaController.grid_to_world(0, 2, true), Vector2(192, 116))
	# Row 1 (MID): y=180
	assert_eq(ArenaController.grid_to_world(1, 0, true), Vector2(64, 180))
	assert_eq(ArenaController.grid_to_world(1, 1, true), Vector2(128, 180))
	assert_eq(ArenaController.grid_to_world(1, 2, true), Vector2(192, 180))
	# Row 2 (FRONT): y=244
	assert_eq(ArenaController.grid_to_world(2, 0, true), Vector2(64, 244))
	assert_eq(ArenaController.grid_to_world(2, 1, true), Vector2(128, 244))
	assert_eq(ArenaController.grid_to_world(2, 2, true), Vector2(192, 244))


func test_grid_to_world_enemy_cells() -> void:
	# Row 0 (BACK): y=116
	assert_eq(ArenaController.grid_to_world(0, 0, false), Vector2(448, 116))
	assert_eq(ArenaController.grid_to_world(0, 1, false), Vector2(512, 116))
	assert_eq(ArenaController.grid_to_world(0, 2, false), Vector2(576, 116))
	# Row 1 (MID): y=180
	assert_eq(ArenaController.grid_to_world(1, 0, false), Vector2(448, 180))
	assert_eq(ArenaController.grid_to_world(1, 1, false), Vector2(512, 180))
	assert_eq(ArenaController.grid_to_world(1, 2, false), Vector2(576, 180))
	# Row 2 (FRONT): y=244
	assert_eq(ArenaController.grid_to_world(2, 0, false), Vector2(448, 244))
	assert_eq(ArenaController.grid_to_world(2, 1, false), Vector2(512, 244))
	assert_eq(ArenaController.grid_to_world(2, 2, false), Vector2(576, 244))
