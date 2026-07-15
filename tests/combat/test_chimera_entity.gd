extends GutTest

## Tests for ChimeraEntity combat state and effect ticking.
## (FR-2: Chimera entity scene)


func test_combat_state_can_be_set_and_get():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	var state := CombatState.new()
	entity.combat_state = state
	assert_eq(entity.combat_state, state)


func test_process_ticks_effect_component():
	var entity := ChimeraEntity.new()
	var effect_comp := EffectComponent.new()
	effect_comp.name = "EffectComponent"
	entity.add_child(effect_comp)
	add_child_autofree(entity)
	var effect := ActiveEffect.new()
	effect.duration = 2.0
	effect_comp.add_effect(effect)
	entity._process(1.0)
	assert_eq(effect.duration, 1.0, "Effect duration should decrease by delta")


func test_process_without_effect_component_does_not_error():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	entity._process(0.016)
	assert_true(is_instance_valid(entity), "_process should not crash without EffectComponent")


func test_move_toward_target_sets_velocity_horizontal():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	entity.global_position = Vector2(0, 0)
	var state := CombatState.new()
	state.speed = 100.0
	entity.combat_state = state
	entity.move_toward_target(Vector2(100, 0))
	# direction = (1, 0), velocity = (1, 0) * 100 = (100, 0)
	# NOT multiplied by delta — move_and_slide applies delta internally
	assert_eq(entity.velocity, Vector2(100, 0))


func test_move_toward_target_sets_velocity_diagonal():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	entity.global_position = Vector2(0, 0)
	var state := CombatState.new()
	state.speed = 200.0
	entity.combat_state = state
	entity.move_toward_target(Vector2(100, 100))
	# direction = (1, 1).normalized() ≈ (0.707, 0.707)
	# velocity = (0.707, 0.707) * 200 ≈ (141.42, 141.42)
	assert_almost_eq(entity.velocity.x, 141.42, 0.1)
	assert_almost_eq(entity.velocity.y, 141.42, 0.1)
