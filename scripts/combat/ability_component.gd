class_name AbilityComponent
extends Node

## Manages ability cooldowns and execution for a chimera entity.
## This is an interface stub — full implementation in TRACK-007.
## (FR-2: AbilityComponent interface stub, TDD Section 8)
##
## Method signatures match spec.md / TDD Section 8:
## - initialize(abilities: Array[AbilityData]) -> void
## - is_off_cooldown(ability: AbilityData) -> bool
## - get_ready_abilities() -> Array[AbilityData]
## - get_next_ready_ability(priority: Array) -> AbilityData
## - execute_ability(ability_id: String) -> void
## - apply_passives(combat_state: CombatState) -> void
## - update_cooldowns(delta: float) -> void


func initialize(_abilities: Array[AbilityData]) -> void:
	pass


func is_off_cooldown(_ability: AbilityData) -> bool:
	return false


func get_ready_abilities() -> Array[AbilityData]:
	return []


## Returns the first off-cooldown ability matching the given priority order.
## Stub — returns null. Full implementation in TRACK-007.
## (FR-9: AbilityComponent stub interface adjustment)
func get_next_ready_ability(_priority: Array) -> AbilityData:
	return null


func execute_ability(_ability_id: String) -> void:
	pass


func apply_passives(_combat_state: CombatState) -> void:
	pass


func update_cooldowns(_delta: float) -> void:
	pass
