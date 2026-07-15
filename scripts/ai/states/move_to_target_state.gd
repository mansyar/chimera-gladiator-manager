class_name MoveToTargetState
extends AIState

## MOVE_TO_TARGET state — moves toward/away from target via get_move_position().
## Transitions to IN_RANGE when within attack_range. (FR-4: State Flow)


func update(_delta: float) -> void:
	var target: ChimeraEntity = ai_controller.target
	if target == null:
		ai_controller.change_state("ACQUIRE_TARGET")
		return
	ai_controller.entity.move_toward_target(ai_controller.get_move_position(target))
	var distance: float = ai_controller.entity.global_position.distance_to(target.global_position)
	if distance <= ai_controller.combat_state.attack_range:
		ai_controller.change_state("IN_RANGE")
