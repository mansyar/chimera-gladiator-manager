class_name ChimeraEntity
extends CharacterBody2D

## Combat entity representing a chimera in the arena.
## Orchestrates components and ticks EffectComponent each frame.
## (FR-2: Chimera entity scene)

var combat_state: CombatState

@onready var effect_component: EffectComponent = get_node_or_null("EffectComponent")


func _process(delta: float) -> void:
	if effect_component:
		effect_component.tick(delta)


## Moves toward [param target_position] at [member CombatState.speed].
## Sets [member velocity] to direction * speed (NO delta multiplication —
## [method move_and_slide] applies delta internally).
## (FR-4: Movement)
func move_toward_target(target_position: Vector2) -> void:
	var direction: Vector2 = (target_position - global_position).normalized()
	velocity = direction * combat_state.speed
	move_and_slide()


## Calculates damage from [param attacker] to [param defender].
## Formula: max(1.0, effective_attack - effective_defense).
## Berserk: attacker +50% attack, defender -30% defense.
## EffectComponent modifiers applied to both stats after berserk.
## (FR-6: Damage Resolution)
static func calculate_damage(attacker: ChimeraEntity, defender: ChimeraEntity) -> float:
	var base_damage: float = attacker.combat_state.attack
	if attacker.combat_state.is_berserk:
		base_damage *= 1.5
	var defense: float = defender.combat_state.defense
	if defender.combat_state.is_berserk:
		defense *= 0.7
	base_damage = attacker.effect_component.get_modified_stat("attack", base_damage)
	defense = defender.effect_component.get_modified_stat("defense", defense)
	return maxf(1.0, base_damage - defense)
