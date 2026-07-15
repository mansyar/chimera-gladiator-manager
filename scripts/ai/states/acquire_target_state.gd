class_name AcquireTargetState
extends AIState

## ACQUIRE_TARGET state — finds a target via the behavior module's targeting mode.
## If target found → MOVE_TO_TARGET, if null → IDLE. (FR-4: State Flow)


func update(_delta: float) -> void:
	var new_target: ChimeraEntity = ai_controller.acquire_target()
	if new_target != null:
		ai_controller.target = new_target
		ai_controller.change_state("MOVE_TO_TARGET")
	else:
		ai_controller.change_state("IDLE")
