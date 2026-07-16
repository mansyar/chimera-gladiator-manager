class_name UseAbilityState
extends AIState

## USE_ABILITY state — executes highest-priority off-cooldown ability.
## Delegates to AbilityComponent, then transitions based on target status.
## If target dead/gone → ACQUIRE_TARGET, if alive → ATTACK. (FR-4: State Flow)


func update(_delta: float) -> void:
	var target: ChimeraEntity = ai_controller.target
	var ability: AbilityData = ai_controller.get_next_ready_ability()
	if ability != null and ai_controller.entity.ability_component:
		ai_controller.entity.ability_component.execute_ability(ability, target)
	if target == null or target.combat_state.is_dead:
		ai_controller.change_state("ACQUIRE_TARGET")
	else:
		ai_controller.change_state("ATTACK")
