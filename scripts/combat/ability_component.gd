class_name AbilityComponent
extends Node

## Manages ability cooldowns and execution for a chimera entity.
## Initialized from CombatState at combat start; tracks cooldowns per ability.
##
## Phase 1 (TRACK-007): initialization, cooldown tracking, ready-ability querying.
## Phase 3 will add target resolution and effect execution via AbilitySystem.
## Phase 4 will add passive ability application.

## All abilities available to this entity (part abilities + combo).
var abilities: Array[AbilityData] = []

## Cooldown timers keyed by ability ID. 0.0 means ready.
var cooldowns: Dictionary = {}

## ID of the currently executing ability (for ActiveEffect source tracking).
var current_ability_id: String = ""


## Initializes abilities from the combat state's chimera data.
## Collects part abilities + combo ability, initializes cooldowns, applies passives.
func initialize(combat_state: CombatState) -> void:
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


## Executes an ability: sets current_ability_id, starts cooldown.
## Target resolution and effect execution are added in Phase 3.
func execute_ability(ability: AbilityData, _primary_target: ChimeraEntity) -> void:
	current_ability_id = ability.id
	cooldowns[ability.id] = ability.cooldown
	# Phase 3: resolve targets and call AbilitySystem.execute_effect()


## Applies passive abilities at combat start.
## Full implementation in Phase 4.
func apply_passives(_combat_state: CombatState) -> void:
	pass


## Decrements all cooldown values by delta, floored at 0.0.
func update_cooldowns(delta: float) -> void:
	for ability_id in cooldowns:
		cooldowns[ability_id] = maxf(cooldowns[ability_id] - delta, 0.0)
