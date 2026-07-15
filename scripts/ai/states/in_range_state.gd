class_name InRangeState
extends AIState

## IN_RANGE state — checks ability cooldowns, decides to attack or use ability.
## If ability ready → USE_ABILITY, else → ATTACK. (FR-4: State Flow)


func update(_delta: float) -> void:
	var ability: AbilityData = ai_controller.get_next_ready_ability()
	if ability != null:
		ai_controller.change_state("USE_ABILITY")
	else:
		ai_controller.change_state("ATTACK")
