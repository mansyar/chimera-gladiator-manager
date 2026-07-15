extends GutTest

## Tests for AI positioning behavior (FR-5: Positioning Behavior, TDD Section 7).
## Verifies get_move_position() for FRONT/MID/BACK modes, melee/ranged distinction,
## and has_front_line_allies() helper.

# gdlint:ignore=max-public-methods

const MELEE_RANGE: float = 32.0
const RANGED_RANGE: float = 100.0

# --- FRONT positioning tests ---


func test_front_melee_returns_target_position() -> void:
	var controller := _create_ai_entity(Vector2(0, 0), MELEE_RANGE, GameEnums.Positioning.FRONT)
	var target := _create_target_at(Vector2(200, 0))
	var pos := controller.get_move_position(target)
	assert_eq(pos, Vector2(200, 0), "FRONT melee should close distance to target")


func test_front_ranged_kites_when_too_close() -> void:
	var controller := _create_ai_entity(Vector2(50, 0), RANGED_RANGE, GameEnums.Positioning.FRONT)
	var target := _create_target_at(Vector2(100, 0))
	var pos := controller.get_move_position(target)
	# distance=50 < attack_range*0.8=80 -> kite away
	# target.pos + (entity.pos - target.pos).normalized() * attack_range
	# = (100,0) + (-1,0) * 100 = (0, 0)
	assert_eq(pos, Vector2(0, 0), "FRONT ranged should kite away when too close")


func test_front_ranged_approaches_when_safe_distance() -> void:
	var controller := _create_ai_entity(Vector2(0, 0), RANGED_RANGE, GameEnums.Positioning.FRONT)
	var target := _create_target_at(Vector2(100, 0))
	var pos := controller.get_move_position(target)
	# distance=100 >= attack_range*0.8=80 -> approach
	assert_eq(pos, Vector2(100, 0), "FRONT ranged should approach when at safe distance")


# --- MID positioning tests ---


func test_mid_ranged_holds_at_range() -> void:
	var controller := _create_ai_entity(Vector2(0, 0), RANGED_RANGE, GameEnums.Positioning.MID)
	var target := _create_target_at(Vector2(200, 0))
	var pos := controller.get_move_position(target)
	# target.pos + (entity.pos - target.pos).normalized() * attack_range * 0.9
	# = (200,0) + (-1,0) * 90 = (110, 0)
	assert_eq(pos, Vector2(110, 0), "MID ranged should hold at 90% of attack range")


func test_mid_melee_approaches() -> void:
	var controller := _create_ai_entity(Vector2(0, 0), MELEE_RANGE, GameEnums.Positioning.MID)
	var target := _create_target_at(Vector2(200, 0))
	var pos := controller.get_move_position(target)
	assert_eq(pos, Vector2(200, 0), "MID melee should approach target")


# --- BACK positioning tests ---


func test_back_ranged_flees_when_approached() -> void:
	var controller := _create_ai_entity(Vector2(100, 0), RANGED_RANGE, GameEnums.Positioning.BACK)
	var target := _create_target_at(Vector2(150, 0))
	var pos := controller.get_move_position(target)
	# distance=50 < attack_range*0.7=70 -> flee
	# entity.pos + (entity.pos - target.pos).normalized() * 100
	# = (100,0) + (-1,0) * 100 = (0, 0)
	assert_eq(pos, Vector2(0, 0), "BACK ranged should flee when enemy approaches")


func test_back_ranged_holds_when_safe() -> void:
	var controller := _create_ai_entity(Vector2(0, 0), RANGED_RANGE, GameEnums.Positioning.BACK)
	var target := _create_target_at(Vector2(200, 0))
	var pos := controller.get_move_position(target)
	# distance=200 >= attack_range*0.7=70 -> hold
	assert_eq(pos, Vector2(0, 0), "BACK ranged should hold when enemy is far")


func test_back_melee_holds_with_front_line_allies() -> void:
	var context := CombatContext.new()
	var controller := _create_ai_entity(
		Vector2(0, 0), MELEE_RANGE, GameEnums.Positioning.BACK, 1, context
	)
	_create_ai_entity(Vector2(50, 50), MELEE_RANGE, GameEnums.Positioning.FRONT, 1, context)
	var target := _create_target_at(Vector2(200, 0))
	var pos := controller.get_move_position(target)
	assert_eq(pos, Vector2(0, 0), "BACK melee should hold when front-line allies exist")


func test_back_melee_approaches_without_front_line_allies() -> void:
	var context := CombatContext.new()
	var controller := _create_ai_entity(
		Vector2(0, 0), MELEE_RANGE, GameEnums.Positioning.BACK, 1, context
	)
	var target := _create_target_at(Vector2(200, 0))
	var pos := controller.get_move_position(target)
	assert_eq(pos, Vector2(200, 0), "BACK melee should approach without front-line allies")


# --- has_front_line_allies() tests ---


func test_has_front_line_allies_true() -> void:
	var context := CombatContext.new()
	var controller := _create_ai_entity(
		Vector2(0, 0), MELEE_RANGE, GameEnums.Positioning.BACK, 1, context
	)
	_create_ai_entity(Vector2(50, 50), MELEE_RANGE, GameEnums.Positioning.FRONT, 1, context)
	assert_true(controller.has_front_line_allies(), "Should detect front-line ally")


func test_has_front_line_allies_false_no_allies() -> void:
	var context := CombatContext.new()
	var controller := _create_ai_entity(
		Vector2(0, 0), MELEE_RANGE, GameEnums.Positioning.BACK, 1, context
	)
	assert_false(controller.has_front_line_allies(), "Should return false with no allies")


func test_has_front_line_allies_false_no_front_allies() -> void:
	var context := CombatContext.new()
	var controller := _create_ai_entity(
		Vector2(0, 0), MELEE_RANGE, GameEnums.Positioning.BACK, 1, context
	)
	_create_ai_entity(Vector2(50, 50), MELEE_RANGE, GameEnums.Positioning.MID, 1, context)
	assert_false(
		controller.has_front_line_allies(), "Should return false when ally is MID not FRONT"
	)


func test_has_front_line_allies_false_null_context() -> void:
	var controller := _create_ai_entity(Vector2(0, 0), MELEE_RANGE, GameEnums.Positioning.BACK)
	assert_false(controller.has_front_line_allies(), "Should return false when context is null")


# --- Helpers ---


func _create_ai_entity(
	pos: Vector2,
	attack_range: float,
	positioning: GameEnums.Positioning,
	team_id: int = 0,
	context: CombatContext = null
) -> AIController:
	var entity: ChimeraEntity = ChimeraEntity.new()
	entity.global_position = pos
	var cs: CombatState = CombatState.new()
	cs.attack_range = attack_range
	cs.team = team_id
	entity.combat_state = cs
	entity.team = team_id
	var controller: AIController = AIController.new()
	controller.name = "AIController"
	entity.add_child(controller)
	var module: BehaviorModuleData = BehaviorModuleData.new()
	module.positioning = positioning
	controller.setup_ai(module, cs, context)
	add_child_autofree(entity)
	if context:
		context.register_entity(entity)
	return controller


func _create_target_at(pos: Vector2) -> ChimeraEntity:
	var target: ChimeraEntity = ChimeraEntity.new()
	add_child_autofree(target)
	target.global_position = pos
	return target
