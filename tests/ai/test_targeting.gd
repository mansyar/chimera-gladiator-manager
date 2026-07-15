extends GutTest

## Tests for AI target selection (FR-6: Target Selection, TDD Section 7).
## Verifies 6 targeting functions and acquire_target() dispatch.

# gdlint:ignore=max-public-methods

# --- find_nearest tests ---


func test_find_nearest_returns_closest() -> void:
	var controller := _create_controller(Vector2(0, 0))
	var e1 := _create_enemy(Vector2(100, 0))
	var e2 := _create_enemy(Vector2(50, 0))
	var e3 := _create_enemy(Vector2(200, 0))
	var enemies: Array[ChimeraEntity] = [e1, e2, e3]
	var result := controller.find_nearest(enemies)
	assert_eq(result, e2, "Should return nearest enemy")


func test_find_nearest_empty_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0))
	var enemies: Array[ChimeraEntity] = []
	var result := controller.find_nearest(enemies)
	assert_eq(result, null, "Should return null for empty list")


# --- find_lowest_hp_in_range tests ---


func test_find_lowest_hp_in_range_returns_weakest() -> void:
	var controller := _create_controller(Vector2(0, 0))
	var e1 := _create_enemy(Vector2(30, 0), 80.0)
	var e2 := _create_enemy(Vector2(40, 0), 20.0)
	var e3 := _create_enemy(Vector2(50, 0), 60.0)
	var enemies: Array[ChimeraEntity] = [e1, e2, e3]
	var result := controller.find_lowest_hp_in_range(enemies, 100.0)
	assert_eq(result, e2, "Should return lowest HP enemy in range")


func test_find_lowest_hp_in_range_none_in_range_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0))
	var e1 := _create_enemy(Vector2(200, 0), 80.0)
	var enemies: Array[ChimeraEntity] = [e1]
	var result := controller.find_lowest_hp_in_range(enemies, 100.0)
	assert_eq(result, null, "Should return null when no enemies in range")


func test_find_lowest_hp_in_range_empty_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0))
	var enemies: Array[ChimeraEntity] = []
	var result := controller.find_lowest_hp_in_range(enemies, 100.0)
	assert_eq(result, null, "Should return null for empty list")


# --- find_highest_attack tests ---


func test_find_highest_attack_returns_strongest() -> void:
	var controller := _create_controller(Vector2(0, 0))
	var e1 := _create_enemy(Vector2(100, 0), 100.0, 15.0)
	var e2 := _create_enemy(Vector2(50, 0), 100.0, 30.0)
	var e3 := _create_enemy(Vector2(200, 0), 100.0, 10.0)
	var enemies: Array[ChimeraEntity] = [e1, e2, e3]
	var result := controller.find_highest_attack(enemies)
	assert_eq(result, e2, "Should return highest attack enemy")


func test_find_highest_attack_empty_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0))
	var enemies: Array[ChimeraEntity] = []
	var result := controller.find_highest_attack(enemies)
	assert_eq(result, null, "Should return null for empty list")


# --- find_highest_attack_targeting_ally tests ---


func test_find_highest_attack_targeting_ally_returns_strongest() -> void:
	var controller := _create_controller(Vector2(0, 0), 0)
	var ally := _create_enemy(Vector2(10, 0), 100.0, 5.0, 0)
	var e1 := _create_enemy_with_target(Vector2(100, 0), ally, 100.0, 15.0)
	var e2 := _create_enemy_with_target(Vector2(50, 0), ally, 100.0, 30.0)
	var e3 := _create_enemy(Vector2(200, 0), 100.0, 50.0)
	var enemies: Array[ChimeraEntity] = [e1, e2, e3]
	var result := controller.find_highest_attack_targeting_ally(enemies)
	assert_eq(result, e2, "Should return highest-attack enemy targeting an ally")


func test_find_highest_attack_targeting_ally_none_targeting_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0), 0)
	var e1 := _create_enemy(Vector2(100, 0), 100.0, 15.0)
	var e2 := _create_enemy(Vector2(50, 0), 100.0, 30.0)
	var enemies: Array[ChimeraEntity] = [e1, e2]
	var result := controller.find_highest_attack_targeting_ally(enemies)
	assert_eq(result, null, "Should return null when no enemy targets an ally")


func test_find_highest_attack_targeting_ally_empty_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0), 0)
	var enemies: Array[ChimeraEntity] = []
	var result := controller.find_highest_attack_targeting_ally(enemies)
	assert_eq(result, null, "Should return null for empty list")


# --- find_enemy_attacking_ally tests ---


func test_find_enemy_attacking_ally_returns_first_found() -> void:
	var controller := _create_controller(Vector2(0, 0), 0)
	var ally := _create_enemy(Vector2(10, 0), 100.0, 5.0, 0)
	var e1 := _create_enemy_with_target(Vector2(100, 0), ally)
	var e2 := _create_enemy(Vector2(50, 0))
	var enemies: Array[ChimeraEntity] = [e1, e2]
	var result := controller.find_enemy_attacking_ally(enemies)
	assert_eq(result, e1, "Should return enemy targeting an ally")


func test_find_enemy_attacking_ally_none_targeting_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0), 0)
	var e1 := _create_enemy(Vector2(100, 0))
	var e2 := _create_enemy(Vector2(50, 0))
	var enemies: Array[ChimeraEntity] = [e1, e2]
	var result := controller.find_enemy_attacking_ally(enemies)
	assert_eq(result, null, "Should return null when no enemy targets an ally")


func test_find_enemy_attacking_ally_empty_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0), 0)
	var enemies: Array[ChimeraEntity] = []
	var result := controller.find_enemy_attacking_ally(enemies)
	assert_eq(result, null, "Should return null for empty list")


# --- find_lowest_hp tests ---


func test_find_lowest_hp_returns_weakest_overall() -> void:
	var controller := _create_controller(Vector2(0, 0))
	var e1 := _create_enemy(Vector2(100, 0), 80.0)
	var e2 := _create_enemy(Vector2(50, 0), 20.0)
	var e3 := _create_enemy(Vector2(200, 0), 60.0)
	var enemies: Array[ChimeraEntity] = [e1, e2, e3]
	var result := controller.find_lowest_hp(enemies)
	assert_eq(result, e2, "Should return lowest HP enemy overall")


func test_find_lowest_hp_empty_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0))
	var enemies: Array[ChimeraEntity] = []
	var result := controller.find_lowest_hp(enemies)
	assert_eq(result, null, "Should return null for empty list")


# --- acquire_target dispatch tests ---


func test_acquire_target_nearest_dispatch() -> void:
	var controller := _create_controller(Vector2(0, 0), 0)
	controller.behavior_module.targeting = GameEnums.TargetingMode.NEAREST
	var e1 := _create_enemy(Vector2(100, 0))
	var e2 := _create_enemy(Vector2(50, 0))
	controller.combat_context.register_entity(e1)
	controller.combat_context.register_entity(e2)
	var result := controller.acquire_target()
	assert_eq(result, e2, "NEAREST mode should return nearest enemy")


func test_acquire_target_null_context_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0), 0)
	controller.combat_context = null
	var result := controller.acquire_target()
	assert_eq(result, null, "Should return null with null context")


func test_acquire_target_no_enemies_returns_null() -> void:
	var controller := _create_controller(Vector2(0, 0), 0)
	controller.behavior_module.targeting = GameEnums.TargetingMode.NEAREST
	var result := controller.acquire_target()
	assert_eq(result, null, "Should return null with no enemies")


# --- Helpers ---


func _create_controller(pos: Vector2, team_id: int = 0) -> AIController:
	var entity: ChimeraEntity = ChimeraEntity.new()
	entity.global_position = pos
	var cs: CombatState = CombatState.new()
	cs.team = team_id
	cs.attack_range = 100.0
	cs.max_hp = 100.0
	cs.current_hp = 100.0
	entity.combat_state = cs
	entity.team = team_id
	var controller: AIController = AIController.new()
	controller.name = "AIController"
	entity.add_child(controller)
	var module: BehaviorModuleData = BehaviorModuleData.new()
	var context: CombatContext = CombatContext.new()
	controller.setup_ai(module, cs, context)
	add_child_autofree(entity)
	context.register_entity(entity)
	return controller


func _create_enemy(
	pos: Vector2, hp: float = 100.0, atk: float = 10.0, team_id: int = 1
) -> ChimeraEntity:
	var enemy: ChimeraEntity = ChimeraEntity.new()
	add_child_autofree(enemy)
	enemy.global_position = pos
	var cs: CombatState = CombatState.new()
	cs.current_hp = hp
	cs.max_hp = 100.0
	cs.attack = atk
	cs.team = team_id
	enemy.combat_state = cs
	enemy.team = team_id
	return enemy


func _create_enemy_with_target(
	pos: Vector2, target: ChimeraEntity, hp: float = 100.0, atk: float = 10.0, team_id: int = 1
) -> ChimeraEntity:
	var enemy: ChimeraEntity = ChimeraEntity.new()
	enemy.global_position = pos
	var cs: CombatState = CombatState.new()
	cs.current_hp = hp
	cs.max_hp = 100.0
	cs.attack = atk
	cs.team = team_id
	enemy.combat_state = cs
	enemy.team = team_id
	var controller: AIController = AIController.new()
	controller.name = "AIController"
	controller.target = target
	enemy.add_child(controller)
	add_child_autofree(enemy)
	return enemy
