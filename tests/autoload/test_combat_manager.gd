# gdlint:ignore=max-public-methods
extends GutTest

## Tests for CombatManager autoload (TRACK-008).
##
## Verifies properties, entity container resolution,
## and basic _process behavior.

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


func test_process_does_not_crash_when_inactive() -> void:
	CombatManager.match_active = false
	CombatManager._process(0.016)
	assert_false(CombatManager.match_active, "Should remain inactive after _process")


func test_process_does_not_crash_when_active() -> void:
	CombatManager.match_active = true
	CombatManager._process(0.016)
	assert_true(CombatManager.match_active, "Should remain active after _process")
	CombatManager.match_active = false


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


# --- Cleanup ---


func after_each() -> void:
	# Free any temp entities containers created during tests
	for child in CombatManager.get_children():
		CombatManager.remove_child(child)
		child.free()
