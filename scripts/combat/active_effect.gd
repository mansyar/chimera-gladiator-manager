class_name ActiveEffect
extends RefCounted

## Transient status effect applied to a chimera during combat.
## Tracks a duration that ticks down each frame; expires when it reaches zero.

var effect_type: AbilityEffect.EffectType
var stat_name: String
var amount: float
var duration: float
var source_id: String


func tick(delta: float) -> bool:
	duration -= delta
	return duration <= 0.0
