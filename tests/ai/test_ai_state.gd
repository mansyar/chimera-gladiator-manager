extends GutTest

## Tests for AIState base class (FR-3: AIState Base Class).
## Verifies virtual methods exist and ai_controller reference works.


func test_can_instantiate() -> void:
	var state := AIState.new()
	assert_not_null(state, "AIState should be instantiable")


func test_enter_does_not_error() -> void:
	var state := AIState.new()
	state.enter()
	assert_true(is_instance_valid(state), "enter() should not crash")


func test_update_does_not_error() -> void:
	var state := AIState.new()
	state.update(0.016)
	assert_true(is_instance_valid(state), "update() should not crash")


func test_exit_does_not_error() -> void:
	var state := AIState.new()
	state.exit()
	assert_true(is_instance_valid(state), "exit() should not crash")


func test_ai_controller_can_be_set() -> void:
	var state := AIState.new()
	var controller := AIController.new()
	add_child_autofree(controller)
	state.ai_controller = controller
	assert_eq(state.ai_controller, controller, "ai_controller should be settable")
