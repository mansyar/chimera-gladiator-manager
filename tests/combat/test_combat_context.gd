extends GutTest

## Tests for CombatContext entity registry (FR-10: CombatContext).
## Verifies register/unregister and enemy/ally filtering by team and dead status.


func _create_entity(team_id: int, dead: bool = false) -> ChimeraEntity:
	var entity := ChimeraEntity.new()
	entity.combat_state = CombatState.new()
	entity.combat_state.team = team_id
	entity.combat_state.is_dead = dead
	autofree(entity)
	return entity


func test_register_entity_adds_to_list() -> void:
	var context := CombatContext.new()
	var entity := _create_entity(0)
	context.register_entity(entity)
	assert_eq(context.entities.size(), 1, "Entity should be registered")


func test_register_entity_no_duplicates() -> void:
	var context := CombatContext.new()
	var entity := _create_entity(0)
	context.register_entity(entity)
	context.register_entity(entity)
	assert_eq(context.entities.size(), 1, "Duplicate registration should be ignored")


func test_unregister_entity_removes_from_list() -> void:
	var context := CombatContext.new()
	var entity := _create_entity(0)
	context.register_entity(entity)
	context.unregister_entity(entity)
	assert_eq(context.entities.size(), 0, "Entity should be unregistered")


func test_unregister_nonexistent_entity_no_error() -> void:
	var context := CombatContext.new()
	var entity := _create_entity(0)
	context.unregister_entity(entity)
	assert_eq(context.entities.size(), 0, "Unregistering nonexistent entity should not error")


func test_get_enemies_of_filters_by_team() -> void:
	var context := CombatContext.new()
	var ally := _create_entity(0)
	var enemy := _create_entity(1)
	context.register_entity(ally)
	context.register_entity(enemy)
	var enemies := context.get_enemies_of(0)
	assert_eq(enemies.size(), 1, "Should find 1 enemy")
	assert_eq(enemies[0], enemy, "Should be the enemy entity")


func test_get_enemies_of_excludes_dead() -> void:
	var context := CombatContext.new()
	var ally := _create_entity(0)
	var dead_enemy := _create_entity(1, true)
	var alive_enemy := _create_entity(1, false)
	context.register_entity(ally)
	context.register_entity(dead_enemy)
	context.register_entity(alive_enemy)
	var enemies := context.get_enemies_of(0)
	assert_eq(enemies.size(), 1, "Should exclude dead enemies")
	assert_eq(enemies[0], alive_enemy, "Should be the alive enemy")


func test_get_allies_of_filters_by_team() -> void:
	var context := CombatContext.new()
	var ally1 := _create_entity(0)
	var ally2 := _create_entity(0)
	var enemy := _create_entity(1)
	context.register_entity(ally1)
	context.register_entity(ally2)
	context.register_entity(enemy)
	var allies := context.get_allies_of(0)
	assert_eq(allies.size(), 2, "Should find 2 allies")


func test_get_allies_of_excludes_dead() -> void:
	var context := CombatContext.new()
	var alive_ally := _create_entity(0, false)
	var dead_ally := _create_entity(0, true)
	var enemy := _create_entity(1)
	context.register_entity(alive_ally)
	context.register_entity(dead_ally)
	context.register_entity(enemy)
	var allies := context.get_allies_of(0)
	assert_eq(allies.size(), 1, "Should exclude dead allies")
	assert_eq(allies[0], alive_ally, "Should be the alive ally")


func test_get_enemies_of_empty_context() -> void:
	var context := CombatContext.new()
	var enemies := context.get_enemies_of(0)
	assert_eq(enemies.size(), 0, "Empty context should return no enemies")


func test_get_allies_of_empty_context() -> void:
	var context := CombatContext.new()
	var allies := context.get_allies_of(0)
	assert_eq(allies.size(), 0, "Empty context should return no allies")
