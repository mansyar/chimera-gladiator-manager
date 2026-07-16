# gdlint:ignore=max-public-methods
extends GutTest

## Tests for CombatManager autoload (TRACK-008).
##
## Verifies properties, entity container resolution,
## _process behavior, and start_match lifecycle.

# --- Property default tests ---


func test_match_active_defaults_false() -> void:
	assert_false(CombatManager.match_active, "match_active should default to false")


func test_timer_defaults_zero() -> void:
	assert_eq(CombatManager.timer, 0.0, "timer should default to 0.0")


func test_combat_entities_defaults_empty() -> void:
	assert_eq(CombatManager.combat_entities, [], "combat_entities should default to empty")


func test_combat_context_defaults_null() -> void:
	assert_null(CombatManager.combat_context, "combat_context should default to null")


func test_player_formation_defaults_empty() -> void:
	assert_eq(CombatManager.player_formation, [], "player_formation should default to empty")


func test_enemy_formation_defaults_empty() -> void:
	assert_eq(CombatManager.enemy_formation, [], "enemy_formation should default to empty")


func test_match_result_defaults_empty() -> void:
	assert_eq(CombatManager.match_result, {}, "match_result should default to empty dict")


# --- _process tests ---


func test_process_idle_does_not_decrement_timer() -> void:
	CombatManager.match_active = false
	CombatManager.timer = 60.0
	CombatManager._process(0.5)
	assert_eq(CombatManager.timer, 60.0, "Timer should not change when match is inactive")


func test_process_active_decrements_timer() -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	var initial_timer: float = CombatManager.timer
	CombatManager._process(0.5)
	assert_eq(CombatManager.timer, initial_timer - 0.5, "Timer should decrement by delta")


func test_process_calls_check_win_condition() -> void:
	assert_true(
		CombatManager.has_method("check_win_condition"), "check_win_condition method should exist"
	)
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	CombatManager._process(0.016)
	assert_true(CombatManager.match_active, "Match should still be active (no win condition met)")


func test_process_triggers_on_timer_expired() -> void:
	assert_true(
		CombatManager.has_method("_on_timer_expired"), "_on_timer_expired method should exist"
	)
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	CombatManager.timer = 0.05
	CombatManager._process(0.1)
	assert_eq(CombatManager.timer, 0.0, "Timer should be clamped to 0.0 when expired")


# --- _find_or_create_entities_container tests ---


func test_find_or_create_creates_temp_when_no_arena() -> void:
	# In test mode, no arena scene is loaded — no arena_entities group node exists
	var container: Node2D = CombatManager._find_or_create_entities_container()
	assert_not_null(container, "Should create a container when none found")
	assert_true(container is Node2D, "Container should be a Node2D")


func test_find_or_create_finds_existing_group_node() -> void:
	var test_node := Node2D.new()
	test_node.add_to_group("arena_entities")
	autofree(test_node)
	add_child(test_node)

	var container: Node2D = CombatManager._find_or_create_entities_container()
	assert_eq(container, test_node, "Should find existing arena_entities node")


# --- start_match tests ---


func _setup_roster() -> Array[ChimeraData]:
	var starters := PartDatabase.get_starter_chimeras()
	var roster: Array[ChimeraData] = []
	for starter in starters:
		var dup := starter.duplicate()
		dup.calculate_instability()
		dup.recalculate_stats()
		roster.append(dup)
	return roster


func _setup_formations() -> Array:
	return [
		[Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2)],
		[Vector2i(0, 2), Vector2i(1, 1), Vector2i(2, 0)],
	]


func test_start_match_creates_six_entities() -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	assert_eq(CombatManager.combat_entities.size(), 6, "Should create 6 entities")
	var player_count := 0
	var enemy_count := 0
	for entity in CombatManager.combat_entities:
		if entity.team == 0:
			player_count += 1
		elif entity.team == 1:
			enemy_count += 1
	assert_eq(player_count, 3, "Should have 3 player entities (team 0)")
	assert_eq(enemy_count, 3, "Should have 3 enemy entities (team 1)")


func test_start_match_initializes_combat_state() -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	# Player entities (indices 0-2) should have team=0 and snapshotted stats
	for i in range(3):
		var entity: ChimeraEntity = CombatManager.combat_entities[i]
		assert_not_null(entity.combat_state, "Player entity %d should have CombatState" % i)
		assert_eq(entity.combat_state.team, 0, "Player entity %d should be team 0" % i)
		assert_not_null(
			entity.combat_state.chimera_data, "Player entity %d should have chimera_data set" % i
		)
		assert_eq(
			entity.combat_state.max_hp,
			player_roster[i].max_hp,
			"Player entity %d max_hp should match ChimeraData" % i
		)
		assert_eq(
			entity.combat_state.attack,
			player_roster[i].attack,
			"Player entity %d attack should match ChimeraData" % i
		)
		assert_gt(entity.combat_state.max_hp, 0.0, "Player entity %d max_hp should be > 0" % i)
	# Enemy entities (indices 3-5) should have team=1 and snapshotted stats
	for i in range(3, 6):
		var entity: ChimeraEntity = CombatManager.combat_entities[i]
		assert_eq(entity.combat_state.team, 1, "Enemy entity %d should be team 1" % i)
		assert_eq(
			entity.combat_state.max_hp,
			enemy_roster[i - 3].max_hp,
			"Enemy entity %d max_hp should match ChimeraData" % i
		)


func test_start_match_places_entities_at_grid_positions() -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	# Player entity 0 at Vector2i(0, 0) -> grid_to_world(0, 0, true)
	var expected_pos := ArenaController.grid_to_world(0, 0, true)
	assert_eq(
		CombatManager.combat_entities[0].position,
		expected_pos,
		"Player entity 0 should be at grid (row=0, col=0)"
	)
	# Player entity 1 at Vector2i(1, 1) -> grid_to_world(1, 1, true)
	expected_pos = ArenaController.grid_to_world(1, 1, true)
	assert_eq(
		CombatManager.combat_entities[1].position,
		expected_pos,
		"Player entity 1 should be at grid (row=1, col=1)"
	)
	# Enemy entity 0 at Vector2i(0, 2) -> grid_to_world(0, 2, false)
	expected_pos = ArenaController.grid_to_world(0, 2, false)
	assert_eq(
		CombatManager.combat_entities[3].position,
		expected_pos,
		"Enemy entity 0 should be at grid (row=0, col=2)"
	)


func test_start_match_registers_entities_in_context() -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	assert_not_null(CombatManager.combat_context, "CombatContext should be created")
	assert_eq(
		CombatManager.combat_context.entities.size(),
		6,
		"All 6 entities should be registered in CombatContext"
	)


func test_start_match_connects_died_signals() -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	for entity in CombatManager.combat_entities:
		assert_true(
			entity.died.is_connected(CombatManager._on_entity_died),
			"Each entity's died signal should be connected to _on_entity_died"
		)


func test_start_match_sets_active_and_timer() -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	assert_true(CombatManager.match_active, "match_active should be true after start_match")
	assert_eq(CombatManager.timer, 60.0, "timer should be set to 60.0")


func test_start_match_emits_match_started() -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	watch_signals(EventBus)
	CombatManager.start_match(player_roster, enemy_roster, formations, "regular", 1)
	assert_signal_emitted(EventBus, "match_started", "match_started signal should be emitted")


func test_start_match_stores_match_type_and_tier() -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, "tournament", 3)
	assert_eq(CombatManager.match_type, "tournament", "match_type should be stored")
	assert_eq(CombatManager.tournament_tier, 3, "tournament_tier should be stored")


# --- Cleanup ---


func after_each() -> void:
	# Reset CombatManager state
	CombatManager.match_active = false
	CombatManager.combat_entities.clear()
	CombatManager.combat_context = null
	CombatManager.player_formation.clear()
	CombatManager.enemy_formation.clear()
	CombatManager.timer = 0.0
	CombatManager.match_result = {}
	# Free any temp entities containers (frees child entities recursively)
	for child in CombatManager.get_children():
		CombatManager.remove_child(child)
		child.free()
