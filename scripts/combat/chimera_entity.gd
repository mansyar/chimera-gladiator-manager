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
