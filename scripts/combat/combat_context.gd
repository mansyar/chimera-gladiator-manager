class_name CombatContext
extends RefCounted

## Entity registry for combat. Tracks all ChimeraEntity instances in a match.
## Provides filtered queries for enemies and allies by team.
## (FR-10: CombatContext, TDD Section 7)
##
## TRACK-008's CombatManager will hold and populate this context.

## All registered combat entities in this match.
var entities: Array[ChimeraEntity] = []


## Registers a combat entity in this context. Ignores duplicates.
func register_entity(entity: ChimeraEntity) -> void:
	if not entities.has(entity):
		entities.append(entity)


## Removes a combat entity from this context. No-op if not registered.
func unregister_entity(entity: ChimeraEntity) -> void:
	entities.erase(entity)


## Returns all entities on a different team that are not dead.
func get_enemies_of(team: int) -> Array[ChimeraEntity]:
	var enemies: Array[ChimeraEntity] = []
	for entity in entities:
		if entity.combat_state.team != team and not entity.combat_state.is_dead:
			enemies.append(entity)
	return enemies


## Returns all entities on the same team that are not dead.
func get_allies_of(team: int) -> Array[ChimeraEntity]:
	var allies: Array[ChimeraEntity] = []
	for entity in entities:
		if entity.combat_state.team == team and not entity.combat_state.is_dead:
			allies.append(entity)
	return allies
