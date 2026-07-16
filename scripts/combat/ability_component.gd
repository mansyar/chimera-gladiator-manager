class_name AbilityComponent
extends Node

## Manages ability cooldowns and execution for a chimera entity.
## Initialized from CombatState at combat start; tracks cooldowns per ability.
##
## Phase 1 (TRACK-007): initialization, cooldown tracking, ready-ability querying.
## Phase 3 (TRACK-007): target resolution and effect execution via AbilitySystem.
## Phase 4 will add passive ability application.

## All abilities available to this entity (part abilities + combo).
var abilities: Array[AbilityData] = []

## Cooldown timers keyed by ability ID. 0.0 means ready.
var cooldowns: Dictionary = {}

## ID of the currently executing ability (for ActiveEffect source tracking).
var current_ability_id: String = ""

## Reference to the parent ChimeraEntity (for combat_context, team, position).
var entity: ChimeraEntity = null


## Initializes abilities from the combat state's chimera data.
## Collects part abilities + combo ability, initializes cooldowns, applies passives.
func initialize(combat_state: CombatState) -> void:
	entity = get_parent() as ChimeraEntity
	var chimera_data: ChimeraData = combat_state.chimera_data
	abilities.clear()
	cooldowns.clear()
	# Collect part abilities
	for ability in chimera_data.part_abilities:
		abilities.append(ability)
	# Collect combo ability via get_combo_ability() (returns null if <2 same-strain)
	var combo: AbilityData = chimera_data.get_combo_ability()
	if combo != null:
		abilities.append(combo)
	# Initialize cooldowns for all abilities
	for ability in abilities:
		cooldowns[ability.id] = 0.0
	# Apply passive abilities (full implementation in Phase 4)
	apply_passives(combat_state)


## Returns true if the ability's cooldown has expired.
func is_off_cooldown(ability: AbilityData) -> bool:
	return cooldowns.get(ability.id, 0.0) <= 0.0


## Returns all ACTIVE abilities (not PASSIVE) that are off cooldown.
func get_ready_abilities() -> Array[AbilityData]:
	var ready: Array[AbilityData] = []
	for ability in abilities:
		if ability.type != GameEnums.AbilityType.PASSIVE and is_off_cooldown(ability):
			ready.append(ability)
	return ready


## Executes an ability: sets current_ability_id, starts cooldown, resolves targets,
## and calls AbilitySystem.execute_effect() for each effect.
func execute_ability(ability: AbilityData, primary_target: ChimeraEntity) -> void:
	current_ability_id = ability.id
	cooldowns[ability.id] = ability.cooldown
	if entity == null:
		return
	var targets := _resolve_targets(ability.targeting, primary_target, ability.range)
	for effect in ability.effects:
		AbilitySystem.execute_effect(effect, entity, targets, ability.effects)


## Resolves targets based on the ability's targeting pattern.
## Uses combat_context for AOE expansion and range filtering.
func _resolve_targets(
	targeting: String, primary_target: ChimeraEntity, ability_range: float
) -> Array[ChimeraEntity]:
	var targets: Array[ChimeraEntity] = []
	match targeting:
		"SELF":
			targets = [entity]
		"TARGET":
			if primary_target != null:
				targets = [primary_target]
		"AOE_ENEMIES":
			if entity.combat_context != null:
				var enemies := entity.combat_context.get_enemies_of(entity.combat_state.team)
				targets = _filter_by_range(enemies, primary_target, ability_range)
		"AOE_ALLIES":
			if entity.combat_context != null:
				var allies := entity.combat_context.get_allies_of(entity.combat_state.team)
				targets = _filter_by_range(allies, primary_target, ability_range)
		"ALL_ENEMIES":
			if entity.combat_context != null:
				targets = entity.combat_context.get_enemies_of(entity.combat_state.team)
	return targets


## Filters entities to those within ability_range of the primary_target.
func _filter_by_range(
	entities: Array[ChimeraEntity], primary_target: ChimeraEntity, ability_range: float
) -> Array[ChimeraEntity]:
	var in_range: Array[ChimeraEntity] = []
	for e in entities:
		if primary_target.global_position.distance_to(e.global_position) <= ability_range:
			in_range.append(e)
	return in_range


## Applies passive abilities at combat start.
## Full implementation in Phase 4.
func apply_passives(_combat_state: CombatState) -> void:
	pass


## Decrements all cooldown values by delta, floored at 0.0.
func update_cooldowns(delta: float) -> void:
	for ability_id in cooldowns:
		cooldowns[ability_id] = maxf(cooldowns[ability_id] - delta, 0.0)
