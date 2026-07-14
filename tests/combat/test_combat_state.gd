extends GutTest

## Tests for CombatState (FR-7).
## Verifies stat snapshotting, damage, and healing.


func _make_chimera(
	max_hp: float = 100.0, atk: float = 10.0, def: float = 5.0, spd: float = 20.0
) -> ChimeraData:
	var data := ChimeraData.new()
	data.max_hp = max_hp
	data.attack = atk
	data.defense = def
	data.speed = spd
	return data


func test_initialize_snapshots_stats() -> void:
	var data := _make_chimera(150.0, 15.0, 8.0, 25.0)
	var state := CombatState.new()
	state.initialize(data, 0)
	assert_eq(state.max_hp, 150.0, "max_hp should snapshot from ChimeraData")
	assert_eq(state.attack, 15.0, "attack should snapshot from ChimeraData")
	assert_eq(state.defense, 8.0, "defense should snapshot from ChimeraData")
	assert_eq(state.speed, 25.0, "speed should snapshot from ChimeraData")


func test_initialize_sets_current_hp_to_max() -> void:
	var data := _make_chimera(100.0)
	var state := CombatState.new()
	state.initialize(data, 0)
	assert_eq(state.current_hp, 100.0, "current_hp should equal max_hp after initialize")


func test_initialize_sets_team() -> void:
	var data := _make_chimera()
	var state := CombatState.new()
	state.initialize(data, 2)
	assert_eq(state.team, 2, "team should be set from team_id")


func test_take_damage_reduces_hp() -> void:
	var data := _make_chimera(100.0)
	var state := CombatState.new()
	state.initialize(data, 0)
	state.take_damage(30.0)
	assert_eq(state.current_hp, 70.0, "current_hp should be reduced by damage")


func test_take_damage_sets_dead_at_zero() -> void:
	var data := _make_chimera(50.0)
	var state := CombatState.new()
	state.initialize(data, 0)
	state.take_damage(50.0)
	assert_eq(state.current_hp, 0.0, "current_hp should be 0")
	assert_true(state.is_dead, "is_dead should be true when hp reaches 0")


func test_take_damage_does_not_go_below_zero() -> void:
	var data := _make_chimera(30.0)
	var state := CombatState.new()
	state.initialize(data, 0)
	state.take_damage(100.0)
	assert_eq(state.current_hp, 0.0, "current_hp should not go below 0")
	assert_true(state.is_dead, "is_dead should be true")


func test_heal_increases_hp() -> void:
	var data := _make_chimera(100.0)
	var state := CombatState.new()
	state.initialize(data, 0)
	state.take_damage(40.0)
	state.heal(20.0)
	assert_eq(state.current_hp, 80.0, "current_hp should be increased by heal amount")


func test_heal_caps_at_max_hp() -> void:
	var data := _make_chimera(100.0)
	var state := CombatState.new()
	state.initialize(data, 0)
	state.take_damage(10.0)
	state.heal(50.0)
	assert_eq(state.current_hp, 100.0, "current_hp should not exceed max_hp")
