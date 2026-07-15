class_name BerserkState
extends AIState

## BERSERK state — override state that ignores module, targets nearest entity.
## Lasts BERSERK_DURATION seconds, then transitions to ACQUIRE_TARGET.
## (FR-4: State Flow, FR-8: Berserk System)


func update(delta: float) -> void:
	ai_controller.combat_state.berserk_timer -= delta
	if ai_controller.combat_state.berserk_timer <= 0.0:
		ai_controller.combat_state.is_berserk = false
		ai_controller.change_state("ACQUIRE_TARGET")
