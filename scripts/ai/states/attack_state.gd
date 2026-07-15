class_name AttackState
extends AIState

## ATTACK state — executes auto-attack via ChimeraEntity, resets attack timer.
## If target dead/gone → ACQUIRE_TARGET, if alive → IN_RANGE. (FR-4: State Flow)


func update(_delta: float) -> void:
	var target: ChimeraEntity = ai_controller.target
	if target == null or target.combat_state.is_dead:
		ai_controller.change_state("ACQUIRE_TARGET")
		return
	if ai_controller.entity.can_attack():
		var damage: float = ChimeraEntity.calculate_damage(ai_controller.entity, target)
		target.combat_state.take_damage(damage)
		ai_controller.entity.reset_attack_timer()
	ai_controller.change_state("IN_RANGE")
