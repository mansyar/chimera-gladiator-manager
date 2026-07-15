extends GutTest

## Tests for AIController FSM core (FR-2: AIController node, TDD Section 7).
## Verifies state management, setup, process delegation, and stubs.

# gdlint:ignore=max-public-methods


func test_setup_ai_sets_behavior_module() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var module: BehaviorModuleData = BehaviorModuleData.new()
	controller.setup_ai(module, CombatState.new(), CombatContext.new())
	assert_eq(controller.behavior_module, module, "setup_ai should set behavior_module")


func test_setup_ai_sets_combat_state() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var state: CombatState = CombatState.new()
	controller.setup_ai(BehaviorModuleData.new(), state, CombatContext.new())
	assert_eq(controller.combat_state, state, "setup_ai should set combat_state")


func test_setup_ai_sets_combat_context() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var context: CombatContext = CombatContext.new()
	controller.setup_ai(BehaviorModuleData.new(), CombatState.new(), context)
	assert_eq(controller.combat_context, context, "setup_ai should set combat_context")


func test_register_state_sets_ai_controller() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var state: MockState = MockState.new()
	controller.register_state("IDLE", state)
	assert_eq(state.ai_controller, controller, "register_state should set ai_controller on state")


func test_change_state_calls_exit_on_current() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var old_state: MockState = MockState.new()
	var new_state: MockState = MockState.new()
	controller.register_state("OLD", old_state)
	controller.register_state("NEW", new_state)
	controller.current_state = old_state
	controller.change_state("NEW")
	assert_true(old_state.exit_called, "change_state should call exit on current state")


func test_change_state_calls_enter_on_new() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var new_state: MockState = MockState.new()
	controller.register_state("NEW", new_state)
	controller.change_state("NEW")
	assert_true(new_state.enter_called, "change_state should call enter on new state")


func test_change_state_swaps_current_state() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var new_state: MockState = MockState.new()
	controller.register_state("NEW", new_state)
	controller.change_state("NEW")
	assert_eq(controller.current_state, new_state, "change_state should swap current_state")


func test_change_state_with_no_current_does_not_error() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var new_state: MockState = MockState.new()
	controller.register_state("NEW", new_state)
	controller.change_state("NEW")
	assert_true(is_instance_valid(controller), "change_state with no current should not crash")


func test_process_delegates_to_current_state_update() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var state: MockState = MockState.new()
	controller.current_state = state
	controller._process(0.5)
	assert_true(state.update_called, "_process should call update on current state")
	assert_eq(state.last_delta, 0.5, "_process should pass delta to update")


func test_process_with_no_current_state_does_not_error() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	controller._process(0.016)
	assert_true(is_instance_valid(controller), "_process with no current state should not crash")


func test_initial_state_is_idle() -> void:
	var controller: AIController = AIController.new()
	var idle: MockState = MockState.new()
	controller.register_state("IDLE", idle)
	add_child_autofree(controller)
	assert_eq(controller.current_state, idle, "Initial state should be IDLE")
	assert_true(idle.enter_called, "enter() should be called on initial state")


func test_entity_onready_reference() -> void:
	var chimera: ChimeraEntity = ChimeraEntity.new()
	add_child_autofree(chimera)
	var controller: AIController = AIController.new()
	chimera.add_child(controller)
	assert_eq(controller.entity, chimera, "entity should reference parent ChimeraEntity")


func test_entity_null_when_parent_not_chimera() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	assert_eq(controller.entity, null, "entity should be null when parent is not ChimeraEntity")


func test_acquire_target_returns_null_stub() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var target: Variant = controller.acquire_target()
	assert_eq(target, null, "acquire_target should return null (stub)")


func test_get_move_position_returns_zero_for_null_target() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var pos: Vector2 = controller.get_move_position(null)
	assert_eq(pos, Vector2.ZERO, "get_move_position should return ZERO for null target")


func test_get_next_ready_ability_returns_null_stub() -> void:
	var controller: AIController = AIController.new()
	add_child_autofree(controller)
	var ability: Variant = controller.get_next_ready_ability()
	assert_eq(ability, null, "get_next_ready_ability should return null (stub)")


## Mock AIState that tracks method calls for testing FSM transitions.
class MockState:
	extends AIState

	var enter_called: bool = false
	var update_called: bool = false
	var exit_called: bool = false
	var last_delta: float = 0.0

	func enter() -> void:
		enter_called = true

	func update(delta: float) -> void:
		update_called = true
		last_delta = delta

	func exit() -> void:
		exit_called = true
