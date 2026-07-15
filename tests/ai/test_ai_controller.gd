extends GutTest

## Tests for AIController interface stub (FR-2: AIController interface stub).
## Verifies method signatures exist and return defaults without error.


func test_change_state_does_not_error() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	controller.change_state("IDLE")
	assert_true(is_instance_valid(controller), "change_state should not crash the controller")


func test_acquire_target_returns_null() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var target: Variant = controller.acquire_target()
	assert_eq(target, null, "acquire_target should return null by default")


func test_process_does_not_error() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	controller._process(0.016)
	assert_true(is_instance_valid(controller), "_process should not crash the controller")
