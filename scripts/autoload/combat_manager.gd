## Combat match manager.
##
## Creates and manages transient CombatState instances for each match.
## Handles combat lifecycle: setup, execution, resolution.
extends Node

const _ENTITY_SCENE: PackedScene = preload("res://scenes/combat/chimera_entity.tscn")

## Whether a combat match is currently active.
## When false, _process returns early (no combat simulation).
var match_active: bool = false

## Countdown timer for the current match (starts at 60.0 seconds).
var timer: float = 0.0

## All ChimeraEntity instances spawned for the current match.
var combat_entities: Array[ChimeraEntity] = []

## Combat context tracking entities for the current match.
var combat_context: CombatContext = null

## Player formation grid positions for the current match.
var player_formation: Array = []

## Enemy formation grid positions for the current match.
var enemy_formation: Array = []

## Result dictionary populated when a match ends.
var match_result: Dictionary = {}

## Type of the current match ("regular" or "tournament").
var match_type: String = ""

## Tournament tier for the current match (1-4, 0 for regular).
var tournament_tier: int = 0


func _process(delta: float) -> void:
	if not match_active:
		return
	timer -= delta
	check_win_condition()
	if timer <= 0.0:
		timer = 0.0
		_on_timer_expired()


## Checks win conditions every frame and on entity death.
## Ends match when all entities on one team are dead.
## (FR-2: Win Condition Evaluation)
func check_win_condition() -> void:
	if not match_active:
		return
	var player_alive := _count_alive(0)
	var enemy_alive := _count_alive(1)
	if player_alive == 0 and enemy_alive == 0:
		# Both teams wiped simultaneously — player wins ties
		end_match(_build_result(0, 0.0))
	elif player_alive == 0:
		end_match(_build_result(1, _calc_team_hp_percent(1)))
	elif enemy_alive == 0:
		end_match(_build_result(0, _calc_team_hp_percent(0)))


## Counts alive entities on the given team.
func _count_alive(team: int) -> int:
	var count := 0
	for entity in combat_entities:
		if entity.combat_state.team == team and not entity.combat_state.is_dead:
			count += 1
	return count


## Calculates total HP percentage for a team across all its entities.
func _calc_team_hp_percent(team: int) -> float:
	var total_hp := 0.0
	var total_max_hp := 0.0
	for entity in combat_entities:
		if entity.combat_state.team == team:
			total_hp += entity.combat_state.current_hp
			total_max_hp += entity.combat_state.max_hp
	if total_max_hp <= 0.0:
		return 0.0
	return (total_hp / total_max_hp) * 100.0


## Builds the match result dictionary.
## Rewards (gold_earned, infamy_earned) are 0 here — populated in Phase 3.
func _build_result(winner: int, surviving_hp: float) -> Dictionary:
	return {
		"winner": winner,
		"won": winner == 0,
		"surviving_hp": surviving_hp,
		"duration": 60.0 - timer,
		"gold_earned": 0,
		"infamy_earned": 0,
	}


## Ends the current match, stores the result, and clears match-active flag.
## Full cleanup (clearing arrays, freeing entities, emitting signal) in Task 6.
## (FR-1: end_match)
func end_match(result: Dictionary) -> void:
	match_active = false
	match_result = result


## Handles timer expiry — determines winner by total HP%.
## Full implementation in a later task.
func _on_timer_expired() -> void:
	pass


## Find the arena's Entities node via the 'arena_entities' scene tree group.
## If no arena scene is loaded (test mode), creates a temporary Node2D container.
func _find_or_create_entities_container() -> Node2D:
	var nodes := get_tree().get_nodes_in_group("arena_entities")
	if not nodes.is_empty():
		return nodes[0] as Node2D
	# No arena scene loaded (test mode) — create a temporary container
	var container := Node2D.new()
	container.name = "TempEntities"
	add_child(container)
	return container


## Starts a new combat match. Spawns entities from both rosters, initializes
## their combat state, places them on the formation grid, and begins the timer.
## (FR-1: CombatManager Match Lifecycle)
func start_match(
	player_roster: Array[ChimeraData],
	enemy_roster: Array[ChimeraData],
	formations: Array,
	match_type: String,
	tournament_tier: int
) -> void:
	self.match_type = match_type
	self.tournament_tier = tournament_tier
	combat_context = CombatContext.new()
	var container: Node2D = _find_or_create_entities_container()
	# Spawn player entities (team 0)
	var player_positions: Array = formations[0]
	for i in range(player_roster.size()):
		_spawn_entity(player_roster[i], 0, player_positions[i], container)
	# Spawn enemy entities (team 1)
	var enemy_positions: Array = formations[1]
	for i in range(enemy_roster.size()):
		_spawn_entity(enemy_roster[i], 1, enemy_positions[i], container)
	player_formation = player_positions.duplicate()
	enemy_formation = enemy_positions.duplicate()
	match_active = true
	timer = 60.0
	EventBus.match_started.emit(player_roster, enemy_roster)


## Spawns a single ChimeraEntity, initializes its combat state, places it
## on the formation grid, registers it in CombatContext, and connects signals.
func _spawn_entity(
	chimera_data: ChimeraData, team_id: int, grid_pos: Vector2i, container: Node2D
) -> void:
	var entity: ChimeraEntity = _ENTITY_SCENE.instantiate()
	container.add_child(entity)
	entity.combat_state = CombatState.new()
	entity.combat_state.initialize(chimera_data, team_id)
	entity.team = team_id
	entity.combat_context = combat_context
	if entity.ability_component:
		entity.ability_component.initialize(entity.combat_state)
	var is_player: bool = team_id == 0
	entity.position = ArenaController.grid_to_world(grid_pos.x, grid_pos.y, is_player)
	combat_context.register_entity(entity)
	entity.died.connect(_on_entity_died)
	combat_entities.append(entity)


## Handles entity death. Unregisters from context and checks win condition.
## (FR-3: Entity Death Handling — full implementation in a later task)
func _on_entity_died(_entity: ChimeraEntity) -> void:
	pass
