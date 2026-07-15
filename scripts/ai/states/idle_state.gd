class_name IdleState
extends AIState

## IDLE state — brief pause (1-2 frames) before acquiring a target.
## Transitions to ACQUIRE_TARGET after a short delay. (FR-4: State Flow)

var _frame_count: int = 0


func enter() -> void:
	_frame_count = 0


func update(_delta: float) -> void:
	_frame_count += 1
	if _frame_count >= 2:
		ai_controller.change_state("ACQUIRE_TARGET")
