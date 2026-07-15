extends GutTest

## Tests for FSM state transition logic (FR-4: State Flow, TDD Section 7).
## Verifies all 8 states and their transition behavior.

# gdlint:ignore=max-public-methods


# Mock AIController that allows controlling stub method returns.
class MockAIController:
	extends AIController

	var mock_target: ChimeraEntity = null
	var mock_ability: AbilityData = null

	func acquire_target() -> ChimeraEntity:
		return mock_target

	func get_next_ready_ability() -> AbilityData:
		return mock_ability


func _create_controller() -> MockAIController:
	var controller := MockAIController.new()
	controller.register_state("IDLE", IdleState.new())
	controller.register_state("ACQUIRE_TARGET", AcquireTargetState.new())
	controller.register_state("MOVE_TO_TARGET", MoveToTargetState.new())
	controller.register_state("IN_RANGE", InRangeState.new())
	controller.register_state("ATTACK", AttackState.new())
	controller.register_state("USE_ABILITY", UseAbilityState.new())
	controller.register_state("BERSERK", BerserkState.new())
	controller.register_state("DEAD", DeadState.new())
	return controller


func _create_combat_state(
	atk: float = 10.0, def: float = 5.0, spd: float = 10.0, rng: float = 48.0
) -> CombatState:
	var cs := CombatState.new()
	cs.attack = atk
	cs.defense = def
	cs.speed = spd
	cs.attack_range = rng
	cs.max_hp = 100.0
	cs.current_hp = 100.0
	return cs


func _create_entity(pos: Vector2 = Vector2.ZERO) -> ChimeraEntity:
	var entity := ChimeraEntity.new()
	entity.combat_state = _create_combat_state()
	entity.global_position = pos
	add_child_autofree(entity)
	return entity


# --- IDLE state tests ---


func test_idle_transitions_to_acquire_target() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.change_state("IDLE")
	controller.current_state.update(0.016)
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["ACQUIRE_TARGET"],
		"IDLE should transition to ACQUIRE_TARGET after 2 frames"
	)


func test_idle_stays_idle_on_first_frame() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.change_state("IDLE")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state, controller.states["IDLE"], "IDLE should stay IDLE on first frame"
	)


# --- ACQUIRE_TARGET state tests ---


func test_acquire_target_null_transitions_to_idle() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.mock_target = null
	controller.change_state("ACQUIRE_TARGET")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["IDLE"],
		"ACQUIRE_TARGET with null target should transition to IDLE"
	)


func test_acquire_target_found_transitions_to_move_to_target() -> void:
	var controller := _create_controller()
	autofree(controller)
	var target := _create_entity()
	controller.mock_target = target
	controller.change_state("ACQUIRE_TARGET")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["MOVE_TO_TARGET"],
		"ACQUIRE_TARGET with target found should transition to MOVE_TO_TARGET"
	)
	assert_eq(controller.target, target, "ACQUIRE_TARGET should set controller.target")


# --- MOVE_TO_TARGET state tests ---


func test_move_to_target_in_range_transitions_to_in_range() -> void:
	var controller := _create_controller()
	autofree(controller)
	var entity := _create_entity(Vector2.ZERO)
	var target := _create_entity(Vector2(30, 0))
	controller.entity = entity
	controller.combat_state = entity.combat_state
	controller.target = target
	controller.change_state("MOVE_TO_TARGET")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["IN_RANGE"],
		"MOVE_TO_TARGET should transition to IN_RANGE when within attack_range"
	)


func test_move_to_target_null_transitions_to_acquire_target() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.target = null
	controller.change_state("MOVE_TO_TARGET")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["ACQUIRE_TARGET"],
		"MOVE_TO_TARGET with null target should transition to ACQUIRE_TARGET"
	)


# --- IN_RANGE state tests ---


func test_in_range_ability_ready_transitions_to_use_ability() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.mock_ability = AbilityData.new()
	controller.change_state("IN_RANGE")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["USE_ABILITY"],
		"IN_RANGE with ability ready should transition to USE_ABILITY"
	)


func test_in_range_no_ability_transitions_to_attack() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.mock_ability = null
	controller.change_state("IN_RANGE")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["ATTACK"],
		"IN_RANGE with no ability should transition to ATTACK"
	)


# --- ATTACK state tests ---


func test_attack_target_dead_transitions_to_acquire_target() -> void:
	var controller := _create_controller()
	autofree(controller)
	var target := _create_entity()
	target.combat_state.is_dead = true
	controller.target = target
	controller.change_state("ATTACK")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["ACQUIRE_TARGET"],
		"ATTACK with dead target should transition to ACQUIRE_TARGET"
	)


func test_attack_target_null_transitions_to_acquire_target() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.target = null
	controller.change_state("ATTACK")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["ACQUIRE_TARGET"],
		"ATTACK with null target should transition to ACQUIRE_TARGET"
	)


func test_attack_target_alive_transitions_to_in_range() -> void:
	var controller := _create_controller()
	autofree(controller)
	var entity := _create_entity()
	var target := _create_entity()
	controller.entity = entity
	controller.combat_state = entity.combat_state
	controller.target = target
	controller.change_state("ATTACK")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["IN_RANGE"],
		"ATTACK with alive target should transition to IN_RANGE"
	)


# --- USE_ABILITY state tests ---


func test_use_ability_transitions_to_attack() -> void:
	var controller := _create_controller()
	autofree(controller)
	var entity := _create_entity()
	var ability_comp := AbilityComponent.new()
	autofree(ability_comp)
	entity.ability_component = ability_comp
	var target := _create_entity()
	controller.entity = entity
	controller.target = target
	controller.mock_ability = AbilityData.new()
	controller.change_state("USE_ABILITY")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["ATTACK"],
		"USE_ABILITY with alive target should transition to ATTACK"
	)


func test_use_ability_target_dead_transitions_to_acquire_target() -> void:
	var controller := _create_controller()
	autofree(controller)
	var entity := _create_entity()
	var ability_comp := AbilityComponent.new()
	autofree(ability_comp)
	entity.ability_component = ability_comp
	var target := _create_entity()
	target.combat_state.is_dead = true
	controller.entity = entity
	controller.target = target
	controller.mock_ability = AbilityData.new()
	controller.change_state("USE_ABILITY")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["ACQUIRE_TARGET"],
		"USE_ABILITY with dead target should transition to ACQUIRE_TARGET"
	)


# --- BERSERK state tests ---


func test_berserk_timer_expired_transitions_to_acquire_target() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.combat_state = _create_combat_state()
	controller.combat_state.is_berserk = true
	controller.combat_state.berserk_timer = 1.0
	controller.change_state("BERSERK")
	controller.current_state.update(1.0)
	assert_eq(
		controller.current_state,
		controller.states["ACQUIRE_TARGET"],
		"BERSERK should transition to ACQUIRE_TARGET when timer expires"
	)
	assert_false(
		controller.combat_state.is_berserk, "is_berserk should be false after BERSERK expires"
	)


func test_berserk_timer_not_expired_stays_berserk() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.combat_state = _create_combat_state()
	controller.combat_state.is_berserk = true
	controller.combat_state.berserk_timer = 5.0
	controller.change_state("BERSERK")
	controller.current_state.update(1.0)
	assert_eq(
		controller.current_state,
		controller.states["BERSERK"],
		"BERSERK should stay BERSERK when timer has not expired"
	)
	assert_true(
		controller.combat_state.is_berserk, "is_berserk should remain true while BERSERK is active"
	)


# --- DEAD state tests ---


func test_dead_is_terminal() -> void:
	var controller := _create_controller()
	autofree(controller)
	controller.change_state("DEAD")
	controller.current_state.update(0.016)
	assert_eq(
		controller.current_state,
		controller.states["DEAD"],
		"DEAD state should be terminal (no transitions)"
	)
