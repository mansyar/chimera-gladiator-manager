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
