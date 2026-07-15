extends GutTest

## Tests for ArenaController scene-level controller stub.
## (FR-1: Arena scene — ArenaController script)


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
